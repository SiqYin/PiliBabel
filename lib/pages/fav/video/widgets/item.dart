import 'package:PiliPlus/common/style.dart';
import 'package:PiliPlus/common/widgets/image/image_save.dart';
import 'package:PiliPlus/common/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/models_new/fav/fav_folder/list.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:PiliPlus/utils/bili_utils.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

class FavVideoItem extends StatelessWidget {
  final String heroTag;
  final FavFolderInfo item;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const FavVideoItem({
    super.key,
    this.onTap,
    this.onLongPress,
    required this.heroTag,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        onLongPress:
            onLongPress ??
            (onTap == null
                ? null
                : () => imageSaveDialog(
                    title: item.title,
                    cover: item.cover,
                  )),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: Style.aspectRatio,
                child: LayoutBuilder(
                  builder: (context, boxConstraints) {
                    return Hero(
                      tag: heroTag,
                      child: NetworkImgLayer(
                        src: item.cover,
                        width: boxConstraints.maxWidth,
                        height: boxConstraints.maxHeight,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              content(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget content(BuildContext context) {
    final theme = Theme.of(context);
    final fontSize = theme.textTheme.labelMedium!.fontSize;
    final color = theme.colorScheme.outline;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () {
              UiTranslateService.to.revision.value;
              return Text(
                uiTx(item.title),
                textAlign: TextAlign.start,
                style: const TextStyle(
                  letterSpacing: 0.3,
                ),
              );
            },
          ),
          if (item.intro?.isNotEmpty == true)
            Obx(
              () {
                UiTranslateService.to.revision.value;
                return Text(
                  uiTx(item.intro!),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: fontSize,
                    color: color,
                  ),
                );
              },
            ),
          Obx(
            () {
              UiTranslateService.to.revision.value;
              return Text(
                '${item.mediaCount}${uiTx('个内容')}',
                style: TextStyle(
                  fontSize: fontSize,
                  color: color,
                ),
              );
            },
          ),
          const Spacer(),
          Obx(
            () {
              UiTranslateService.to.revision.value;
              return Text(
                uiTx(BiliUtils.isPublicFavText(item.attr)),
                style: TextStyle(
                  fontSize: fontSize,
                  color: color,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
