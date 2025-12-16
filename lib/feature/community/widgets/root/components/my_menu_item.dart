import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inninglog/shared/theme/app_colors.dart';

class MyMenuItem extends StatelessWidget {
  final Widget leading;
  final String label;
  final double gap;

  const MyMenuItem({
    required this.leading,
    required this.label,
    this.gap = 8,
    super.key,
  });

  static const TextStyle _labelStyle = TextStyle(
    fontSize: 12,
    color: Colors.black,
    fontFamily: 'Pretendard',
    fontWeight: FontWeight.w600,
    letterSpacing: -0.12,
  );

  factory MyMenuItem.emoji({
    required String emoji,
    required String label,
    Color? emojiColor,
    double emojiSize = 12,
    Key? key,
  }) {
    return MyMenuItem(
      key: key,
      leading: Text(
        emoji,
        style: TextStyle(
          fontSize: emojiSize,
          color: emojiColor ?? Colors.black,
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w600,
          letterSpacing: -0.12,
        ),
      ),
      label: label,
    );
  }

  factory MyMenuItem.svg({
    required String svgPath,
    required String label,
    Color iconColor = AppColors.primary700,
    double width = 12,
    double height = 14,
    Key? key,
  }) {
    return MyMenuItem(
      key: key,
      leading: SvgPicture.asset(
        svgPath,
        width: width,
        height: height,
        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      ),
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        leading,
        SizedBox(width: gap),
        Text(label, style: _labelStyle),
      ],
    );
  }
}
