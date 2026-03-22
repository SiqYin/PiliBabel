import 'package:PiliPlus/common/assets.dart';
import 'package:PiliPlus/common/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/models/common/avatar_badge_type.dart';
import 'package:PiliPlus/models/common/image_type.dart';
import 'package:PiliPlus/utils/extension/num_ext.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:flutter/material.dart';

class PendantAvatar extends StatelessWidget {
  const PendantAvatar(
    this.url, {
    super.key,
    required double size,
    double? badgeSize,
    int? vipStatus,
    int? officialType,
    this.pendantImage,
    this.pendentOffset = 6,
    this.roomId,
    this.onTap,
  }) : preferredSize = size,
       badgeSize = badgeSize ?? size / 3,
       badgeType = officialType == null || officialType < 0
           ? vipStatus != null && vipStatus > 0
                 ? .vip
                 : .none
           : officialType == 0
           ? .person
           : officialType == 1
           ? .institution
           : .none;

  static bool showDynDecorate = Pref.showDynDecorate;

  final BadgeType badgeType;
  final String? url;
  final double preferredSize;
  final double badgeSize;
  final String? pendantImage;
  final double pendentOffset;
  final int? roomId;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final showPendant = showDynDecorate && pendantImage?.isNotEmpty == true;
    final size = showPendant ? preferredSize - pendentOffset : preferredSize;
    Widget? pendant;
    if (showPendant) {
      final pendantSize = size * 1.75;
      pendant = Positioned(
        // -(size * 1.75 - size) / 2
        top: -0.375 * size + pendentOffset,
        child: IgnorePointer(
          child: NetworkImgLayer(
            type: .emote,
            width: pendantSize,
            height: pendantSize,
            src: pendantImage,
            getPlaceHolder: () => const SizedBox.shrink(),
          ),
        ),
      );
    }
    Widget avatar = NetworkImgLayer(
      src: url,
      width: size,
      height: size,
      type: ImageType.avatar,
    );
    if (onTap != null) {
      avatar = GestureDetector(
        behavior: .opaque,
        onTap: onTap,
        child: avatar,
      );
    }
    Widget child = Stack(
      clipBehavior: .none,
      alignment: .center,
      children: [
        avatar,
        ?pendant,
        if (roomId != null)
          Positioned(
            bottom: 0,
            child: InkWell(
              onTap: () => PageUtils.toLiveRoom(roomId),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: const BorderRadius.all(Radius.circular(36)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      size: 16,
                      applyTextScaling: true,
                      Icons.equalizer_rounded,
                      color: colorScheme.onSecondaryContainer,
                    ),
                    Text(
                      '直播中',
                      style: TextStyle(
                        height: 1,
                        fontSize: 13,
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else if (badgeType != BadgeType.none)
          _buildBadge(context, colorScheme),
      ],
    );
    if (showPendant) {
      return SizedBox.square(
        dimension: preferredSize,
        child: child,
      );
    }
    return child;
  }

  Widget _buildBadge(BuildContext context, ColorScheme colorScheme) {
    final child = switch (badgeType) {
      BadgeType.vip => Image.asset(
        Assets.vipIcon,
        width: badgeSize,
        height: badgeSize,
        cacheWidth: badgeSize.cacheSize(context),
        semanticLabel: badgeType.desc,
      ),
      _ => Icon(
        Icons.offline_bolt,
        color: badgeType.color,
        size: badgeSize,
        semanticLabel: badgeType.desc,
      ),
    };
    return Positioned(
      right: 0.0,
      bottom: 0.0,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.surface,
          ),
          child: child,
        ),
      ),
    );
  }
}
