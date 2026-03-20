import 'package:PiliPlus/common/constants.dart';
import 'package:flutter/material.dart';

class MedalWidget extends StatelessWidget {
  const MedalWidget({
    super.key,
    required this.medalName,
    required this.level,
    required this.backgroundColor,
    required this.nameColor,
    required this.levelColor,
  });

  final String medalName;
  final int level;
  final Color backgroundColor;
  final Color nameColor;
  final Color levelColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const .symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: StyleString.mdRadius,
        color: backgroundColor,
      ),
      child: Text.rich(
        strutStyle: const StrutStyle(
          height: 1,
          leading: 0,
          fontSize: 10,
        ),
        TextSpan(
          children: [
            TextSpan(
              text: medalName,
              style: TextStyle(
                height: 1,
                fontSize: 10,
                color: nameColor,
              ),
            ),
            TextSpan(
              text: ' $level',
              style: TextStyle(
                height: 1,
                fontSize: 10,
                fontWeight: .bold,
                color: levelColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
