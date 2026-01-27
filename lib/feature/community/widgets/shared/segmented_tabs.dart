import 'package:flutter/material.dart';
import 'package:inninglog/shared/theme/app_colors.dart';
import 'package:inninglog/shared/theme/app_text_styles.dart';

enum BoardTab { onlywan, free, news }

const Map<BoardTab, String> _boardTabPaths = {
  BoardTab.onlywan: 'onlywan',
  BoardTab.free: 'free',
  BoardTab.news: 'news',
};

String boardTabPath(BoardTab tab) => _boardTabPaths[tab]!;

BoardTab boardTabFromPath(String value) {
  for (final entry in _boardTabPaths.entries) {
    if (entry.value == value) return entry.key;
  }
  return BoardTab.free;
}

class CommunityTabItem {
  final BoardTab type;
  final String label;

  const CommunityTabItem({required this.type, required this.label});
}

class SegmentedTabs extends StatelessWidget {
  final TabController controller;
  final List<CommunityTabItem> items;

  const SegmentedTabs({
    super.key,
    required this.controller,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.gray400, width: 0.5),
        ),
      ),
      child: TabBar(
        controller: controller,
        dividerColor: Colors.transparent,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.primary700, width: 1.5),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: const Color(0xFF000000),
        unselectedLabelColor: AppColors.gray700,
        labelStyle: AppTextStyles.headHead7Sb,
        unselectedLabelStyle: AppTextStyles.headHead7R,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        tabs: items.map((e) => Tab(text: e.label)).toList(),
      ),
    );
  }
}
