import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:PiliPlus/common/widgets/cover_translate_button.dart';
import 'package:PiliPlus/common/style.dart';
import 'package:PiliPlus/common/widgets/image/image_save.dart';
import 'package:PiliPlus/common/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/models/search/result.dart';
import 'package:PiliPlus/utils/date_utils.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

class SearchArticleItem extends StatelessWidget {
  const SearchArticleItem({
    super.key,
    required this.item,
    this.translate = true,
  });

  final SearchArticleItemModel item;

  /// 是否跟随界面翻译翻译标题；搜索结果用中文搜时置 false，按原文显示。
  final bool translate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = TextStyle(
      fontSize: theme.textTheme.labelSmall!.fontSize,
      color: theme.colorScheme.outline,
    );
    void onLongPress() => imageSaveDialog(
      title: item.title.map((item) => item.text).join(),
      cover: item.imageUrls?.firstOrNull,
    );
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => Get.toNamed(
          '/articlePage',
          parameters: {
            'id': '${item.id}',
            'type': 'read',
          },
        ),
        onLongPress: onLongPress,
        onSecondaryTap: PlatformUtils.isMobile ? null : onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Style.safeSpace,
            vertical: 5,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (item.imageUrls?.isNotEmpty == true)
                AspectRatio(
                  aspectRatio: Style.aspectRatio,
                  child: LayoutBuilder(
                    builder: (context, boxConstraints) {
                      double maxWidth = boxConstraints.maxWidth;
                      double maxHeight = boxConstraints.maxHeight;
                      return Stack(children: [
NetworkImgLayer(
                        width: maxWidth,
                        height: maxHeight,
                        src: item.imageUrls?.firstOrNull,
                      ),
CoverTranslateButton(cover: item.imageUrls?.firstOrNull),
]);
                    },
                  ),
                ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => translate && UiTranslateService.contentTranslationActive()
                          // 搜索结果标题带 <em> 高亮分段，逐段翻译会译得支离破碎；
                          // 界面翻译开启时整句走 uiTx，用高亮换取完整译文。
                          ? Text(
                              uiTx(item.title.map((e) => e.text).join()),
                              maxLines: 2,
                            )
                          : Text.rich(
                              maxLines: 2,
                              TextSpan(
                                children: item.title
                                    .map(
                                      (e) => TextSpan(
                                        text: e.text,
                                        style: TextStyle(
                                          color: e.isEm
                                              ? theme.colorScheme.primary
                                              : theme.colorScheme.onSurface,
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormatUtils.dateFormat(item.pubTime),
                      style: textStyle,
                    ),
                    Row(
                      children: [
                        Text(uiTx('${item.view}浏览'), style: textStyle),
                        Text(' • ', style: textStyle),
                        Text(uiTx('${item.reply}评论'), style: textStyle),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
