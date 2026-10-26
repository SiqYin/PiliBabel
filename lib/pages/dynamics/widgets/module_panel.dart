import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:PiliPlus/common/widgets/cover_translate_button.dart';
import 'package:PiliPlus/common/style.dart';
import 'package:PiliPlus/common/widgets/badge.dart';
import 'package:PiliPlus/common/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/grpc/bilibili/app/listener/v1.pbenum.dart'
    show PlaylistSource;
import 'package:PiliPlus/models/dynamics/result.dart';
import 'package:PiliPlus/pages/audio/view.dart';
import 'package:PiliPlus/pages/dynamics/widgets/forward_panel.dart';
import 'package:PiliPlus/pages/dynamics/widgets/live_panel.dart';
import 'package:PiliPlus/pages/dynamics/widgets/live_panel_sub.dart';
import 'package:PiliPlus/pages/dynamics/widgets/live_rcmd_panel.dart';
import 'package:PiliPlus/pages/dynamics/widgets/video_panel.dart';
import 'package:PiliPlus/utils/extension/num_ext.dart';
import 'package:PiliPlus/utils/image_utils.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_ui/material_ui.dart';

Widget noneWidget(ThemeData theme, String? tips) => Row(
  spacing: 5,
  children: [
    Icon(
      Icons.error,
      size: 18,
      color: theme.colorScheme.outline,
    ),
    Text(
      tips ?? '已失效',
      style: TextStyle(color: theme.colorScheme.outline),
    ),
  ],
);

