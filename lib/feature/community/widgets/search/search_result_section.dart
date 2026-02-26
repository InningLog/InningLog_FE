import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inninglog/feature/community/model/community_post.dart';
import 'package:inninglog/feature/community/model/diary_item.dart';
import 'package:inninglog/feature/community/widgets/onlywan/diary_item.dart';
import 'package:inninglog/feature/community/widgets/post/post_item_card.dart';
import 'package:inninglog/feature/community/widgets/shared/board_list.dart';
import 'package:inninglog/feature/community/widgets/shared/segmented_tabs.dart';
import 'package:inninglog/router/app_routes.dart';
import 'package:inninglog/shared/theme/app_colors.dart';
import 'package:inninglog/shared/widgets/empty_state.dart';

class SearchResultSection extends StatelessWidget {
  final TabController controller;
  final List<DiaryItemModel> onlywanResults;
  final List<CommunityPostItem> freeResults;
  final bool isLoading;
  final bool hasNext;
  final Future<void> Function() onLoadMore;
  final String query;
  final String teamCode;

  const SearchResultSection({
    super.key,
    required this.controller,
    required this.onlywanResults,
    required this.freeResults,
    required this.isLoading,
    required this.hasNext,
    required this.onLoadMore,
    required this.query,
    required this.teamCode,
  });

  @override
  Widget build(BuildContext context) {
    const tabs = <CommunityTabItem>[
      CommunityTabItem(type: BoardTab.onlywan, label: '오직완'),
      CommunityTabItem(type: BoardTab.free, label: '자유 게시판'),
    ];

    return Column(
      children: [
        SegmentedTabs(controller: controller, items: tabs),
        Expanded(
          child: TabBarView(
            controller: controller,
            children: [
              _OnlywanResultList(
                items: onlywanResults,
                isLoading: isLoading,
                hasNext: hasNext,
                onLoadMore: onLoadMore,
                query: query,
              ),
              _FreeResultList(
                items: freeResults,
                isLoading: isLoading,
                hasNext: hasNext,
                onLoadMore: onLoadMore,
                query: query,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OnlywanResultList extends StatelessWidget {
  final List<DiaryItemModel> items;
  final bool isLoading;
  final bool hasNext;
  final Future<void> Function() onLoadMore;
  final String query;

  const _OnlywanResultList({
    required this.items,
    required this.isLoading,
    required this.hasNext,
    required this.onLoadMore,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty && !isLoading) {
      return EmptyState(message: '"$query" 검색 결과가 없습니다.');
    }

    return BoardList<DiaryItemModel>(
      items: items,
      hasNext: hasNext,
      isLoading: isLoading,
      onLoadMore: onLoadMore,
      itemBuilder: (context, item) => DiaryItem(item: item),
    );
  }
}

class _FreeResultList extends StatelessWidget {
  final List<CommunityPostItem> items;
  final bool isLoading;
  final bool hasNext;
  final Future<void> Function() onLoadMore;
  final String query;

  const _FreeResultList({
    required this.items,
    required this.isLoading,
    required this.hasNext,
    required this.onLoadMore,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty && !isLoading) {
      return EmptyState(message: '"$query" 검색 결과가 없습니다.');
    }

    return BoardList<CommunityPostItem>(
      items: items,
      hasNext: hasNext,
      isLoading: isLoading,
      onLoadMore: onLoadMore,
      itemBuilder:
          (context, item) => PostItemCard(
            item: item,
            onTap:
                () => context.push(
                  AppRoutePaths.boardPostDetailLocation(item.teamCode, item.id),
                ),
          ),
    );
  }
}
