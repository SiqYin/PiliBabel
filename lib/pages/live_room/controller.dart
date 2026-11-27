import 'package:PiliPlus/utils/storage_key.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'dart:async' show Timer, StreamSubscription;
import 'dart:convert' show jsonDecode;
import 'dart:math' as math;

import 'package:PiliPlus/common/widgets/dialog/report.dart';
import 'package:PiliPlus/common/widgets/flutter/text_field/controller.dart';
import 'package:PiliPlus/http/constants.dart';
import 'package:PiliPlus/http/live.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/models/common/super_chat_type.dart';
import 'package:PiliPlus/models/common/video/live_quality.dart';
import 'package:PiliPlus/models/model_owner.dart';
import 'package:PiliPlus/models_new/live/live_danmaku/danmaku_msg.dart';
import 'package:PiliPlus/models_new/live/live_danmaku/live_emote.dart';
import 'package:PiliPlus/models_new/live/live_dm_info/data.dart';
import 'package:PiliPlus/models_new/live/live_fans_medal/data.dart';
import 'package:PiliPlus/models_new/live/live_fans_medal/item.dart';
import 'package:PiliPlus/models_new/live/live_medal_wall/uinfo_medal.dart';
import 'package:PiliPlus/models_new/live/live_info_by_user/medal.dart' as info;
import 'package:PiliPlus/models_new/live/live_room_info_h5/data.dart';
import 'package:PiliPlus/models_new/live/live_room_play_info/codec.dart';
import 'package:PiliPlus/models_new/live/live_room_play_info/stream.dart';
import 'package:PiliPlus/models_new/live/live_superchat/item.dart';
import 'package:PiliPlus/models_new/live/live_trace/data.dart';
import 'package:PiliPlus/pages/common/publish/publish_route.dart';
import 'package:PiliPlus/pages/danmaku/danmaku_model.dart';
import 'package:PiliPlus/pages/live_room/send_danmaku/view.dart';
import 'package:PiliPlus/pages/video/widgets/header_control.dart';
import 'package:PiliPlus/plugin/pl_player/controller.dart';
import 'package:PiliPlus/plugin/pl_player/models/data_source.dart';
import 'package:PiliPlus/plugin/pl_player/utils/danmaku_options.dart';
import 'package:PiliPlus/services/logger.dart' show logger;
import 'package:PiliPlus/services/service_locator.dart';
import 'package:PiliPlus/tcp/live.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:PiliPlus/utils/accounts/account.dart';
import 'package:PiliPlus/utils/connectivity_utils.dart';
import 'package:PiliPlus/utils/danmaku_utils.dart';
import 'package:PiliPlus/utils/duration_utils.dart';
import 'package:PiliPlus/utils/extension/iterable_ext.dart';
import 'package:PiliPlus/utils/extension/rx_ext.dart';
import 'package:PiliPlus/utils/global_data.dart';
import 'package:PiliPlus/utils/num_utils.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:PiliPlus/utils/theme_utils.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:PiliPlus/utils/video_utils.dart';
import 'package:collection/collection.dart';
import 'package:canvas_danmaku/canvas_danmaku.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kReleaseMode;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

part 'controller_mixin/data.dart';
part 'controller_mixin/block.dart';
part 'controller_mixin/time.dart';
part 'controller_mixin/size.dart';
part 'controller_mixin/like.dart';
part 'controller_mixin/sc.dart';
part 'controller_mixin/dm.dart';
part 'controller_mixin/dm_stream.dart';
part 'controller_mixin/dm_trim.dart';
part 'controller_mixin/trace.dart';
part 'controller_mixin/medal.dart';

const int _kMaxChatCount = 500;
const int _kTrimCount = _kMaxChatCount + 50;
const int _kSafeTrimIndex = 200;

