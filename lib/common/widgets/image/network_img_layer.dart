import 'package:PiliPlus/common/assets.dart';
import 'package:PiliPlus/common/style.dart';
import 'package:PiliPlus/common/widgets/image/retry_network_image.dart';
import 'package:PiliPlus/models/common/image_type.dart';
import 'package:PiliPlus/utils/extension/num_ext.dart';
import 'package:PiliPlus/utils/image_utils.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:material_ui/material_ui.dart';

class NetworkImgLayer extends StatelessWidget {
  const NetworkImgLayer({
    super.key,
    required this.src,
    required this.width,
    required this.height,
    this.type = .def,
    this.fadeOutDuration = const Duration(milliseconds: 120),
    this.fadeInDuration = const Duration(milliseconds: 120),
    this.quality = 1,
    this.borderRadius = Style.mdRadius,
    this.getPlaceHolder,
    this.fit = .cover,
    this.alignment = .center,
    this.cacheWidth,
  });

  final String? src;
  final double width;
  final double height;
  final ImageType type;
  final Duration fadeOutDuration;
  final Duration fadeInDuration;
  final int quality;
  final BorderRadius borderRadius;
  final ValueGetter<Widget>? getPlaceHolder;
  final BoxFit fit;
  final Alignment alignment;
  final bool? cacheWidth;

  static Color? reduceLuxColor = Pref.reduceLuxColor;
  static bool reduce = false;

  @override
  Widget build(BuildContext context) {
    final isEmote = type == ImageType.emote;
    final isAvatar = type == ImageType.avatar;
    if (src?.isNotEmpty == true) {
      Widget child = _buildImage(context, isEmote: isEmote, isAvatar: isAvatar);
      if (isEmote) {
        return child;
      } else if (isAvatar) {
        return ClipOval(child: child);
      } else {
        return ClipRRect(borderRadius: borderRadius, child: child);
      }
    } else {
      return getPlaceHolder?.call() ??
          _placeholder(context, isEmote: isEmote, isAvatar: isAvatar);
    }
  }

  Widget _buildImage(
    BuildContext context, {
    required bool isEmote,
    required bool isAvatar,
  }) {
    int? memCacheWidth, memCacheHeight;
    if (cacheWidth ?? width <= height) {
      memCacheWidth = width.cacheSize(context);
    } else {
      memCacheHeight = height.cacheSize(context);
    }
    // 首载失败自动重试：此前 errorBuilder 直接落回占位图就再也不动，
    // 一张图抖动一次就要用户自己下拉刷新/重进页面才可能出来。
    return RetryNetworkImage(
      imageUrl: ImageUtils.thumbnailUrl(src, quality),
      width: width,
      height: height,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      fit: fit,
      alignment: alignment,
      fadeOutDuration: fadeOutDuration,
      fadeInDuration: fadeInDuration,
      filterQuality: FilterQuality.low,
      placeholder: () =>
          getPlaceHolder?.call() ??
          _placeholder(context, isEmote: isEmote, isAvatar: isAvatar),
      errorPlaceholder: () =>
          getPlaceHolder?.call() ??
          _placeholder(context, isEmote: isEmote, isAvatar: isAvatar),
      colorBlendMode: reduce ? BlendMode.modulate : null,
      color: reduce ? reduceLuxColor : null,
    );
  }

  Widget _placeholder(
    BuildContext context, {
    required bool isEmote,
    required bool isAvatar,
  }) {
    return Container(
      width: width,
      height: height,
      clipBehavior: isEmote ? Clip.none : Clip.antiAlias,
      decoration: BoxDecoration(
        shape: isAvatar ? BoxShape.circle : BoxShape.rectangle,
        color: ColorScheme.of(context).onInverseSurface.withValues(alpha: 0.4),
        borderRadius: isEmote || isAvatar ? null : borderRadius,
      ),
      child: Center(
        child: Image.asset(
          isAvatar ? Assets.avatarPlaceHolder : Assets.loading,
          width: width,
          height: height,
          cacheWidth: width.cacheSize(context),
          colorBlendMode: reduce ? BlendMode.modulate : null,
          color: reduce ? reduceLuxColor : null,
        ),
      ),
    );
  }
}
