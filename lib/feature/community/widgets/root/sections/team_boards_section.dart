import 'package:flutter/material.dart';
import 'package:inninglog/feature/community/model/team_item.dart';
import 'package:inninglog/feature/community/widgets/root/components/section_title.dart';
import 'package:inninglog/feature/community/widgets/root/components/team_grid.dart';

class TeamBoardsSection extends StatelessWidget {
  final String title;
  final List<TeamItem> items;
  final ValueChanged<TeamItem> onTap;

  final EdgeInsetsGeometry padding;
  final double bottomSpacing;

  const TeamBoardsSection({
    super.key,
    this.title = '팀 게시판',
    required this.items,
    required this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.bottomSpacing = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title),
        const SizedBox(height: 8),
        Padding(padding: padding, child: TeamGrid(items: items, onTap: onTap)),
        SizedBox(height: bottomSpacing),
      ],
    );
  }
}
