import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:PiliPlus/common/style.dart';
import 'package:PiliPlus/common/widgets/badge.dart';
import 'package:PiliPlus/common/widgets/custom_icon.dart';
import 'package:PiliPlus/common/widgets/flutter/popup_menu.dart';
import 'package:PiliPlus/common/widgets/image/image_save.dart';
import 'package:PiliPlus/common/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/common/widgets/stat/stat.dart';
import 'package:PiliPlus/grpc/bilibili/app/interfaces/v1.pb.dart' show Arc;
import 'package:PiliPlus/http/user.dart';
import 'package:PiliPlus/models/common/badge_type.dart';
import 'package:PiliPlus/models/common/stat_type.dart';
import 'package:PiliPlus/utils/date_utils.dart';
import 'package:PiliPlus/utils/duration_utils.dart';
import 'package:PiliPlus/utils/global_data.dart';
import 'package:PiliPlus/utils/em.dart';
import 'package:PiliPlus/utils/extension/dimension_ext.dart';
import 'package:PiliPlus/utils/id_utils.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:fixnum/fixnum.dart' show Int64;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:material_ui/material_ui.dart';

class SearchArchiveGrpc extends StatelessWidget {
  const SearchArchiveGrpc({
    super.key,
    required this.item,
  });

  final Arc item;

  @override
  Widget build(BuildContext context) {
    final arc = item.archive;
    final bvid = IdUtils.av2bv(arc.aid.toInt());
    final regTitle = Em.regTitle(arc.title);
    final titleStr = regTitle.map((e) => e.text).join();
    void onLongPress() => imageSaveDialog(
      bvid: bvid,
      title: titleStr,
      cover: arc.pic,
    );
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          InkWell(
            onLongPress: onLongPress,
            onSecondaryTap: PlatformUtils.isMobile ? null : onLongPress,
            onTap: () {
              if (item.isPugv) {
                PageUtils.viewPgcFromUri(item.uri, isPgc: false);
                return;
              }
              if (arc.hasRedirectUrl()) {
                PageUtils.viewPgcFromUri(arc.redirectUrl);
                return;
              }
              PageUtils.toVideoPage(
                bvid: bvid,
                cid: arc.firstCid.toInt(),
                cover: arc.pic,
                title: titleStr,
                isVertical: arc.dimension.isVertical,
              );
            },
            child: Padding(
              padding: const .symmetric(
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
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            NetworkImgLayer(
                              src: arc.pic,
                              width: maxWidth,
                              height: maxHeight,
                            ),
                            if (item.isPugv)
                              PBadge(
                                text: uiTx('课堂'),
                                top: 6.0,
                                right: 6.0,
                              ),
                 