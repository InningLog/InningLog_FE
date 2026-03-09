import 'package:flutter/material.dart';
import 'package:inninglog/shared/theme/app_colors.dart';
import 'package:inninglog/shared/theme/app_text_styles.dart';

class NewsBulletList extends StatelessWidget {
  final List<String> items;

  const NewsBulletList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(items.length, (index) {
        final isLast = index == items.length - 1;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Text(
                  '•',
                  style: AppTextStyles.bodyBody3Rg.copyWith(
                    color: AppColors.gray850,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  items[index],
                  style: AppTextStyles.bodyBody3Rg.copyWith(
                    color: AppColors.gray850,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
