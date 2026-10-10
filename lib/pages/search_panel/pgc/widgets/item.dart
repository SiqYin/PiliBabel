import 'package:PiliPlus/common/style.dart';
import 'package:PiliPlus/common/widgets/badge.dart';
import 'package:PiliPlus/common/widgets/image/image_save.dart';
import 'package:PiliPlus/common/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/models/search/result.dart';
import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';
import 'package:PiliPlus/utils/date_utils.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

class SearchPgcItem extends StatelessWidget {
  const SearchPgcItem({
    super.key,
    required this.item,
  });

  final SearchPgcItemModel item;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    const TextStyle style = TextStyle(fontSize: 13);
    void onLongPress() => imageSaveDialog(
      title: item.title.map((item) => item.text).join(),
      cover: item.cover,
    );
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => PageUtils.viewPgc(seasonId: item.seasonId),
        onLongPress: onLongPress,
        onSecondaryTap: PlatformUtils.isMobile ? null : onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Style.safeSpace,
            vertical: Style.cardSpace,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  NetworkImgLayer(
                    width: 111,
                    height: 148,
                    src: item.cover,
                  ),
                  PBadge(
                    text: item.seasonTypeName,
                    top: 6.0,
                    right: 4.0,
                    bottom: null,
                    left: null,
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Obx(
                      () => UiTranslateService.contentTranslationActive()
                          // 搜索结果标题带 <em> 高亮分段，逐段翻译会译得支离破碎；
                          // 界面翻译开启时整句走 uiTx，用高亮换取完整译文。
                          ? Text(uiTx(item.title.map((e) => e.text).join()))
                          : Text.rich(
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
                    const SizedBox(height: 12),
                    Text(uiTxP('评分:{0}', [item.mediaScore?['score']]), style: style),
                    Row(
                      children: [
                        if (item.areas?.isNotEmpty == true)
                          Text(item.areas!, style: style),
                        const SizedBox(width: 3),
                        const Text('·'),
                        const SizedBox(width: 3),
                        Text(
                          DateFormatUtils.dateFormat(item.pubtime),
                          style: style,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (item.styles?.isNotEmpty == true)
                          Text(item.styles!, style: style),
                        const SizedBox(width: 3),
                        const Text('·'),
                        const SizedBox(width: 3),
                        if (item.indexShow?.isNotEmpty == true)
                          Text(item.indexShow!, style: style),
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
