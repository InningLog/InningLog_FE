import 'package:flutter/material.dart';
import 'package:inninglog/feature/community/widgets/news/news_card.dart';
import 'package:inninglog/feature/community/widgets/news/news_cards_panel.dart';
import 'package:inninglog/feature/community/widgets/news/news_section_header.dart';

class NewsSection extends StatelessWidget {
  final String highlightText;
  final bool showInfoIcon;
  final List<NewsCardItemData> items;
  final VoidCallback? onTapMore;
  final VoidCallback? onTapInfo;
  final void Function(NewsCardItemData item)? onTapItem;

  const NewsSection({
    super.key,
    required this.highlightText,
    required this.items,
    this.showInfoIcon = false,
    this.onTapMore,
    this.onTapInfo,
    this.onTapItem,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: NewsSectionHeader(
            highlightText: highlightText,
            showInfoIcon: showInfoIcon,
            onTapMore: onTapMore,
            onTapInfo: onTapInfo,
          ),
        ),
        const SizedBox(height: 12),
        NewsCardsPanel(items: items, onTapItem: onTapItem),
      ],
    );
  }
}
