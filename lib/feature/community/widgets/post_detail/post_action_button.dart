import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inninglog/shared/theme/app_text_styles.dart';

class PostActionButton extends StatelessWidget {
  final String asset;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final double iconSize;

  const PostActionButton({
    super.key,
    required this.asset,
    required this.label,
    required this.color,
    required this.onTap,
    this.iconSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          asset,
          width: iconSize,
          height: iconSize,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.headHead8Sb.copyWith(color: color)),
      ],
    );

    if (onTap == null) return content;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: content,
      ),
    );
  }
}
