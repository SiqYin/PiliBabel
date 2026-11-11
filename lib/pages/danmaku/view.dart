import 'dart:async';
import 'dart:convert';

import 'package:PiliPlus/grpc/bilibili/community/service/dm/v1.pb.dart';
import 'package:PiliPlus/pages/danmaku/controller.dart';
import 'package:PiliPlus/pages/danmaku/danmaku_model.dart';
import 'package:PiliPlus/plugin/pl_player/controller.dart';
import 'package:PiliPlus/plugin/pl_player/models/play_status.dart';
import 'package:PiliPlus/plugin/pl_player/utils/danmaku_options.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:PiliPlus/utils/danmaku_utils.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:canvas_danmaku/canvas_danmaku.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

/// 传入播放器控制器，监听播放进度，加载对应弹幕
class PlDanmaku extends StatefulWidget {
  final int cid;
  final PlPlayerController playerController;
  final bool isPipMode;
  final bool isFullScreen;
  final bool isFileSource;
  final Size size;

  const PlDanmaku({
    super.key,
    required this.cid,
    required this.playerController,
    this.isPipMode = false,
    required this.isFullScreen,
    required this.isFileSource,
    required this.size,
  });

  @override
  State<PlDanmaku> createState() => _PlDanmakuState();

  bool get notFullscreen => !isFullScreen || isPipMode;
}

class _PlDanmakuState extends State<PlDanmaku> {
  PlPlayerController get playerController => widget.playerController;

