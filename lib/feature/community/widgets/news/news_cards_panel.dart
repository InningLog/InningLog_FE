import 'package:flutter/material.dart';
import 'package:inninglog/feature/community/widgets/news/news_card.dart';
import 'package:inninglog/shared/theme/app_colors.dart';

class NewsCardsPanel extends StatelessWidget {
  final List<NewsCardItemData> items;
  final void Function(NewsCardItemData item)? onTapItem;

  const NewsCardsPanel({super.key, required this.items, this.onTapItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.primary100,
        boxShadow: [
          BoxShadow(
            color: AppColors.gray900.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
            child: NewsCard(item: item, onTap: () => onTapItem?.call(item)),
          );
        }),
      ),
    );
  }
}
