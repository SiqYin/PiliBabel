import 'package:PiliPlus/common/skeleton/skeleton.dart';
import 'package:PiliPlus/common/style.dart';
import 'package:material_ui/material_ui.dart';

class VideoCardHSkeleton extends StatelessWidget {
  const VideoCardHSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final color = ColorScheme.of(context).onInverseSurface;
    return Skeleton(
      child: Padding(
        padding: const .symmetric(horizontal: Style.safeSpace, vertical: 5),
        child: Row(
          crossAxisAlignment: .start,
          children: [
            // 必须与 VideoCardH 的真实封面同高（100）：
            // 骨架屏在 Row 里用 AspectRatio，宽度是按可用高度反推的；格子高度会随
            // 「标题完全显示」加高，若不钉死高度，加载时就会先闪出一个大尺寸占位块，
            // 等真实卡片出来再缩回正常尺寸。
            SizedBox(
              height: Style.cardHCoverHeight,
              child: AspectRatio(
                aspectRatio: Style.aspectRatio,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: Style.mdRadius,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const .fromLTRB(10, 4, 6, 4),
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Container(
                      color: color,
                      width: 200,
                      height: 13,
                      margin: const .only(bottom: 5),
                    ),
                    Container(
                      color: color,
                      width: 150,
                      height: 13,
                    ),
                    const Spacer(),
                    Container(
                      color: color,
                      width: 100,
                      height: 13,
                      margin: const .only(bottom: 5),
                    ),
                    Row(
                      spacing: 8,
                      children: [
                        Container(
                          color: color,
                          width: 40,
                          height: 13,
                        ),
                        Container(
                          color: color,
                          width: 40,
                          height: 13,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
