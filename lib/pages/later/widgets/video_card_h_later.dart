import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:PiliPlus/common/style.dart';
import 'package:PiliPlus/common/widgets/badge.dart';
import 'package:PiliPlus/common/widgets/button/icon_button.dart';
import 'package:PiliPlus/common/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/common/widgets/progress_bar/video_progress_indicator.dart';
import 'package:PiliPlus/common/widgets/select_mask.dart';
import 'package:PiliPlus/common/widgets/stat/stat.dart';
import 'package:PiliPlus/http/search.dart';
import 'package:PiliPlus/models/common/badge_type.dart';
import 'package:PiliPlus/models/common/stat_type.dart';
import 'package:PiliPlus/models_new/later/list.dart';
import 'package:PiliPlus/pages/later/controller.dart';
import 'package:PiliPlus/utils/duration_utils.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:material_ui/material_ui.dart';

// 视频卡片 - 水平布局
class VideoCardHLater extends StatelessWidget {
  const VideoCardHLater({
    super.key,
    required this.ctr,
    required this.index,
    required this.videoItem,
    required this.onViewLater,
  });
  final int index;
  final BaseLaterController ctr;
  final LaterItemModel videoItem;
  final ValueChanged<int> onViewLater;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enableMultiSelect = ctr.enableMultiSelect.value;

    final onLongPress = enableMultiSelect
        ? null
        : () => ctr
            ..enableMultiSelect.value = true
            ..onSelect(videoItem);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onLongPress: onLongPress,
        onSecondaryTap: PlatformUtils.isMobile ? null : onLongPress,
        onTap: enableMultiSelect
            ? () => ctr.onSelect(videoItem)
            : () async {
                if (videoItem.isPugv ?? false) {
                  PageUtils.viewPugv(seasonId: videoItem.aid);
                  return;
                }
                if (videoItem.isPgc ?? false) {
                  if (videoItem.bangumi?.epId != null) {
                    PageUtils.viewPgc(epId: videoItem.bangumi!.epId);
                  } else if (videoItem.redirectUrl?.isNotEmpty == true) {
                    PageUtils.viewPgcFromUri(videoItem.redirectUrl!);
                  }
                  return;
                }
                try {
                  final cid =
                      videoItem.cid ??
                      await SearchHttp.ab2c(
                        aid: videoItem.aid,
                        bvid: videoItem.bvid,
                      );
                  if (cid != null) {
                    onViewLater(cid);
                  }
                } catch (err) {
                  SmartDialog.showToast(err.toString());
                }
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Style.safeSpace,
            vertical: 5,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AspectRatio(
                aspectRatio: Style.aspectRatio,
                child: LayoutBuilder(
                  builder: (context, boxConstraints) {
                    final double maxWidth = boxConstraints.maxWidth;
                    final double maxHeight = boxConstraints.maxHeight;
                    num? progress = videoItem.progress;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        NetworkImgLayer(
                          src: videoItem.pic,
                          width: maxWidth,
                          height: maxHeight,
                          cacheWidth: videoItem.dimension?.cacheWidth,
                        ),
                        if (videoItem.isCharging == true)
                          const PBadge(
                            text: uiTx('充电专属'),
                            top: 6.0,
                            right: 6.0,
                            type: PBadgeType.e