  late final PlDanmakuController _plDanmakuController;
  DanmakuController<DanmakuExtra>? _controller;
  Worker? _danmakuTranslateWorker;
  int latestAddedPosition = -1;
  int _preTranslateCursor = 0;
  bool _loggedEarlySpecialDanmaku = false;
  /// 3.8.9：原位换文去抖标记。译文一批批回来会连着触发多次 revision 递增，
  /// 每次都全量扫描在飞弹幕会把主线程压住；这里合并到**帧末**只扫一次。
  bool _swapScheduled = false;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      debugPrint(
        '[PlDanmaku] init state=${identityHashCode(this)} cid=${widget.cid} '
        'fileSource=${widget.isFileSource} fullScreen=${widget.isFullScreen} '
        'pip=${widget.isPipMode}',
      );
    }
    _plDanmakuController = PlDanmakuController(
      widget.cid,
      playerController,
      widget.isFileSource,
    );
    if (playerController.enableShowDanmaku.value) {
      if (widget.isFileSource) {
        _plDanmakuController.initFileDmIfNeeded();
      } else {
        _plDanmakuController.queryDanmaku(
          DmUtils.calcSegment(playerController.positionInMilliseconds),
        );
      }
    }
    playerController
      ..addStatusLister(playerListener)
      ..addPositionListener(videoPositionListen);
    // 开启弹幕翻译时立即清屏，下一拍以译文重新添加；
    // 同时把已加载的整段弹幕批量送进翻译缓存，避免逐条排队赶不上出生时刻。
    _danmakuTranslateWorker = ever(
      UiTranslateService.to.danmakuTranslate,
      (bool on) {
        if (on) {
          _preTranslateCursor = 0;
          _controller?.clear();
          _plDanmakuController.pretranslateLoadedDanmaku();
        }
      },
    );
  }

  @override
  void didUpdateWidget(PlDanmaku oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notFullscreen != widget.notFullscreen &&
        !DanmakuOptions.sameFontScale) {
      _controller?.updateOption(
        DanmakuOptions.get(notFullscreen: widget.notFullscreen),
      );
    }
  }

  /// 上次做过「原文→译文」原位换文扫描的 revision（3.8.0）。
  int _lastSwapRevision = -1;

  /// 添加时译文尚未就绪、等待原位换文的源文本集合（3.8.0）。
  /// 只扫这些条目：已换成译文的/本来就是译文的不再当源文入队。
  final Set<String> _awaitingSwapSources = <String>{};

  /// 播放器状态监听
  void playerListener(PlayerStatus status) {
    if (_controller case final controller?) {
      if (status.isPlaying) {
        controller.resume();
      } else {
        controller.pause();
      }
    }
  }

  @pragma('vm:notify-debugger-on-exception')
  void videoPositionListen(Duration position) {
    if (_controller == null || !playerController.enableShowDanmaku.value) {
      return;
    }

    if (!playerController.showDanmaku && !widget.isPipMode) {
      return;
    }

    if (!playerController.playerStatus.isPlaying) {
      return;
    }

    int currentPosition = position.inMilliseconds;
    currentPosition -= currentPosition % 100; //取整百的毫秒数
    if (currentPosition == latestAddedPosition) {
      return;
    }
    latestAddedPosition = currentPosition;

    // 弹幕翻译：预译“当前进度往后 ~15 秒”的弹幕，使播放到达时已是译文；
    // 用游标避免重复入队，并在跳转（含拖到中间再开启）时从当前位置重新计。
    if (UiTranslateService.to.danmakuTranslate.value) {
      final to = currentPosition + 15000;
      if (_preTranslateCursor < currentPosition - 5000 ||
          _preTranslateCursor > to) {
        _preTranslateCursor = currentPosition;
      }
      if (to > _preTranslateCursor) {
        // 3.8.9：整段批量送翻，而不是逐条 uiTx。
        // 逐条入队赶不上内置引擎的单条请求速度（弹幕会先于译文出生，
        // 只能等「原位换文」再改写），这里改成一段一次批量，译文成片到达。
        final contents = <String>[];
        for (int t = _preTranslateCursor; t <= to; t += 1000) {
          final list = _plDanmakuController.getCurrentDanmaku(t);
          if (list == null) continue;
          for (final e in list) {
            if (e.mode == 7) continue;
            contents.add(e.content);
          }
        }
        if (contents.isNotEmpty) {
          unawaited(UiTranslateService.to.pretranslateDanmaku(contents));
        }
        _preTranslateCursor = to;
      }
    }

    // 原位换文（3.8.0）：预译/即时翻译陆续落缓存后，把仍在屏上飞行、
    // 显示着原文的条目替换为译文（revision 变化才扫描，一次线性遍历）。
    if (UiTranslateService.to.danmakuTranslate.value) {
      final revision = UiTranslateService.to.revision.value;
      if (revision != _lastSwapRevision) {
        _lastSwapRevision = revision;
        // 帧末合并扫描：一批译文可能连着触发多次 revision 递增，
        // 每次都全量遍历在飞弹幕会明显卡顿。
        _scheduleSwapTranslatedInFlight();
      }
    }

    List<DanmakuElem>? currentDanmakuList = _plDanmakuController
        .getCurrentDanmaku(currentPosition);
    if (currentDanmakuList != null) {
      final blockColorful = DanmakuOptions.blockColorful;
      final danmakuWeight = DanmakuOptions.danmakuWeight;
      for (DanmakuElem e in currentDanmakuList) {
        if (e.weight < danmakuWeight) return;
        if (e.mode == 7) {
          if (kDebugMode &&
              !_loggedEarlySpecialDanmaku &&
              currentPosition <= 10000) {
            _loggedEarlySpecialDanmaku = true;
            debugPrint(
              '[PlDanmaku] early special danmaku state=${identityHashCode(this)} '
              'cid=${widget.cid} position=$currentPosition progress=${e.progress} '
              'mode=${e.mode} contentLength=${e.content.length}',
            );
          }
          try {
            _controller!.addDanmaku(
              SpecialDanmakuContentItem.fromList(
                DmUtils.decimalToColor(e.color),
                e.fontsize.toDouble(),
                jsonDecode(e.content.replaceAll('\n', '\\n')),
                extra: VideoDanmaku(
                  id: e.id.toInt(),
                  mid: e.midHash,
                  like: e.likeCount.toInt(),
                ),
              ),
            );
          } catch (_) {}
        } else {
          final displayCount = e.count > Pref.mergeDanmakuMarkThreshold
              ? e.count
              : null;
          final preferredCountPosition = switch (Pref.mergeDanmakuMarkPosition) {
            0 => DanmakuCountPosition.hidden,
            2 => DanmakuCountPosition.tail,
            _ => DanmakuCountPosition.head,
          };
          final countPosition = displayCount == null
              ? DanmakuCountPosition.hidden
              : preferredCountPosition;
          // Apply fontSize for merged danmaku (count > 1)
          // e.fontsize contains base * enlargeRate, multiply by user's scale
          double? itemFontSize;
          if (e.fontsize > 0 && e.count > 1) {
            final scale = !widget.isFullScreen || widget.isPipMode
                ? DanmakuOptions.danmakuFontScale
                : DanmakuOptions.danmakuFontScaleFS;
            itemFontSize = e.fontsize.toDouble() * scale;
          }
          // If itemFontSize is null, canvas_danmaku uses global fontSize from DanmakuOption
          
          final showText = UiTranslateService.to.danmakuTranslate.value
              ? uiTx(e.content)
              : e.content;
          // 译文未就绪（uiTx 原样返回）→ 记入等待换文集合，
          // 缓存到达后由 _swapTranslatedInFlight 原位切换（3.8.0）。
          if (showText == e.content &&
              UiTranslateService.to.danmakuTranslate.value &&
              !UiTranslateService.to.isSourceLanguage) {
            _awaitingSwapSources.add(e.content);
            if (_awaitingSwapSources.length > 600) {
              _awaitingSwapSources.clear();
            }
          }
          _controller!.addDanmaku(
            DanmakuContentItem(
              showText,
              color: blockColorful
                  ? Colors.white
                  : DmUtils.decimalToColor(e.color),
              type: DmUtils.getPosition(e.mode),
              isColorful:
                  playerController.showVipDanmaku &&
                  e.colorful == DmColorfulType.VipGradualColor,
              count: displayCount,
              countPosition: countPosition,
              fontSize: itemFontSize,
              selfSend: e.isSelf,
              extra: VideoDanmaku(
                id: e.id.toInt(),
                mid: e.midHash,
                like: e.likeCount.toInt(),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  /// 原位换文（3.8.0）：遍历画布活体条目，凡是「显示的还是原文、而缓存里
  /// 已经有了译文」的，直接替换内容并作废其图像缓存——下一帧即按译文绘制，
  /// 飞行轨迹不变。mode 7 高级弹幕不做（同 add 时口径）。
  /// 把「原位换文」合并到帧末执行（3.8.9 去抖）。
  void _scheduleSwapTranslatedInFlight() {
    if (_swapScheduled) return;
    _swapScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _swapScheduled = false;
      if (!mounted) return;
      _swapTranslatedInFlight();
    });
  }

  void _swapTranslatedInFlight() {
    if (_controller == null || _awaitingSwapSources.isEmpty) return;
    final service = UiTranslateService.to;
    if (!service.enabled || service.isSourceLanguage) return;
    for (final track in _controller!.scrollDanmaku) {
      for (final item in track) {
        final current = item.content.text;
        if (!_awaitingSwapSources.contains(current)) continue;
        final translated = UiTranslateService.tx(current);
        if (translated != current) {
          item.replaceContent(translated);
          _awaitingSwapSources.remove(current);
        }
      }
    }
    for (final item in _controller!.staticDanmaku) {
      if (item == null) continue;
      final current = item.content.text;
      if (!_awaitingSwapSources.contains(current)) continue;
      final translated = UiTranslateService.tx(current);
      if (translated != current) {
        item.replaceContent(translated);
        _awaitingSwapSources.remove(current);
      }
    }
    // specialDanmaku（mode 7 高级弹幕）不支持换文，与添加时口径一致。
    // 上限保护：集合超限时整体清空（最坏情形是个别条目停在原文）。
    if (_awaitingSwapSources.length > 600) _awaitingSwapSources.clear();
  }

  void dispose() {
    if (kDebugMode) {
      debugPrint(
        '[PlDanmaku] dispose state=${identityHashCode(this)} cid=${widget.cid}',
      );
    }
    playerController
      ..removePositionListener(videoPositionListen)
      ..removeStatusLister(playerListener);
    _plDanmakuController.dispose();
    _danmakuTranslateWorker?.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final option = DanmakuOptions.get(
      notFullscreen: widget.notFullscreen,
      speed: playerController.playbackSpeed,
    );
    return Obx(
      () => AnimatedOpacity(
        opacity: playerController.enableShowDanmaku.value
            ? playerController.danmakuOpacity.value
            : 0,
        duration: const Duration(milliseconds: 100),
        child: DanmakuScreen<DanmakuExtra>(
          createdController: (e) {
            if (kDebugMode) {
              debugPrint(
                '[PlDanmaku] created canvas controller state=${identityHashCode(this)} '
                'cid=${widget.cid} controller=${identityHashCode(e)}',
              );
            }
            playerController.danmakuController = _controller = e;
          },
          option: option,
          size: widget.size,
        ),
      ),
    );
  }

}
