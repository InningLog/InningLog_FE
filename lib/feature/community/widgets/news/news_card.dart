import 'package:flutter/material.dart';
import 'package:inninglog/feature/community/widgets/news/news_bullet_list.dart';
import 'package:inninglog/feature/community/widgets/news/news_tag_chip.dart';
import 'package:inninglog/shared/theme/app_colors.dart';
import 'package:inninglog/shared/theme/app_text_styles.dart';

class NewsCardItemData {
  final String title;
  final List<String> summaryBullets;
  final List<String> tags;

  const NewsCardItemData({
    required this.title,
    required this.summaryBullets,
    required this.tags,
  });
}

class NewsCard extends StatelessWidget {
  final NewsCardItemData item;
  final VoidCallback? onTap;

  const NewsCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          decoration: BoxDecoration(
            color: AppColors.primary50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gray300, width: 0.7),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: AppTextStyles.headHead7Sb.copyWith(
                  color: AppColors.gray850,
                ),
              ),
              const SizedBox(height: 8),
              NewsBulletList(items: item.summaryBullets),
              if (item.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: item.tags
                      .map((tag) => NewsTagChip(label: tag))
                      .toList(growable: false),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
