import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inninglog/shared/theme/app_colors.dart';

// ---------- public components ----------

class LikeCount extends StatelessWidget {
  final int count;
  final Color color;
  const LikeCount({
    required this.count,
    this.color = AppColors.primary700,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return _IconCount(
      assetPath: 'assets/icons/green_heart.svg',
      count: count,
      color: color,
      iconWidth: 12.3,
      iconHeight: 10.44,
    );
  }
}

class CommentCount extends StatelessWidget {
  final int count;
  final Color color;
  const CommentCount({
    required this.count,
    this.color = AppColors.primary700,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return _IconCount(
      assetPath: 'assets/icons/green_comment.svg',
      count: count,
      color: color,
      iconWidth: 14,
      iconHeight: 14.4,
    );
  }
}

class ScrapCount extends StatelessWidget {
  final int count;
  final Color color;
  const ScrapCount({
    required this.count,
    this.color = AppColors.primary700,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return _IconCount(
      assetPath: 'assets/icons/green_bookmark.svg',
      count: count,
      color: color,
      iconWidth: 12.8,
      iconHeight: 14,
    );
  }
}

// ---------- private base ----------

class _IconCount extends StatelessWidget {
  final String assetPath;
  final int count;
  final Color color;
  final double iconWidth;
  final double iconHeight;
  final double gap;

  const _IconCount({
    required this.assetPath,
    required this.count,
    required this.color,
    required this.iconWidth,
    required this.iconHeight,
    this.gap = 4,
  });

  static const TextStyle _baseTextStyle = TextStyle(
    fontSize: 12,
    fontFamily: 'Pretendard',
    fontWeight: FontWeight.w500,
    letterSpacing: -0.12,
    height: 1.5,
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          assetPath,
          width: iconWidth,
          height: iconHeight,
          // 단색 틴트
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
        SizedBox(width: gap),
        Text('$count', style: _baseTextStyle.copyWith(color: color)),
      ],
    );
  }
}
