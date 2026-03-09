import 'package:flutter/material.dart';
import 'package:inninglog/shared/theme/app_colors.dart';
import 'package:inninglog/shared/theme/app_text_styles.dart';

class NewsSectionHeader extends StatelessWidget {
  final String highlightText;
  final bool showInfoIcon;
  final VoidCallback? onTapMore;
  final VoidCallback? onTapInfo;

  const NewsSectionHeader({
    super.key,
    required this.highlightText,
    this.showInfoIcon = false,
    this.onTapMore,
    this.onTapInfo,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = AppTextStyles.headHead6Sb.copyWith(
      color: AppColors.gray850,
    );

    return SizedBox(
      height: 21,
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: titleStyle,
                      children: [
                        TextSpan(
                          text: highlightText,
                          style: titleStyle.copyWith(
                            color: AppColors.primary700,
                          ),
                        ),
                        const TextSpan(text: ' 오늘의 뉴스 by '),
                        TextSpan(
                          text: 'AI',
                          style: titleStyle.copyWith(
                            color: AppColors.primary700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (showInfoIcon) ...[
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: onTapInfo,
                    borderRadius: BorderRadius.circular(12),
                    child: const Icon(
                      Icons.info_outline,
                      size: 15,
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          InkWell(
            onTap: onTapMore,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Text(
                    '더보기',
                    style: AppTextStyles.headHead8M.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                  const SizedBox(width: 1),
                  const Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: AppColors.gray500,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
