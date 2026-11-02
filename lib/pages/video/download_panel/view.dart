import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:PiliPlus/common/widgets/cover_translate_button.dart';
import 'package:PiliPlus/common/assets.dart';
import 'package:PiliPlus/common/style.dart';
import 'package:PiliPlus/common/widgets/badge.dart';
import 'package:PiliPlus/common/widgets/dialog/dialog.dart';
import 'package:PiliPlus/common/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/common/widgets/stat/stat.dart';
import 'package:PiliPlus/models/common/badge_type.dart';
import 'package:PiliPlus/models/common/stat_type.dart';
import 'package:PiliPlus/models/common/video/audio_quality.dart';
import 'package:PiliPlus/models/common/video/video_quality.dart';
import 'package:PiliPlus/models_new/pgc/pgc_info_model/episode.dart' as pgc;
import 'package:PiliPlus/models_new/pgc/pgc_info_model/result.dart';
import 'package:PiliPlus/models_new/video/video_detail/data.dart';
import 'package:PiliPlus/models_new/video/video_detail/episode.dart' as ugc;
import 'package:PiliPlus/models_new/video/video_detail/page.dart';
import 'package:PiliPlus/pages/download/view.dart';
import 'package:PiliPlus/pages/video/controller.dart';
import 'package:PiliPlus/pages/video/introduction/ugc/controller.dart';
import 'package:PiliPlus/pages/video/introduction/ugc/widgets/page.dart';
import 'package:PiliPlus/services/download/download_service.dart';
import 'package:PiliPlus/services/download/audio_cache_service.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:PiliPlus/utils/date_utils.dart';
import 'package:PiliPlus/utils/duration_utils.dart';
import 'package:PiliPlus/utils/extension/num_ext.dart';
import 'package:PiliPlus/utils/id_utils.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kReleaseMode;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class DownloadPanel extends StatefulWidget {
  const DownloadPanel({
    super.key,
    required this.index,
    this.pgcItem,
    this.videoDetail,
    required this.episodes,
    required this.scrollController,
    required this.videoDetailController,
    required this.heroTag,
    this.ugcIntroController,
    required this.cidSet,
    this.isAudio = false,
  });

  final int index;
  final PgcInfoModel? pgcItem;
  final VideoDetailData? videoDetail;
  final List<ugc.BaseEpisodeItem> episodes;
  final ScrollController scrollController;
  final VideoDetailController videoDetailController;
  final String heroTag;
  final UgcIntroController? ugcIntroController;
  final Set<int> cidSet;

  /// 这个面板是「缓存视频」还是「缓存音频」。
  ///
  /// 它决定三件事：默认落到哪个音质档位、点条目时真正执行哪种缓存、
  /// 以及「查看缓存」跳到哪个模块。
  final bool isAudio;

  @override
  State<DownloadPanel> createState() => _DownloadPanelState();
}

class _DownloadPanelState extends State<DownloadPanel> {
  final DownloadService _downloadService = Get.find<DownloadService>();
  final AudioCacheService _audioCacheService = Get.find<AudioCacheService>();
  final ListController _listController = ListController();

  late final cidSet = widget.cidSet;
  VideoQuality _quality = VideoQuality.fromCode(Pref.defaultVideoQa);
  AudioQuality _audioQuality = AudioQuality.fromCode(Pref.defaultAudioQa);