class LiveRoomController extends GetxController
    with
        _LiveDataMixin,
        _LiveBlockMixin,
        _LiveTimeMixin,
        _LiveSizeMixin,
        _LiveLikeMixin,
        _LiveScMixin,
        _LiveDMMixin,
        _LiveDMTrimMixin,
        _LiveDMStreamMixin,
        _LiveTraceMixin,
        _LiveMedalMixin {
  LiveRoomController(this.heroTag, {this.fromPip = false});
  final String heroTag;
  final bool fromPip;

  bool isReturningFromPip = false;


  // PiP 模式标志
  RxBool isInPipMode = false.obs;


  void startLiveTimer() {
    _startLiveTimeTimer();
    _startLiveTraceTimer();
  }

  void cancelLiveTimer() {
    _stopLiveTimeTimer();
    _stopLiveTraceTimer();
  }

  void startService() => startLiveTimer();

  void stopService() => cancelLiveTimer();


  late final RxInt pageIndex = 0.obs;
  PageController? pageController;






  @override
  void onInit() {
    super.onInit();
    plPlayerController.onNeedsPlayerInit = queryLiveUrl;

    // 从参数中提取 roomId（支持 int 或 Map 格式）
    final args = Get.arguments;
    if (args is Map) {
      roomId = (args['roomId'] as int?) ?? (args['id'] as int? ?? 0);
    } else {
      roomId = args as int;
    }

    scrollController = ScrollController()..addListener(listener);
    final account = Accounts.main;
    isLogin = account.isLogin;
    mid = account.mid;
    heartbeat = Accounts.heartbeat;

    // 直接透传构造函数传入的 fromPip 标志，因为它在 view.dart 中已经经过了校验
    isReturningFromPip = fromPip;

    final Future<void> liveUrlFuture;
    if (isReturningFromPip) {
      isPortrait.value = plPlayerController.isVertical;
      isLoaded.value = true;
      // 播放器无需重建，但 stream/ruid/liveTime 等元数据随旧 controller 丢失，
      // 必须重新拉取；playerInit 会因 isReturningFromPip 跳过数据源初始化
      liveUrlFuture = queryLiveUrl();
    } else {
      liveUrlFuture = queryLiveUrl(autoFullScreenFlag: true);
    }
    Future.wait([
      liveUrlFuture,
      queryLiveInfoH5(),
    ]).whenComplete(_initLiveTraceIfNeeded);
    if (heartbeat.isLogin && !Pref.historyPause) {
      VideoHttp.roomEntryAction(roomId: roomId);
    }
    if (showSuperChat) {
      pageController = PageController();
    }
  }

  Future<void>? playerInit({
    bool autoplay = true,
    bool autoFullScreenFlag = false,
  }) {
    if (videoUrl == null) {
      return null;
    }
    // 如果是从小窗返回，播放器已在播放，跳过初始化
    if (isReturningFromPip) {
      return null;
    }

    // 如果播放器已被彻底销毁（例如在其他页面关闭了小窗），重新获取单例实例
    if (plPlayerController.videoPlayerController == null) {
      plPlayerController = PlPlayerController.ensureInstance(isLive: true);
    }

    // 确保播放器处于直播模式
    plPlayerController.isLive = true;

    return plPlayerController
        .setDataSource(
          NetworkSource(videoSource: videoUrl!, audioSource: null),
          isLive: true,
          autoplay: autoplay,
          isVertical: isPortrait.value,
          autoFullScreenFlag: autoFullScreenFlag,
          roomId: roomId,
        )
        .then((_) async {
          if (!autoplay) {
            return;
          }
          final isActuallyPlaying =
              plPlayerController.videoPlayerController?.state.playing == true;
          if (!isActuallyPlaying) {
            await plPlayerController.play();
          }
        });
  }

  Future<void> queryLiveUrl({bool autoFullScreenFlag = false}) async {
    currentQn ??= await ConnectivityUtils.isWiFi
        ? Pref.liveQuality
        : Pref.liveQualityCellular;
    final res = await LiveHttp.liveRoomInfo(
      roomId: roomId,
      qn: currentQn,
      onlyAudio: plPlayerController.onlyPlayAudio.value,
    );
    if (res case Success(:final response)) {
      if (response.liveStatus != 1) {
        _showDialog(uiTx('当前直播间未开播'));
        return;
      }
      final playurl = response.playurlInfo?.playurl;
      if (playurl == null) {
        _showDialog(uiTx('无法获取播放地址'));
        return;
      }
      ruid = response.uid;
      if (response.roomId case final roomId?) {
        this.roomId = roomId;
      }
      liveTime.value = response.liveTime;
      startLiveTimer();
      if (Accounts.heartbeat.isLogin) {
        LiveHttp.startLiveHeartbeat(roomId, ruid!);
      }
      isPortrait.value = response.isPortrait ?? false;
      stream = playurl.stream;
      _initStreamIndex();
      await Future.wait([
        ?initLiveUrl(
          streamIndex: streamIndex,
          formatIndex: formatIndex,
          codecIndex: codecIndex,
          liveUrlIndex: liveUrlIndex,
        ),
        if (isLogin && !isLoaded.value) _fetchBlockRules(),
      ]);

      // 置于 initLiveUrl 之后：恢复场景的首次拉取靠该标志让 playerInit 跳过
      // 数据源重建，完成后清零，切换路线/画质才会真正重建数据源
      isReturningFromPip = false;
      isLoaded.value = true;
      if (isLogin && ruid != null) {
        getUserMedal();
      }
    } else {
      _showDialog(res.toString());
    }
  }

  // 拉取成功前为 null（含小窗恢复后的重拉窗口期），使用处需判空
  List<Stream>? stream;
  int streamIndex = 0;
  int formatIndex = 0;
  int codecIndex = 0;
  int liveUrlIndex = 0;

  void _initStreamIndex() {
    final pref = Pref.liveStream;
    if (pref != null) {
      try {
        final String protocolName = pref[0];
        final String formatName = pref[1];
        final String codecName = pref[2];
        for (var (i, s) in stream!.indexed) {
          if (s.protocolName == protocolName) {
            streamIndex = i;
            for (var (j, f) in s.format.indexed) {
              if (f.formatName == formatName) {
                formatIndex = j;
                for (var (k, c) in f.codec.indexed) {
                  if (c.codecName == codecName) {
                    codecIndex = k;
                    return;
                  }
                }
              }
            }
          }
        }
      } catch (_) {}
    }
  }

  Future<void>? initLiveUrl({
    int streamIndex = 0,
    int formatIndex = 0,
    int codecIndex = 0,
    int liveUrlIndex = 0,
  }) {
    this.streamIndex = streamIndex;
    this.formatIndex = formatIndex;
    this.codecIndex = codecIndex;
    this.liveUrlIndex = liveUrlIndex;

    final CodecItem item = stream!
        .getOrFirst(streamIndex)
        .format
        .getOrFirst(formatIndex)
        .codec
        .getOrFirst(codecIndex);
    // 以服务端返回的码率为准
    currentQn = item.currentQn;
    acceptQnList = item.acceptQn.map((e) {
      return (
        code: e,
        desc: LiveQuality.fromCode(e)?.desc ?? e.toString(),
      );
    }).toList();
    currentQnDesc.value =
        LiveQuality.fromCode(currentQn)?.desc ?? currentQn.toString();
    videoUrl = VideoUtils.getLiveCdnUrl(item, index: liveUrlIndex);
    return playerInit()?.whenComplete(_startSizeSub);
  }

  // 直播投屏时，优先选择 HLS 协议的播放地址，且不使用 AV1 编码
  // 实测发现http_stream协议在投屏时会报版权问题，导致无法播放，HLS协议则没有这个问题
  String? _preferredCastUrl() {
    final stream = this.stream;
    if (stream == null) {
      return null;
    }
    final currentCastUrl = _currentCastUrl();
    if (currentCastUrl != null) {
      return currentCastUrl;
    }

    final candidates = <({String url, int score})>[];
    for (final streamItem in stream) {
      final protocolName = streamItem.protocolName?.toLowerCase() ?? '';
      for (final formatItem in streamItem.format) {
        final formatName = formatItem.formatName?.toLowerCase() ?? '';
        for (final codecItem in formatItem.codec) {
          final codecName = codecItem.codecName?.toLowerCase() ?? '';
          for (final urlInfo in codecItem.urlInfo.indexed) {
            final url = VideoUtils.getLiveCdnUrl(codecItem, index: urlInfo.$1);
            final lowerUrl = url.toLowerCase();
            final isHls =
                protocolName.contains('hls') || lowerUrl.contains('.m3u8');
            if (!isHls) {
              continue;
            }
            var score = 0;
            if (formatName.contains('ts')) {
              score += 40;
            }
            if (formatName.contains('fmp4')) {
              score += 20;
            }
            if (codecName.contains('avc') || codecName.contains('h264')) {
              score += 30;
            }
            if (codecName.contains('hevc') || codecName.contains('h265')) {
              score -= 20;
            }
            if (codecName.contains('av1')) {
              score -= 30;
            }
            if (codecItem.currentQn == currentQn) {
              score += 10;
            }
            if (urlInfo.$1 == liveUrlIndex) {
              score += 5;
            }
            candidates.add((url: url, score: score));
          }
        }
      }
    }
    if (candidates.isEmpty) {
      return null;
    }
    candidates.sort((a, b) => b.score.compareTo(a.score));
    return candidates.first.url;
  }

  String? _currentCastUrl() {
    final streamItem = stream!.getOrFirst(streamIndex);
    final formatItem = streamItem.format.getOrFirst(formatIndex);
    final codecItem = formatItem.codec.getOrFirst(codecIndex);
    final url = VideoUtils.getLiveCdnUrl(codecItem, index: liveUrlIndex);
    final protocolName = streamItem.protocolName?.toLowerCase() ?? '';
    final codecName = codecItem.codecName?.toLowerCase() ?? '';
    final lowerUrl = url.toLowerCase();
    final isHls = protocolName.contains('hls') || lowerUrl.contains('.m3u8');
    if (!isHls || codecName.contains('av1')) {
      return null;
    }
    return url;
  }

  Future<void> queryLiveInfoH5() async {
    final res = await LiveHttp.liveRoomInfoH5(roomId: roomId);
    if (res case Success(:final response)) {
      roomInfoH5.value = response;
      title.value = response.roomInfo?.title ?? '';
      watchedShow.value = response.watchedShow?.textLarge;
      videoPlayerServiceHandler?.onVideoDetailChange(response, roomId, heroTag);
    } else {
      res.toast();
    }
  }

  Future<void> onCast() async {
    final currentUrl = videoUrl;
    final url = _preferredCastUrl() ?? currentUrl;
    if (url == null || url.isEmpty) {
      SmartDialog.showToast(uiTx('播放地址未就绪'));
      return;
    }
    final castTitle = title.value.isNotEmpty ? title.value : null;
    await Get.toNamed(
      '/dlna',
      parameters: {
        'url': url,
        'title': ?castTitle,
      },
    );
  }

  void _showDialog(String title) {
    showDialog(
      context: Get.context!,
      builder: (_) => AlertDialog(
        title: Text(title),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(uiTx('关闭'),
              style: TextStyle(color: ThemeUtils.theme.colorScheme.outline),
            ),
          ),
          TextButton(
            onPressed: () {
              if (plPlayerController.isDesktopPip) {
                plPlayerController.exitDesktopPip();
              }
              Get
                ..back()
                ..back();
            },
            child: Text(uiTx('退出')),
          ),
        ],
      ),
    );
  }


  @override
  void onClose() {
    plPlayerController.onNeedsPlayerInit = null;
    _stopSizeSub();
    // 心跳定时器是静态的，无论是否小窗都要取消
    LiveHttp.cancelLiveHeartbeat();
    // 如果在小窗模式，不清理资源
    if (!isInPipMode.value) {
      closeLiveMsg();
      cancelLikeTimer();
      cancelLiveTimer();
      savedDanmaku?.clear();
      savedDanmaku = null;
      messages.clear();
      if (showSuperChat) {
        superChatMsg.clear();
        fsSC.value = null;
      }
      scrollController
        ..removeListener(listener)
        ..dispose();
      pageController?.dispose();
      danmakuController = null;
    }
    super.onClose();
  }

  // 修改画质
  Future<void>? changeQn(int qn) {
    if (currentQn == qn) {
      return null;
    }
    currentQn = qn;
    currentQnDesc.value =
        LiveQuality.fromCode(currentQn)?.desc ?? currentQn.toString();
    return queryLiveUrl();
  }



  @override
  void toastNotLogin() {
    SmartDialog.showToast(uiTx('账号未登录'));
  }

  void onSendDanmaku([bool fromEmote = false]) {
    if (kReleaseMode && !isLogin) {
      toastNotLogin();
      return;
    }
    Get.key.currentState!.push(
      PublishRoute(
        barrierColor: Colors.transparent,
        pageBuilder: (context, animation, secondaryAnimation) {
          return Theme(
            data: ThemeUtils.darkTheme,
            child: LiveSendDmPanel(
              fromEmote: fromEmote,
              liveRoomController: this,
              items: savedDanmaku,
              autofocus: !fromEmote,
              onSave: (msg) {
                if (msg.isEmpty) {
                  savedDanmaku?.clear();
                  savedDanmaku = null;
                } else {
                  savedDanmaku = msg.toList();
                }
              },
            ),
          );
        },
        transitionDuration: fromEmote
            ? const Duration(milliseconds: 400)
            : PlatformUtils.isDesktop
            ? const Duration(milliseconds: 350)
            : const Duration(milliseconds: 400),
      ),
    );
  }

  void onAtUser(DanmakuMsg item) {
    savedDanmaku = [
      RichTextItem.fromStart(
        '@${item.name} ',
        rawText: item.extra.mid.toString(),
        type: .at,
        id: item.extra.id.toString(),
      ),
    ];
    onSendDanmaku();
  }

}
