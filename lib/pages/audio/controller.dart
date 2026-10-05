import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';

import 'dart:async';
import 'dart:io' show Platform;

import 'package:PiliPlus/common/constants.dart';
import 'package:PiliPlus/common/widgets/dialog/simple_dialog_option.dart';
import 'package:PiliPlus/grpc/audio.dart';
import 'package:PiliPlus/grpc/bilibili/app/listener/v1.pb.dart'
    show
        DetailItem,
        PlayURLResp,
        PlaylistSource,
        PlayInfo,
        ThumbUpReq_ThumbType,
        ListOrder,
        DashItem,
        ResponseUrl;
import 'package:PiliPlus/http/browser_ua.dart';
import 'package:PiliPlus/http/constants.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/audio_normalization.dart';
import 'package:PiliPlus/models/common/video/audio_quality.dart';
import 'package:PiliPlus/models/video/play/url.dart' as http_model show Volume;
import 'package:PiliPlus/pages/common/common_intro_controller.dart'
    show FavMixin;
import 'package:PiliPlus/pages/dynamics_repost/view.dart';
import 'package:PiliPlus/pages/main_reply/view.dart';
import 'package:PiliPlus/pages/setting/models/play_settings.dart'
    show kMaxVolume;
import 'package:PiliPlus/pages/sponsor_block/block_mixin.dart';
import 'package:PiliPlus/pages/video/controller.dart';
import 'package:PiliPlus/pages/video/introduction/ugc/widgets/triple_mixin.dart';
import 'package:PiliPlus/plugin/pl_player/controller.dart';
import 'package:PiliPlus/plugin/pl_player/models/play_repeat.dart';
import 'package:PiliPlus/plugin/pl_player/models/play_status.dart';
import 'package:PiliPlus/services/service_locator.dart';
import 'package:PiliPlus/services/shutdown_timer_service.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:PiliPlus/utils/connectivity_utils.dart';
import 'package:PiliPlus/utils/extension/iterable_ext.dart';
import 'package:PiliPlus/utils/extension/num_ext.dart';
import 'package:PiliPlus/utils/global_data.dart';
import 'package:PiliPlus/utils/id_utils.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:PiliPlus/utils/share_utils.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/storage_key.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:PiliPlus/utils/video_utils.dart';
import 'package:fixnum/fixnum.dart' show Int64;
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';
import 'package:media_kit/media_kit.dart';

