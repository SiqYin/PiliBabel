import 'package:PiliPlus/common/assets.dart';
import 'package:PiliPlus/common/style.dart';
import 'package:PiliPlus/common/widgets/badge.dart';
import 'package:PiliPlus/common/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/models/common/badge_type.dart';
import 'package:PiliPlus/models/dynamics/result.dart';
import 'package:PiliPlus/utils/extension/num_ext.dart';
import 'package:material_ui/material_ui.dart';

Widget livePanelSub(
  BuildContext context, {
  required int floor,
  required ThemeData theme,
  required DynamicItemModel item,
  required bool isDetail,
}) {
  LivePlayInfo? live = item
      .modules
      .moduleDynamic!
      .major
      ?.subscriptionNew
      ?.liveRcmd
      ?.content
      ?.livePlayInfo;
  if (live == null) {
    return const SizedBox.shrink();
  }
  EdgeInsets padding;
  if (floor == 1) {
    padding = const EdgeInsets.symmetric(horizontal: 12);
  } else {
    padding = EdgeInsets.zero;
  }
  return Padding(
    padding: padding,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            LayoutBuilder(
              builder: (context, constraints) => NetworkImgLayer(
                width: constraints.maxWidth,
                height: constraints.maxWidth / Style.aspectRatio,
                src: live.cover,
                quality: 40,
              ),
            ),
            PBadge(
              text: live.watchedShow?.textLarge,
              top: 6,
              right: 65,
              fontSize: 10.5,
              type: PBadgeType.gray,
            ),
            if (live.liveStatus == 1)
              Positioned(
                right: 6,
                top: 6,
                child: Image.asset(
                  height: 16,
                  cacheHeight: 16.cacheSize(context),
                  Assets.livingRect,
                  filterQuality: FilterQuality.low,
                ),
              )
            else
              PBadge(
                text: uiTx('直播结束'),
                top: 6,
                right: 6,
              ),
            if (live.areaName case final areaName?)
              Positioned(
     