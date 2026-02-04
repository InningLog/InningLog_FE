import 'package:flutter/material.dart';
import 'package:inninglog/feature/community/model/diary_item.dart';
import 'package:inninglog/feature/community/widgets/onlywan/diary_item.dart';
import 'package:inninglog/shared/theme/app_colors.dart';

class FeedList extends StatelessWidget {
  final List<DiaryItemModel> items;

  const FeedList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        return FeedItem(item: item);
      },
      separatorBuilder:
          (_, __) =>
              const Divider(height: 1, thickness: 1, color: AppColors.gray200),
      itemCount: items.length,
    );
  }
}