Widget module(
  BuildContext context, {
  required int floor,
  required ThemeData theme,
  required DynamicItemModel item,
  required bool isSave,
  required bool isDetail,
}) {
  final moduleDynamic = item.modules.moduleDynamic;
  final major = moduleDynamic?.major;

  if (major?.type == 'MAJOR_TYPE_NONE') {
    return noneWidget(theme, major?.none?.tips);
  }

  switch (item.type) {
    case 'DYNAMIC_TYPE_NONE':
      return Row(
        spacing: 4,
        children: [
          const Icon(FontAwesomeIcons.ghost, size: 14),
          Text(major!.none!.tips!),
        ],
      );
    // 图文
    case 'DYNAMIC_TYPE_DRAW':
    // 文章
    case 'DYNAMIC_TYPE_ARTICLE':
    case 'DYNAMIC_TYPE_WORD':
      return const SizedBox.shrink();
    // 视频
    case 'DYNAMIC_TYPE_AV':
    case 'DYNAMIC_TYPE_UGC_SEASON':
    case 'DYNAMIC_TYPE_PGC':
    case 'DYNAMIC_TYPE_PGC_UNION':
    case 'DYNAMIC_TYPE_COURSES_SEASON':
      return videoSeasonWidget(
        context,
        theme: theme,
        item: item,
        floor: floor,
        isSave: isSave,
        isDetail: isDetail,
      );
    // 转发
    case 'DYNAMIC_TYPE_FORWARD':
      return forwardPanel(
        context,
        theme: theme,
        isSave: isSave,
        orig: item.orig!,
        isDetail: isDetail,
        floor: floor + 1,
      );
    // 直播
    case 'DYNAMIC_TYPE_LIVE_RCMD':
      return liveRcmdPanel(
        context,
        theme: theme,
        isDetail: isDetail,
        item: item,
        floor: floor,
      );
    // 直播
    case 'DYNAMIC_TYPE_LIVE':
      return livePanel(
        context,
        theme: theme,
        item: item,
        floor: floor,
        isDetail: isDetail,
      );
    // 活动
    case 'DYNAMIC_TYPE_COMMON_SQUARE':
      final common = major?.common ?? major?.upowerCommon;
      if (common == null) return const SizedBox.shrink();
      return Material(
        color: floor == 1
            ? theme.dividerColor.withValues(alpha: 0.08)
            : theme.colorScheme.surface,
        shape: floor == 1
            ? null
            : const RoundedRectangleBorder(borderRadius: Style.mdRadius),
        child: InkWell(
          borderRadius: floor == 1 ? null : Style.mdRadius,
          onTap: () {
            try {
              String url = common.jumpUrl!;
              if (url.contains('bangumi/play') &&
                  PageUtils.viewPgcFromUri(url)) {
                return;
              }
              PageUtils.handleWebview(url, inApp: true);
            } catch (_) {}
          },
          child: Padding(
            padding: const EdgeInsets.only(
              left: 12,
              top: 10,
              right: 12,
              bottom: 10,
            ),
            child: Row(
              spacing: 10,
              children: [
                if (common.cover?.isNotEmpty ?? false)
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                    child: CachedNetworkImage(
                      width: 45,
                      height: 45,
                      fit: BoxFit.cover,
                      memCacheWidth: 45.cacheSize(context),
                      imageUrl: ImageUtils.safeThumbnailUrl(common.cover),
                    ),
                  ),
                Expanded(
                  child: Column(
                    spacing: 2,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${common.titlePrefix ?? ''}${common.title ?? ''}',
                        style: TextStyle(color: theme.colorScheme.primary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (common.desc?.isNotEmpty ?? false)
                        Text(
                          common.desc!,
                          style: TextStyle(
                            color: theme.colorScheme.outline,
                            fontSize: theme.textTheme.labelMedium!.fontSize,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    case 'DYNAMIC_TYPE_MUSIC':
      final music = major!.music!;
      final borderRadius = floor == 1 ? null : Style.mdRadius;
      final Color bgColor = floor == 1
          ? theme.dividerColor.withValues(alpha: 0.08)
          : theme.colorScheme.surface;
      return Material(
        color: bgColor,
        borderRadius: borderRadius,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: () => AudioPage.toAudioPage(
            oid: music.id!,
            itemType: 3,
            from: PlaylistSource.AUDIO_CARD,
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 12,
              top: 10,
              right: 12,
              bottom: 10,
            ),
            child: Row(
              spacing: 10,
              children: [
                Stack(children: [
NetworkImgLayer(
                  width: 45,
                  height: 45,
                  src: music.cover,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
CoverTranslateButton(cover: music.cover),
]),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        uiTx(music.title!),
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        uiTx(music.label!),
                        style: TextStyle(
                          color: theme.colorScheme.outline,
                          fontSize: theme.textTheme.labelMedium!.fontSize,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    case 'DYNAMIC_TYPE_MEDIALIST':
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (floor == 1) const SizedBox(width: 12),
          if (major?.medialist?.cover?.isNotEmpty == true) ...[
            Stack(
              clipBehavior: Clip.none,
              children: [
                Hero(
                  tag: major!.medialist!.cover!,
                  child: Stack(children: [
NetworkImgLayer(
                    width: 180,
                    height: 110,
                    src: major.medialist!.cover,
                  ),
CoverTranslateButton(cover: major.medialist!.cover),
]),
                ),
                PBadge(
                  right: 6,
                  top: 6,
                  text: major.medialist!.badge?.text,
                ),
              ],
            ),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: SizedBox(
              height: 110,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    major!.medialist!.title!,
                    style: TextStyle(
                      fontSize: theme.textTheme.titleMedium!.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (major.medialist?.subTitle != null) ...[
                    const Spacer(),
                    Text(
                      major.medialist!.subTitle!,
                      style: TextStyle(
                        fontSize: theme.textTheme.labelLarge!.fontSize,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (floor == 1) const SizedBox(width: 12),
        ],
      );

    case 'DYNAMIC_TYPE_SUBSCRIPTION_NEW'
        when major?.type == 'MAJOR_TYPE_SUBSCRIPTION_NEW':
      return livePanelSub(
        context,
        theme: theme,
        isDetail: isDetail,
        item: item,
        floor: floor,
      );

    // E4：付费卡、小程序、话题集、订阅卡。四张卡此前整页回退 REST，
    // 现在都按 gRPC 字段自己渲染；没有跳转地址的只做展示，不假装可点。
    case 'DYNAMIC_TYPE_CHARGING':
      final charging = major?.charging;
      if (charging == null) return const SizedBox.shrink();
      return _sideCard(
        context: context,
        theme: theme,
        floor: floor,
        cover: charging.archiveCover,
        coverWidth: 180,
        coverHeight: 110,
        title: charging.archiveTitle,
        subtitle: uiTx('付费内容'),
        onTap: null,
      );

    case 'DYNAMIC_TYPE_APPLET':
      final applet = major?.applet;
      if (applet == null) return const SizedBox.shrink();
      return _sideCard(
        context: context,
        theme: theme,
        floor: floor,
        cover: applet.cover ?? applet.icon,
        coverWidth: 45,
        coverHeight: 45,
        title: applet.title,
        subtitle: applet.subTitle ?? applet.label,
        action: applet.buttonTitle,
        onTap: (applet.uri?.isEmpty ?? true)
            ? null
            : () => PageUtils.handleWebview(applet.uri!, inApp: true),
      );

    case 'DYNAMIC_TYPE_TOPIC_SET':
      final topicSet = major?.topicSet;
      if (topicSet == null) return const SizedBox.shrink();
      final uri = topicSet.uri ?? topicSet.inlineUrl;
      return _sideCard(
        context: context,
        theme: theme,
        floor: floor,
        cover: topicSet.cover,
        coverWidth: 180,
        coverHeight: 110,
        title: topicSet.title,
        subtitle: [
          topicSet.coverLeftText1,
          topicSet.coverLeftText2,
          topicSet.coverLeftText3,
        ].whereType<String>().where((e) => e.isNotEmpty).join(' · '),
        onTap: (uri?.isEmpty ?? true)
            ? null
            : () => PageUtils.handleWebview(uri!, inApp: true),
      );

    case 'DYNAMIC_TYPE_SUBSCRIPTION':
      final subscription = major?.subscription;
      if (subscription == null) return const SizedBox.shrink();
      return _sideCard(
        context: context,
        theme: theme,
        floor: floor,
        cover: subscription.cover,
        coverWidth: 180,
        coverHeight: 110,
        title: subscription.title,
        subtitle: subscription.adTitle ?? subscription.tips,
        onTap: (subscription.uri?.isEmpty ?? true)
            ? null
            : () => PageUtils.handleWebview(subscription.uri!, inApp: true),
      );

    default:
      return Padding(
        padding: floor == 1
            ? const EdgeInsets.symmetric(horizontal: 12)
            : EdgeInsets.zero,
        child: Text(uiTx('暂未支持的类型: \n${item.idStr}\n${item.type}')),
      );
  }
}

/// E4：付费卡 / 小程序 / 话题集 / 订阅卡共用的横排卡片。
/// 结构与既有 COMMON_SQUARE 卡一致：封面 + 标题 + 副标题，
/// 没有跳转地址时 [onTap] 传 null，卡片只做展示。
Widget _sideCard({
  required BuildContext context,
  required ThemeData theme,
  required int floor,
  required String? cover,
  required double coverWidth,
  required double coverHeight,
  required String? title,
  String? subtitle,
  String? action,
  VoidCallback? onTap,
}) {
  final radius = floor == 1 ? null : Style.mdRadius;
  final body = Padding(
    padding: const EdgeInsets.only(left: 12, top: 10, right: 12, bottom: 10),
    child: Row(
      spacing: 10,
      children: [
        if (cover?.isNotEmpty ?? false)
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(6)),
            child: CachedNetworkImage(
              width: coverWidth,
              height: coverHeight,
              fit: BoxFit.cover,
              memCacheWidth: coverWidth.cacheSize(context),
              imageUrl: ImageUtils.safeThumbnailUrl(cover),
            ),
          ),
        Expanded(
          child: Column(
            spacing: 2,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title?.isNotEmpty ?? false)
                Text(
                  uiTx(title!),
                  style: TextStyle(color: theme.colorScheme.primary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              if (subtitle?.isNotEmpty ?? false)
                Text(
                  uiTx(subtitle!),
                  style: TextStyle(
                    color: theme.colorScheme.outline,
                    fontSize: theme.textTheme.labelMedium!.fontSize,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              if (action?.isNotEmpty ?? false)
                Text(
                  uiTx(action!),
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: theme.textTheme.labelMedium!.fontSize,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    ),
  );
  return Material(
    color: floor == 1
        ? theme.dividerColor.withValues(alpha: 0.08)
        : theme.colorScheme.surface,
    borderRadius: radius,
    child: onTap == null
        ? body
        : InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: body,
          ),
  );
}
