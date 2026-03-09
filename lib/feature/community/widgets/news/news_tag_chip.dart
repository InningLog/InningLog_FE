import 'package:flutter/material.dart';
import 'package:inninglog/shared/theme/app_colors.dart';
import 'package:inninglog/shared/theme/app_text_styles.dart';

class NewsTagChip extends StatelessWidget {
  final String label;

  const NewsTagChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary700, width: 0.7),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodyBody4M.copyWith(color: AppColors.gray850),
      ),
    );
  }
}
