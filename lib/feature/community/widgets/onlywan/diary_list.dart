import 'package:flutter/material.dart';
import 'package:inninglog/feature/community/model/diary_item.dart';
import 'package:inninglog/feature/community/widgets/onlywan/diary_item.dart';
import 'package:inninglog/feature/community/widgets/shared/board_list.dart';
import 'package:inninglog/shared/widgets/empty_state.dart';

class FeedList extends StatelessWidget {
  final List<DiaryItemModel> items;
  final bool isLoading;
  final bool hasNext;
  final Future<void> Function()? onLoadMore;

  const FeedList({
    super.key,
    required this.items,
    this.isLoading = false,
    this.hasNext = false,
    this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty && !isLoading) {
      return const EmptyState(message: '게시물이 없습니다.');
    }

    return BoardList<DiaryItemModel>(
      items: items,
      hasNext: hasNext,
      isLoading: isLoading,
      onLoadMore: onLoadMore,
      itemBuilder: (context, item) => FeedItem(item: item),
    );
  }
}