  late ColorScheme colorScheme;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    colorScheme = .of(context);
  }

  ({String title, String sourceKey})? get _autoFolderInfo {
    final ugcSeason = widget.videoDetail?.ugcSeason;
    final title = ugcSeason?.title?.trim();
    final seasonId = ugcSeason?.id;
    if (title == null || title.isEmpty || seasonId == null) {
      return null;
    }
    return (
      title: title,
      sourceKey: 'ugc-season:$seasonId',
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.index != -1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _listController.jumpToItem(
          index: widget.index,
          scrollController: widget.scrollController,
          alignment: 0,
        );
      });
    }
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dividerColor = colorScheme.outline.withValues(alpha: 0.2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildHeader(),
        _buildBody(),
        Divider(height: 1, color: dividerColor),
        _buildFooter(dividerColor),
      ],
    );
  }

  Widget _buildHeader() {
    final textStyle = TextStyle(color: colorScheme.onSurfaceVariant);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 0, 12),
      child: Row(
        children: [
          Expanded(
            child: Row(
              spacing: 12,
              children: [
                // 音频缓存面板不显示视频画质：这个面板只产出音频，
                // 留着画质选择只会误导（用户以为选的画质决定了缓存内容）。
                if (!widget.isAudio) ...[
                  Text(uiTx('画质'), style: textStyle),
                  Builder(
                    builder: (context) => PopupMenuButton<VideoQuality>(
                      initialValue: _quality,
                      onSelected: (value) {
                        _quality = value;
                        (context as Element).markNeedsBuild();
                      },
                      itemBuilder: (context) => VideoQuality.values
                          .map(
                            (e) => PopupMenuItem(
                              value: e,
                              child: Text(uiTx(e.desc)),
                            ),
                          )
                          .toList(),
                      child: _buildPopupMenuChild(_quality.desc),
                    ),
                  ),
                ],
                Text(uiTx('音质'), style: textStyle),
                Builder(
                  builder: (context) => PopupMenuButton<AudioQuality>(
                    initialValue: _audioQuality,
                    onSelected: (value) {
                      _audioQuality = value;
                      (context as Element).markNeedsBuild();
                    },
                    itemBuilder: (context) => AudioQuality.values
                        .map(
                          (e) => PopupMenuItem(
                            value: e,
                            child: Text(uiTx(e.desc)),
                          ),
                        )
                        .toList(),
                    child: _buildPopupMenuChild(_audioQuality.desc),
                  ),
                ),
              ],
            ),
          ),
          if (PlatformUtils.isMobile)
            Padding(
              padding: const .only(right: 16),
              child: StreamBuilder(
                stream: Connectivity().onConnectivityChanged,
                builder: (context, snapshot) {
                  if (snapshot.data case final data?) {
                    return Icon(
                      data.contains(ConnectivityResult.wifi)
                          ? Icons.wifi
                          : Icons.signal_cellular_alt,
                      size: 20,
                      color: colorScheme.primary,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            )
          else if (kDebugMode)
            Padding(
              padding: const .only(right: 16),
              child: Icon(
                Icons.wifi,
                size: 20,
                color: colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPopupMenuChild(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(height: 1),
            strutStyle: const StrutStyle(height: 1, leading: 0),
          ),
          Icon(
            size: 18,
            Icons.keyboard_arrow_down,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final episodes = widget.episodes;
    return Expanded(
      child: Material(
        type: MaterialType.transparency,
        child: CustomScrollView(
          controller: widget.scrollController,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 100),
              sliver: SuperSliverList.builder(
                itemCount: episodes.length,
                listController: _listController,
                itemBuilder: (context, index) {
                  final episode = episodes[index];
                  final hasParts =
                      episode is ugc.EpisodeItem && episode.pages!.length > 1;
                  Widget child = _buildItem(
                    index: index,
                    hasParts: hasParts,
                    episode: episode,
                    isCurrentIndex: index == widget.index,
                  );
                  if (hasParts) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        child,
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          child: PagesPanel(
                            list: episode.pages,
                            cover: episode.arc?.pic,
                            heroTag: widget.heroTag,
                            ugcIntroController: widget.ugcIntroController!,
                            bvid: episode.bvid ?? IdUtils.av2bv(episode.aid!),
                            cidSet: cidSet,
                            onDownload: (Part part) => _onDownload(
                              index: index,
                              episode: part,
                              parent: episode,
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return child;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 该 cid 在本面板对应的模块里是否已缓存。
  ///
  /// 音频与视频是两套独立的落盘记录：视频看下载服务的 cidSet，
  /// 音频看 [AudioCacheService.audioList]。混用会让「已经在缓存视频」
  /// 误判成「音频也缓存好了」。
  bool _isCachedCid(int? cid) {
    if (cid == null) return false;
    return widget.isAudio
        ? _audioCacheService.isCached(cid)
        : cidSet.contains(cid);
  }

  /// 缓存音频：与「听视频」页共用 [AudioCacheService]，产出的是纯音频文件。
  ///
  /// 音质用面板顶部选的 [_audioQuality]；重复与并发由服务内部的
  /// isCached / taskOf 判断（会自行提示「已缓存 / 正在缓存」），
  /// 所以这里不走视频那边的 cidSet。
  bool _onAudioCache({
    required ugc.BaseEpisodeItem episode,
    ugc.EpisodeItem? parent,
  }) {
    final cid = episode.cid;
    if (cid == null) return false;
    final detail = widget.videoDetail;
    late final int avid;
    late final String bvid;
    late final String title;
    late final String cover;
    int durationMs = 0;

    switch (episode) {
      case Part part:
        // 分P属于某个分集时，aid/bvid/封面以分集为准
        // （合集里每一集是独立稿件，用外层 videoDetail 会串成同一个视频）。
        avid = parent?.aid ?? detail?.aid ?? widget.videoDetailController.aid;
        bvid =
            parent?.bvid ??
            detail?.bvid ??
            widget.videoDetailController.bvid;
        title = part.part ?? detail?.title ?? '';
        cover = part.firstFrame ?? parent?.arc?.pic ?? detail?.pic ?? '';
        durationMs = (part.duration ?? 0) * 1000;
        break;
      case ugc.EpisodeItem item:
        avid = item.aid ?? detail?.aid ?? widget.videoDetailController.aid;
        bvid =
            item.bvid ??
            detail?.bvid ??
            widget.videoDetailController.bvid;
        title = item.title ?? detail?.title ?? '';
        cover = item.arc?.pic ?? detail?.pic ?? '';
        durationMs = (item.arc?.duration ?? 0) * 1000;
        break;
      default:
        // 番剧不提供音频缓存入口（菜单按 isUgc 显示），这里只做兜底。
        return false;
    }

    if (title.isEmpty) {
      SmartDialog.showToast(uiTx('视频信息还没加载好，稍后再试'));
      return false;
    }

    _audioCacheService.download(
      avid: avid,
      bvid: bvid,
      cid: cid,
      title: title,
      cover: cover,
      durationMs: durationMs,
      quality: _audioQuality,
    );
    return true;
  }

  late final int? vipStatus = Pref.userInfoCache?.vipStatus;
  @pragma('vm:notify-debugger-on-exception')
  bool _onDownload({
    required int index,
    required ugc.BaseEpisodeItem episode,
    bool isFromList = false,
    bool isDownloadAll = false,
    ugc.EpisodeItem? parent,
  }) {
    final cid = episode.cid;
    // on download
    if (cid == null) {
      SmartDialog.showToast('null cid');
      return false;
    }

    if (kReleaseMode && episode.badge == '会员' && Accounts.mainEqVideo) {
      if (vipStatus != 1) {
        if (!isDownloadAll) {
          SmartDialog.showToast(uiTx('需要大会员'));
        }
        return false;
      }
    }

    if (episode is ugc.EpisodeItem) {
      final pages = episode.pages!;
      if (pages.length > 1) {
        if (isFromList && kDebugMode) {
          SmartDialog.showToast('hasParts');
        }
        if (isDownloadAll) {
          for (int i = 0; i < pages.length; i++) {
            _onDownload(
              index: i,
              episode: pages[i],
              parent: episode,
            );
          }
          return true;
        }
        // 多分P：让用户往下选具体那一P（音频缓存同样如此，
        // 每个分P的音频是独立的一条记录）。
        return false;
      }
    }

    // 音频缓存走自己的一套落盘结构（与「听视频」页同一个服务），
    // 不能用下面的 video 下载分支。此前面板没有这条分支，`isAudio`
    // 只用于「查看缓存」跳转，于是从视频页点「音频缓存」进去、
    // 点条目时缓存的仍然是视频（用户实测）。
    if (widget.isAudio) {
      return _onAudioCache(episode: episode, parent: parent);
    }

    if (cidSet.contains(cid)) {
      if (kDebugMode) {
        SmartDialog.showToast('downloaded');
      }
      return false;
    }

    try {
      final autoFolderInfo = _autoFolderInfo;
      switch (episode) {
        case Part part:
          _downloadService.downloadVideo(
            index: index,
            page: part,
            videoDetail: parent == null ? widget.videoDetail : null,
            videoArc: parent,
            videoQuality: _quality,
            audioQuality: _audioQuality,
            autoFolderTitle: autoFolderInfo?.title,
            autoFolderSourceKey: autoFolderInfo?.sourceKey,
          );
          break;
        case ugc.EpisodeItem episode:
          _downloadService.downloadVideo(
            index: index,
            page: episode.pages!.first,
            videoDetail: null,
            videoArc: episode,
            videoQuality: _quality,
            audioQuality: _audioQuality,
            autoFolderTitle: autoFolderInfo?.title,
            autoFolderSourceKey: autoFolderInfo?.sourceKey,
          );
          break;
        case pgc.EpisodeItem episode:
          _downloadService.downloadBangumi(
            index: index,
            pgcItem: widget.pgcItem!,
            episode: episode,
            quality: _quality,
            audioQuality: _audioQuality,
          );
          break;
      }
      cidSet.add(cid);
      return true;
    } catch (e, s) {
      Utils.reportError(e, s);
      SmartDialog.showToast(e.toString());
    }
    return false;
  }

  Widget _buildItem({
    required int index,
    required bool hasParts,
    required bool isCurrentIndex,
    required ugc.BaseEpisodeItem episode,
  }) {
    late String title;
    num? duration;
    int? pubdate;
    int? view;
    int? danmaku;
    bool? isCharging;
    int? cid;

    String? cover;
    bool? cacheWidth;

    switch (episode) {
      case Part part:
        cid = part.cid;
        cover = part.firstFrame ?? widget.videoDetail?.pic;
        title = part.part ?? widget.videoDetail!.title!;
        duration = part.duration;
        pubdate = part.ctime;
        cacheWidth = part.dimension?.cacheWidth;
        break;
      case ugc.EpisodeItem item:
        cid = item.cid;
        title = item.title!;
        if (item.arc case final arc?) {
          cover = arc.pic;
          duration = arc.duration;
          pubdate = arc.pubdate;
          if (arc.stat case final stat?) {
            view = stat.view;
            danmaku = stat.danmaku;
          }
          cacheWidth = arc.dimension?.cacheWidth;
        }
        if (item.attribute == 8) {
          isCharging = true;
        }
        break;
      case pgc.EpisodeItem item:
        cid = item.cid;
        title = item.showTitle ?? item.title!;
        cover = item.cover;
        if (item.from == 'pugv') {
          duration = item.duration;
          view = item.play;
        } else {
          duration = item.duration == null ? null : item.duration! ~/ 1000;
        }
        pubdate = item.pubTime;
        cacheWidth = item.dimension?.cacheWidth;
        break;
    }
    late final primary = colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: SizedBox(
        height: 110,
        child: Builder(
          builder: (context) {
            return Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () {
                  if (_onDownload(
                    index: index,
                    episode: episode,
                    isFromList: true,
                  )) {
                    (context as Element).markNeedsBuild();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Style.safeSpace,
                    vertical: 5,
                  ),
                  child: Row(
                    spacing: 10,
                    children: [
                      if (cover?.isNotEmpty == true)
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Stack(children: [
NetworkImgLayer(
                              src: cover,
                              width: 160,
                              height: 100,
                              cacheWidth: cacheWidth,
                            ),
CoverTranslateButton(cover: cover),
]),
                            if (duration != null && duration > 0)
                              PBadge(
                                text: DurationUtils.formatDuration(duration),
                                right: 6.0,
                                bottom: 6.0,
                                type: PBadgeType.gray,
                              ),
                            if (isCharging == true)
                              PBadge(
                                text: uiTx('充电专属'),
                                top: 6,
                                right: 6,
                                type: PBadgeType.error,
                              )
                            else if (episode.badge != null)
                              PBadge(
                                text: uiTx(episode.badge ?? ''),
                                top: 6,
                                right: 6,
                                type: switch (episode.badge) {
                                  '预告' => PBadgeType.gray,
                                  '限免' => PBadgeType.free,
                                  _ => PBadgeType.primary,
                                },
                              ),
                          ],
                        )
                      else if (isCurrentIndex)
                        Image.asset(
                          Assets.livingStatic,
                          color: primary,
                          height: 12,
                          cacheHeight: 12.cacheSize(context),
                          semanticLabel: uiTx('正在播放：'),
                        ),
                      Expanded(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      height: 1.42,
                                      letterSpacing: 0.3,
                                      fontWeight: isCurrentIndex
                                          ? FontWeight.bold
                                          : null,
                                      color: isCurrentIndex ? primary : null,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (pubdate != null)
                                  Text(
                                    DateFormatUtils.format(pubdate),
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 12,
                                      height: 1,
                                      color: colorScheme.outline,
                                      overflow: TextOverflow.clip,
                                    ),
                                  ),
                                const SizedBox(height: 2),
                                Row(
                                  spacing: 8,
                                  children: [
                                    if (view != null)
                                      StatWidget(
                                        value: view,
                                        type: StatType.play,
                                      ),
                                    if (danmaku != null)
                                      StatWidget(
                                        value: danmaku,
                                        type: StatType.danmaku,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            if (!hasParts && _isCachedCid(cid))
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Icon(
                                  size: 13,
                                  color: colorScheme.secondary.withValues(
                                    alpha: 0.8,
                                  ),
                                  FontAwesomeIcons.circleDown,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFooter(Color dividerColor) {
    return Ink(
      color: colorScheme.surfaceContainer,
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: Row(
        children: [
          _buildBottomBtn(
            text: uiTx('缓存全部'),
            onTap: () {
              showConfirmDialog(
                context: context,
                title: Text(uiTx('确定缓存全部？')),
                onConfirm: () {
                  for (int i = 0; i < widget.episodes.length; i++) {
                    _onDownload(
                      index: i,
                      episode: widget.episodes[i],
                      isDownloadAll: true,
                    );
                  }
                  if (mounted) setState(() {});
                },
              );
            },
          ),
          SizedBox(
            height: 20,
            child: VerticalDivider(
              width: 1,
              color: dividerColor,
            ),
          ),
          _buildBottomBtn(
            text: uiTx('查看缓存'),
            onTap: () => Navigator.of(context).push(
              GetPageRoute(
                page: () => DownloadPage(
                  initialCacheModule: widget.isAudio ? 1 : 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBtn({
    required String text,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 40,
          width: double.infinity,
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