class AudioController extends GetxController
    with
        GetTickerProviderStateMixin,
        TripleMixin,
        FavMixin,
        BlockConfigMixin,
        BlockMixin,
        AudioNormalizationMixin {
  late Int64 id;
  late Int64 oid;
  late List<Int64> subId;
  late int itemType;
  Int64? extraId;
  late final PlaylistSource from;
  late final String heroTag;
  @override
  late final bool isUgc = itemType == 1;

  final audioItem = Rxn<DetailItem>();

  bool _hasInit = false;
  @override
  Player? player;
  late int cacheAudioQa;

  /// 当前播放 URL 的令牌来源，决定媒体请求指纹。
  ///
  /// 音频 URL 有两个来源，指纹要求正好相反（实测，弄错必 403）：
  ///
  /// * [_TokenOrigin.app]——由本页 gRPC `bilibili.app.listener.v1.Listener/PlayURL`
  ///   自取流，或从视频页跳转时透传的视频页 `audioUrl`（视频页自己也是 gRPC
  ///   `PlayView` 的 APP 同源直链）。要**不带** Referer，UA 用官方 APP 的。
  /// * [_TokenOrigin.web]——`/x/player/wbi/playurl` 的 Web 令牌。要
  ///   `Referer: https://www.bilibili.com`，且 `upos-*-mirror*ov` 这类海外主机
  ///   只认 Safari/macOS 的 UA。
  ///
  /// 之前这里无论来源一律用 Web 指纹，导致 APP 令牌被带上非空 Referer，
  /// CDN 直接 403 ——表现就是听视频加载不出来、进度条时长恒为 00:00。
  _TokenOrigin _tokenOrigin = _TokenOrigin.app;

  /// 本次取流拿到的全部音频轨道。音质切换靠它在同一批轨道里换id 重新起播，
  /// 不必重新取流——与官方听视频的音质切换行为一致。
  List<DashItem> _audios = const [];

  /// 当前这批轨道里实际可用的音质，供UI 显示切换面板。
  /// durl 源下没有多轨，这里会被清空、面板随即消失；用 Rx 是因为取流不是
  /// 每次都发生，但 UI 必须跟着变。
  final RxList<AudioQuality> availableAudioQualities =
      RxList<AudioQuality>();

  /// 当前选中的音质。
  final Rx<AudioQuality> currentAudioQa = Pref.defaultAudioQuality.obs;

  late bool isDragging = false;
  final RxInt position = RxInt(0);
  final RxInt duration = RxInt(0);

  late final AnimationController animController;

  List<StreamSubscription>? _subscriptions;

  int? index;
  List<DetailItem>? playlist;

  late double speed = 1.0;

  late final Rx<PlayRepeat> playMode = Pref.audioPlayMode.obs;

  @override
  late final isLogin = Accounts.main.isLogin;

  Duration? _start;
  VideoDetailController? _videoDetailController;

  String? _prev;
  String? _next;
  bool get reachStart => _prev == null;

  ListOrder order = ListOrder.ORDER_NORMAL;

  double? _lastVolume;
  late final RxDouble desktopVolume = RxDouble(Pref.desktopVolume);

  void toggleVolume() {
    if (_lastVolume == null) {
      _lastVolume = desktopVolume.value;
      setVolume(0, clearLastVolme: false);
    } else {
      setVolume(_lastVolume!);
    }
  }

  void setVolume(double volume, {bool clearLastVolme = true}) {
    if (clearLastVolme) {
      _lastVolume = null;
    }
    desktopVolume.value = volume;
    player?.setVolume(volume * 100);
  }

  void syncVolume([_]) {
    final volume = desktopVolume.value;
    PlPlayerController.instance
      ?..volume.value = volume
      ..videoPlayerController?.setVolume(volume * 100);
    GStorage.setting.put(SettingBoxKey.desktopVolume, volume.toPrecision(3));
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    oid = Int64(args['oid']);
    final id = args['id'];
    this.id = id != null ? Int64(id) : oid;
    subId = (args['subId'] as List<int>?)?.map(Int64.new).toList() ?? [oid];
    itemType = args['itemType'];
    from = args['from'];
    heroTag = args['heroTag'];
    _start = args['start'];
    final int? extraId = args['extraId'];
    if (extraId != null) {
      this.extraId = Int64(extraId);
    }
    if (args['heroTag'] case String heroTag) {
      try {
        _videoDetailController = Get.find<VideoDetailController>(tag: heroTag);
      } catch (_) {}
    }

    _queryPlayList(isInit: true);

    final String? audioUrl = args['audioUrl'];
    final hasAudioUrl = audioUrl != null;
    if (hasAudioUrl) {
      _querySponsorBlock();
      // 视频页已按它选好轨道并传了音质码，这里对齐显示，否则面板会显示
      // 默认音质而实际播的是另一档。
      if (args['audioQa'] case final int qaCode) {
        currentAudioQa.value = AudioQuality.values.firstWhere(
          (e) => e.code == qaCode,
          orElse: () => Pref.defaultAudioQuality,
        );
      }
      // 视频页透传过来的 audioUrl 来自 gRPC PlayView 的 APP 同源直链，
      // 必须按 APP 指纹请求（APP UA + 不发 Referer），不能用 Web 指纹。
      _onOpenMedia(
        audioUrl,
        tokenOrigin: _TokenOrigin.app,
        volume: _videoDetailController?.volume,
      );
    }
    ConnectivityUtils.isWiFi.then((isWiFi) {
      cacheAudioQa = isWiFi ? Pref.defaultAudioQa : Pref.defaultAudioQaCellular;
      if (!hasAudioUrl) {
        _queryPlayUrl();
      }
    });
    videoPlayerServiceHandler
      ?..onPlay = onPlay
      ..onPause = onPause
      ..onSeek = onSeek;

    animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    if (shutdownTimerService.isActive) {
      shutdownTimerService
        ..onPause = onPause
        ..isPlaying = isPlaying;
    }
  }

  bool isPlaying() {
    return player?.state.playing ?? false;
  }

  Future<void>? onPlay() {
    return player?.play();
  }

  /// 单曲循环/单元素列表循环用到。
  ///
  /// 顺序很关键：media_kit 的 [Player.play] **只有在 `state.completed` 仍为 true**
  /// 时才会做真正的重播三步（seek(0) → playlist-pos=0 → 取消暂停）；而
  /// [Player.seek] 会把 `state.completed` 置为 false。所以"先 seek 再 play"会让
  /// play 退化成只把 pause 置 false 的空操作——EOF 时播放器本来就停在非暂停的
  /// idle 上（pause 已是 false），于是界面显示"正在播放"、进度条 00:00，声音却
  /// 永远不来，这就是「播完归零却不自动播」的成因。
  /// 因此这里直接 play()，让库自己走完成态重播；再用一次校验兜底。
  Future<void> _restartFromBeginning() async {
    final p = player;
    if (p == null) {
      return;
    }
    position.value = 0;
    try {
      await p.play();
    } catch (_) {}
    await Future.delayed(const Duration(milliseconds: 250));
    if (p.state.playing &&
        p.state.position <= const Duration(milliseconds: 600)) {
      return; // 已经真的从头播起来了
    }
    // 兜底：completed 已被别的路径清掉时 play() 仍可能是空操作；先把 pause 置
    // true（保证随后的 play() 一定有实际动作），再回到起点起播。
    try {
      await p.pause();
      await p.seek(Duration.zero);
      await p.play();
    } catch (_) {}
  }

  Future<void>? onPause() {
    return player?.pause();
  }

  Future<void>? onSeek(Duration duration) {
    if (kDebugMode) debugPrint('AudioController: onSeek to $duration');
    return player?.seek(duration);
  }

  void _updateCurrItem(DetailItem item) {
    audioItem.value = item;
    hasLike.value = item.stat.hasLike_7;
    coinNum.value = item.stat.hasCoin_8 ? 2 : 0;
    hasFav.value = item.stat.hasFav;
    videoPlayerServiceHandler?.onVideoDetailChange(
      item,
      (subId.firstOrNull ?? oid).toInt(),
      heroTag,
    );
  }

  Future<void> _queryPlayList({
    bool isInit = false,
    bool isLoadPrev = false,
    bool isLoadNext = false,
  }) async {
    final res = await AudioGrpc.audioPlayList(
      id: id,
      oid: isInit ? oid : null,
      subId: isInit ? subId : null,
      itemType: isInit ? itemType : null,
      from: isInit ? from : null,
      next: isLoadPrev
          ? _prev
          : isLoadNext
          ? _next
          : null,
      extraId: extraId,
      order: order,
    );
    if (res case Success(:final response)) {
      if (isInit) {
        late final paginationReply = response.paginationReply;
        _prev = response.reachStart ? null : paginationReply.prev;
        _next = response.reachEnd ? null : paginationReply.next;
        final index = response.list.indexWhere((e) => e.item.oid == oid);
        if (index != -1) {
          this.index = index;
          _updateCurrItem(response.list[index]);
          playlist = response.list;
        }
      } else if (isLoadPrev) {
        _prev = response.reachStart ? null : response.paginationReply.prev;
        if (response.list.isNotEmpty) {
          index += response.list.length;
          playlist?.insertAll(0, response.list);
        }
      } else if (isLoadNext) {
        _next = response.reachEnd ? null : response.paginationReply.next;
        if (response.list.isNotEmpty) {
          playlist?.addAll(response.list);
        }
      }
    } else {
      res.toast();
    }
  }

  @pragma('vm:notify-debugger-on-exception')
  void _querySponsorBlock() {
    if (isUgc && enableSponsorBlock) {
      try {
        final bvid = IdUtils.av2bv(oid.toInt());
        final cid = subId.first.toInt();
        querySponsorBlock(bvid: bvid, cid: cid);
      } catch (_) {}
    }
  }

  Future<bool> _queryPlayUrl() async {
    _querySponsorBlock();
    final res = await AudioGrpc.audioPlayUrl(
      itemType: itemType,
      oid: oid,
      subId: subId,
    );
    if (res case Success(:final response)) {
      // 必须回传解析结果：之前这里无条件 return true，导致取流失败被上层
      // playIndex/playNext 当成成功，继续跑后续状态更新。
      return _onPlay(response);
    } else {
      res.toast();
      return false;
    }
  }

  /// 解析取流响应并起播。返回是否真的拿到了可播放的地址。
  ///
  /// 原来这里对 playInfo 为空 / audios 为空 / durls 为空三种情况都是静默
  /// `return`，而 [_queryPlayUrl] 无论解析成败都 `return true`，于是失败被
  /// 完全吞掉：界面 player 已建但 duration 永远是 0，显示 00:00，用户看不到
  /// 任何错误。现在逐个分支都明确反馈。
  bool _onPlay(PlayURLResp data) {
    final PlayInfo? playInfo = data.playerInfo.values.firstOrNull;
    if (playInfo == null) {
      SmartDialog.showToast(uiTx('音频取流失败：未返回可播放信息'));
      return false;
    }
    http_model.Volume? volume;
    if (playInfo.hasVolume()) {
      final volumeInfo = playInfo.volume;
      volume = http_model.Volume(
        measuredI: volumeInfo.measuredI,
        measuredLra: volumeInfo.measuredLra,
        measuredTp: volumeInfo.measuredTp,
        measuredThreshold: volumeInfo.measuredThreshold,
        targetOffset: volumeInfo.targetOffset,
        targetI: volumeInfo.targetI,
        targetTp: volumeInfo.targetTp,
      );
    }
    if (playInfo.hasPlayDash()) {
      final playDash = playInfo.playDash;
      final audios = playDash.audio;
      if (audios.isEmpty) {
        SmartDialog.showToast(uiTx('音频取流失败：未返回音频轨道'));
        return false;
      }
      // 服务端直接给了总时长，先填上。这样即使后续起播失败，界面也能显示真实
      // 时长而不是 00:00 —— 之前 duration 只等mpv 的 stream.duration 事件，
      // 一旦CDN 403 就永远是 0。
      if (playDash.duration > 0) {
        duration.value = playDash.duration;
      }
      // 记下整批轨道，供音质切换时直接换轨道重播，不再二次取流。
      _audios = List.of(audios);
      _refreshAvailableQualities();
      final audio = _pickAudioTrack(cacheAudioQa);
      // listener gRPC 与视频 PlayView 同为 APP 同源直链，令牌与主机、指纹绑定，
      // 必须按官方下发顺序直接用第一条，不能挑海外候选或改写主机（v0.1.8 教训）。
      _onOpenMedia(
        VideoUtils.getCdnUrl(audio.playUrls, nativeOrder: true),
        tokenOrigin: _TokenOrigin.app,
        volume: volume,
      );
      return true;
    } else if (playInfo.hasPlayUrl()) {
      final playUrl = playInfo.playUrl;
      final durls = playUrl.durl;
      if (durls.isEmpty) {
        SmartDialog.showToast(uiTx('音频取流失败：未返回音频地址'));
        return false;
      }
      final durl = durls.first;
      position.value = 0;
      // durl 是单文件、不可再切音质，清空轨道列表让面板回到不可选状态。
      _audios = const [];
      availableAudioQualities.clear();
      _onOpenMedia(
        VideoUtils.getCdnUrl(durl.playUrls, nativeOrder: true),
        tokenOrigin: _TokenOrigin.app,
        volume: volume,
      );
      return true;
    }
    SmartDialog.showToast(uiTx('音频取流失败：返回格式不受支持'));
    return false;
  }

  /// 在可用轨道里挑不高于 [target] 的最高音质；全都高于 [target] 时退到全局兜底
  /// （[IterableExt.findClosestTarget] 内部 `?? reduce`），不会返回空。
  DashItem _pickAudioTrack(int target) {
    return _audios.findClosestTarget(
      (e) => e.id <= target,
      (a, b) => a.id > b.id ? a : b,
    );
  }

  /// 依据当前这批轨道刷新可切换的音质列表（UI 读它决定显示哪几档）。
  void _refreshAvailableQualities() {
    final ids = _audios.map((e) => e.id).toSet();
    final list = AudioQuality.values.where((e) => ids.contains(e.code)).toList()
      ..sort((a, b) => b.code.compareTo(a.code));
    availableAudioQualities.value = list;
    // 预设为最高可用档，与官方「进页面即给最好音质」一致；用户改过则沿用。
    if (list.isNotEmpty) {
      final want = Pref.defaultAudioQa;
      currentAudioQa.value = list.firstWhere(
        (e) => e.code == want,
        orElse: () => list.first,
      );
    }
  }

  bool get canSwitchAudioQa => availableAudioQualities.length > 1;

  /// 切换音质：在同一批 DASH 轨道里换一条重播，保持播放位置。
  ///
  /// 官方听视频的音质切换同样只换轨道、不重新取流。切换后保留当前进度，
  /// 避免每次切音质都从头开始。
  Future<void> setAudioQa(AudioQuality qa) async {
    if (qa == currentAudioQa.value) return;
    if (_audios.isEmpty) {
      SmartDialog.showToast(uiTx('当前音源不支持切换音质'));
      return;
    }
    final track = _audios.where((e) => e.id == qa.code).firstOrNull;
    if (track == null) {
      SmartDialog.showToast(uiTx('该音质不可用'));
      return;
    }
    final resumeAt = position.value;
    currentAudioQa.value = qa;
    Pref.setDefaultAudioQuality(qa);
    await _onOpenMedia(
      VideoUtils.getCdnUrl(track.playUrls, nativeOrder: true),
      tokenOrigin: _tokenOrigin,
    );
    if (resumeAt > 0) {
      // 不同音质轨的时长可能有微小差异，seek 前确认媒体已就绪
      await Future.delayed(const Duration(milliseconds: 200));
      onSeek(Duration(seconds: resumeAt));
    }
  }

  Future<void> _onOpenMedia(
    String url, {
    _TokenOrigin tokenOrigin = _TokenOrigin.app,
    http_model.Volume? volume,
  }) async {
    await _initPlayerIfNeeded();
    final extras = audioFilterExtras(volume);
    _tokenOrigin = tokenOrigin;
    final isApp = tokenOrigin == _TokenOrigin.app;
    player
      ?..setMediaHeader(
        // APP 令牌用官方 APP 的 UA；Web 令牌用 Safari UA——upos 的海外主机
        // （upos-*-mirror*ov）只认 Safari/macOS，其他 UA 一律 403。
        userAgent: isApp ? Constants.userAgent : BrowserUa.pc,
        // mpv 无法清除 referer 选项，所以 APP 令牌这里传空字符串而不是 null：
        // 空值等于「不发 Referer」，正是 APP 同源直链要求的指纹。
        referer: isApp ? '' : HttpString.baseUrl,
      )
      ..open(Media(url, start: _start, extras: extras));
    _start = null;
  }

  Future<void> _initPlayerIfNeeded() async {
    if (_hasInit) return;
    _hasInit = true;
    assert(player == null, _subscriptions = null);
    player = await Player.create(
      configuration: PlayerConfiguration(
        options: {
          if (Platform.isAndroid) 'ao': Pref.audioOutput,
          'volume': PlatformUtils.isDesktop
              ? (desktopVolume.value * 100).toString()
              : (Pref.enableAppVolume ? 100.0 : Pref.playerVolume).toString(),
          'volume-max': kMaxVolume.toString(),
          ...Pref.initBuffer(),
        },
      ),
    );
    if (isClosed) {
      player!.dispose();
      player = null;
      return;
    }
    final stream = player!.stream;
    _subscriptions = [
      stream.position.listen((position) {
        if (isDragging) return;
        final seconds = position.inSeconds;
        if (seconds != this.position.value) {
          this.position.value = seconds;
          _videoDetailController?.playedTime = position;
          videoPlayerServiceHandler?.onPositionChange(position);
        }
      }),
      stream.duration.listen((duration) {
        this.duration.value = duration.inSeconds;
      }),
      stream.playing.listen((playing) {
        final PlayerStatus playerStatus;
        if (playing) {
          animController.forward();
          playerStatus = PlayerStatus.playing;
        } else {
          animController.reverse();
          playerStatus = PlayerStatus.paused;
        }
        videoPlayerServiceHandler?.onStatusChange(playerStatus, false, false);
      }),
      stream.completed.listen((completed) {
        // completed:false 是 seek 之后库主动发出的"离开完成态"事件，不能当作
        // "本集播完"去上报状态，否则每次循环/拖动都会把媒体会话刷成已完成。
        if (!completed) {
          return;
        }
        _videoDetailController?.playedTime = player!.state.duration;
        videoPlayerServiceHandler?.onStatusChange(
          PlayerStatus.completed,
          false,
          false,
        );
        if (shutdownTimerService.isWaiting) {
          shutdownTimerService.handleWaiting();
        } else {
          switch (playMode.value) {
            case PlayRepeat.pause:
              break;
            case PlayRepeat.listOrder:
              playNext(nextPart: true);
              break;
            case PlayRepeat.singleCycle:
              _restartFromBeginning();
              break;
            case PlayRepeat.listCycle:
              if (!playNext(nextPart: true)) {
                if (index != null && index != 0 && playlist != null) {
                  playIndex(0);
                } else {
                  _restartFromBeginning();
                }
              }
              break;
            case PlayRepeat.autoPlayRelated:
              break;
          }
        }
      }),
    ];
  }

  @override
  Future<void> actionLikeVideo() async {
    if (!isLogin) {
      SmartDialog.showToast(uiTx('账号未登录'));
      return;
    }
    final newVal = !hasLike.value;
    final res = await AudioGrpc.audioThumbUp(
      oid: oid,
      subId: subId,
      itemType: itemType,
      type: newVal
          ? ThumbUpReq_ThumbType.LIKE
          : ThumbUpReq_ThumbType.CANCEL_LIKE,
    );
    if (res case Success(:final response)) {
      hasLike.value = newVal;
      try {
        audioItem.value!.stat
          ..hasLike_7 = newVal
          ..like += newVal ? 1 : -1;
        audioItem.refresh();
      } catch (_) {}
      SmartDialog.showToast(response.message);
    } else {
      res.toast();
    }
  }

  @override
  Future<void> actionTriple() async {
    if (!isLogin) {
      SmartDialog.showToast(uiTx('账号未登录'));
      return;
    }
    final res = await AudioGrpc.audioTripleLike(
      oid: oid,
      subId: subId,
      itemType: itemType,
    );
    if (res case Success(:final response)) {
      hasLike.value = true;
      if (response.coinOk && !hasCoin) {
        coinNum.value = 2;
        GlobalData().afterCoin(2);
        try {
          audioItem.value!.stat
            ..hasCoin_8 = true
            ..coin += 2;
          audioItem.refresh();
        } catch (_) {}
      }
      hasFav.value = true;
      if (!hasCoin) {
        SmartDialog.showToast(uiTx('投币失败'));
      } else {
        SmartDialog.showToast(uiTx('三连成功'));
      }
    } else {
      res.toast();
    }
  }

  @override
  int get copyright => audioItem.value?.arc.copyright ?? 1;

  @override
  Future<void> onPayCoin(int coin, bool coinWithLike) async {
    final res = await AudioGrpc.audioCoinAdd(
      oid: oid,
      subId: subId,
      itemType: itemType,
      num: coin,
      thumbUp: coinWithLike,
    );
    if (res.isSuccess) {
      final updateLike = !hasLike.value && coinWithLike;
      if (updateLike) {
        hasLike.value = true;
      }
      coinNum.value += coin;
      try {
        final stat = audioItem.value!.stat
          ..hasCoin_8 = true
          ..coin += coin;
        if (updateLike) {
          stat
            ..hasLike_7 = true
            ..like += 1;
        }
        audioItem.refresh();
      } catch (_) {}
      GlobalData().afterCoin(coin);
    } else {
      res.toast();
    }
  }

  @override
  void showFavBottomSheet(BuildContext context, {bool isLongPress = false}) {
    if (!isLogin) {
      SmartDialog.showToast(uiTx('账号未登录'));
      return;
    }
    if (enableQuickFav) {
      if (!isLongPress) {
        actionFavVideo(isQuick: true);
      } else {
        PageUtils.showFavBottomSheet(context: context, ctr: this);
      }
    } else if (!isLongPress) {
      PageUtils.showFavBottomSheet(context: context, ctr: this);
    }
  }

  void showReply() {
    MainReplyPage.toMainReplyPage(
      oid: oid.toInt(),
      replyType: isUgc ? 1 : 14,
      heroTag: heroTag,
    );
  }

  void actionShareVideo(BuildContext context) {
    final audioUrl = isUgc
        ? '${HttpString.baseUrl}/video/${IdUtils.av2bv(oid.toInt())}'
        : '${HttpString.baseUrl}/audio/au$oid';
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        clipBehavior: Clip.hardEdge,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          DialogOption(
            child: Text(uiTx('复制链接'), style: TextStyle(fontSize: 14)),
            onPressed: () {
              Get.back();
              Utils.copyText(audioUrl);
            },
          ),
          DialogOption(
            child: Text(uiTx('其它app打开'), style: TextStyle(fontSize: 14)),
            onPressed: () {
              Get.back();
              PageUtils.launchURL(audioUrl);
            },
          ),
          DialogOption(
            child: Text(uiTx('分享视频'), style: TextStyle(fontSize: 14)),
            onPressed: () {
              Get.back();
              if (audioItem.value case DetailItem(:final arc, :final owner)) {
                ShareUtils.shareText(
                  '${arc.title} '
                  'UP主: ${owner.name}'
                  ' - $audioUrl',
                );
              }
            },
          ),
          if (isLogin)
            DialogOption(
              child: Text(uiTx('分享至动态'), style: TextStyle(fontSize: 14)),
              onPressed: () {
                Get.back();
                if (audioItem.value case DetailItem(:final arc, :final owner)) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    builder: (context) => RepostPanel(
                      rid: oid.toInt(),
                      dynType: isUgc ? 8 : 256,
                      pic: arc.cover,
                      title: arc.title,
                      uname: owner.name,
                    ),
                  );
                }
              },
            ),
          if (isUgc && isLogin)
            DialogOption(
              child: Text(uiTx('分享至消息'), style: TextStyle(fontSize: 14)),
              onPressed: () {
                Get.back();
                if (audioItem.value case DetailItem(:final arc, :final owner)) {
                  try {
                    PageUtils.pmShare(
                      context,
                      content: {
                        "id": oid.toString(),
                        "title": arc.title,
                        "headline": arc.title,
                        "source": 5,
                        "thumb": arc.cover,
                        "author": owner.name,
                        "author_id": owner.mid.toString(),
                      },
                    );
                  } catch (e) {
                    SmartDialog.showToast(e.toString());
                  }
                }
              },
            ),
        ],
      ),
    );
  }

  Future<void>? playOrPause() {
    return player?.playOrPause();
  }

  bool playPrev() {
    if (index != null && playlist != null && player != null) {
      final prev = index! - 1;
      if (prev >= 0) {
        playIndex(prev);
        return true;
      }
    }
    return false;
  }

  bool playNext({bool nextPart = false}) {
    if (nextPart) {
      if (audioItem.value case DetailItem(:final parts)) {
        if (parts.length > 1) {
          final subId = this.subId.firstOrNull;
          final nextIndex = parts.indexWhere((e) => e.subId == subId) + 1;
          if (nextIndex != 0 && nextIndex < parts.length) {
            final nextPart = parts[nextIndex];
            oid = nextPart.oid;
            this.subId = [nextPart.subId];
            _queryPlayUrl().then((res) {
              if (res) {
                _videoDetailController = null;
              }
            });
            return true;
          }
        }
      }
    }
    if (index != null && playlist != null && player != null) {
      final next = index! + 1;
      if (next < playlist!.length) {
        if (next == playlist!.length - 1 && _next != null) {
          _queryPlayList(isLoadNext: true);
        }
        playIndex(next);
        return true;
      }
    }
    return false;
  }

  void playIndex(int index, {List<Int64>? subId}) {
    if (index == this.index && subId == null) return;
    this.index = index;
    final audioItem = playlist![index];
    final item = audioItem.item;
    oid = item.oid;
    this.subId =
        subId ??
        (item.subId.isNotEmpty ? item.subId : [audioItem.parts.first.subId]);
    itemType = item.itemType;
    _queryPlayUrl().then((res) {
      if (res) {
        _videoDetailController = null;
        _updateCurrItem(audioItem);
      }
    });
  }

  void setSpeed(double speed) {
    if (player case final player?) {
      this.speed = speed;
      player.setRate(speed);
    }
  }

  @override
  (Object, int) get getFavRidType => (oid, isUgc ? 2 : 12);

  @override
  void updateFavCount(int count) {
    try {
      audioItem.value!.stat
        ..hasFav = count > 0
        ..favourite += count;
      audioItem.refresh();
    } catch (_) {}
  }

  Future<void> loadPrev(BuildContext context) async {
    if (_prev == null) return;
    final length = playlist!.length;
    await _queryPlayList(isLoadPrev: true);
    if (length != playlist!.length && context.mounted) {
      (context as Element).markNeedsBuild();
    }
  }

  Future<void> loadNext(BuildContext context) async {
    if (_next == null) return;
    final length = playlist!.length;
    await _queryPlayList(isLoadNext: true);
    if (length != playlist!.length && context.mounted) {
      (context as Element).markNeedsBuild();
    }
  }

  void onChangeOrder(ListOrder value) {
    if (order != value) {
      order = value;
      _queryPlayList(isInit: true);
    }
  }

  @override
  BlockConfigMixin get blockConfig => this;

  @override
  int get currPosInMilliseconds => player?.state.position.inMilliseconds ?? 0;

  @override
  int? get timeLength => player?.state.duration.inMilliseconds ?? 0;

  @override
  Future<void>? seekTo(Duration duration, {required bool isSeek}) =>
      onSeek(duration);

  @override
  bool get autoPlay => true;

  @override
  bool get preInitPlayer => true;

  @override
  void onClose() {
    shutdownTimerService
      ..onPause = null
      ..isPlaying = null
      ..reset();
    videoPlayerServiceHandler
      ?..onPlay = null
      ..onPause = null
      ..onSeek = null
      ..onVideoDetailDispose(heroTag);
    _subscriptions?.forEach((e) => e.cancel());
    _subscriptions?.clear();
    _subscriptions = null;
    player?.dispose();
    player = null;
    animController.dispose();
    super.onClose();
  }
}

/// 直链令牌的签发来源，决定媒体请求指纹。见 [_TokenOrigin] 的说明。
enum _TokenOrigin {
  /// 官方 APP 同源直链（gRPC `Listener/PlayURL` 或 `PlayView`）。
  app,

  /// Web 令牌（`/x/player/wbi/playurl`）。
  web,
}

extension on DashItem {
  Iterable<String> get playUrls sync* {
    yield baseUrl;
    yield* backupUrl;
  }
}

extension on ResponseUrl {
  Iterable<String> get playUrls sync* {
    yield url;
    yield* backupUrl;
  }
}
