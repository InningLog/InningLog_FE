import 'package:flutter/material.dart';
import 'package:inninglog/feature/community/model/team_item.dart';
import 'package:inninglog/feature/community/widgets/root/components/section_title.dart';
import 'package:inninglog/feature/community/widgets/root/components/team_grid.dart';

class TeamBoardsSection extends StatelessWidget {
  final List<TeamItem> items;
  final ValueChanged<TeamItem> onTap;

  const TeamBoardsSection({
    super.key,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: '팀 게시판'),
        const SizedBox(height: 8),
        TeamGrid(items: items, onTap: onTap),
      ],
    );
  }
}
