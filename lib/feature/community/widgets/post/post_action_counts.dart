import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inninglog/shared/theme/app_colors.dart';
import 'package:inninglog/shared/theme/app_text_styles.dart';

// ---------- public components ----------

enum CountVariant { primary, neutral, black }

class LikeCount extends StatelessWidget {
  final int count;
  final CountVariant variant;
  final String? assetPathOverride;
  const LikeCount({
    required this.count,
    this.variant = CountVariant.primary,
    this.assetPathOverride,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return _IconCount(
      assetPath: assetPathOverride ?? 'assets/icons/green_heart.svg',
      count: count,
      variant: variant,
      iconWidth: 12.3,
      iconHeight: 10.44,
    );
  }
}

class CommentCount extends StatelessWidget {
  final int count;
  final CountVariant variant;
  const CommentCount({
    required this.count,
    this.variant = CountVariant.primary,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return _IconCount(
      assetPath: 'assets/icons/green_comment.svg',
      count: count,
      variant: variant,
      iconWidth: 14,
      iconHeight: 14.4,
    );
  }
}

class ScrapCount extends StatelessWidget {
  final int count;
  final CountVariant variant;
  final String? assetPathOverride;
  const ScrapCount({
    required this.count,
    this.variant = CountVariant.primary,
    this.assetPathOverride,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return _IconCount(
      assetPath: assetPathOverride ?? 'assets/icons/green_bookmark.svg',
      count: count,
      variant: variant,
      iconWidth: 12.8,
      iconHeight: 14,
    );
  }
}

// ---------- private base ----------

class _IconCount extends StatelessWidget {
  final String assetPath;
  final int count;
  final CountVariant variant;
  final double iconWidth;
  final double iconHeight;

  const _IconCount({
    required this.assetPath,
    required this.count,
    required this.variant,
    required this.iconWidth,
    required this.iconHeight,
  });

  static const TextStyle _baseTextStyle = AppTextStyles.bodyBody3M;

  @override
  Widget build(BuildContext context) {
    final iconColor = _iconColor(variant);
    final textColor = _textColor(variant);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          assetPath,
          width: iconWidth,
          height: iconHeight,
          // 단색 틴트
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        ),
        SizedBox(width: 4),
        SizedBox(
          width: 32,
          child: Text(
            '$count',
            style: _baseTextStyle.copyWith(color: textColor),
          ),
        ),
      ],
    );
  }
}

Color _iconColor(CountVariant variant) {
  switch (variant) {
    case CountVariant.neutral:
      return AppColors.gray800;
    case CountVariant.black:
      return AppColors.primary700;
    case CountVariant.primary:
      return AppColors.primary700;
  }
}

Color _textColor(CountVariant variant) {
  switch (variant) {
    case CountVariant.neutral:
      return AppColors.gray800;
    case CountVariant.black:
      return AppColors.gray800;
    case CountVariant.primary:
      return AppColors.primary700;
  }
}
