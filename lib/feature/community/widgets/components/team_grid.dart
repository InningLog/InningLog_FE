import 'package:flutter/material.dart';
import 'package:inninglog/feature/community/model/team_item.dart';

import 'package:inninglog/feature/community/widgets/components/team_tile.dart';

class TeamGrid extends StatelessWidget {
  final List<TeamItem> items;
  final ValueChanged<TeamItem> onTap;

  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;

  const TeamGrid({
    super.key,
    required this.items,
    required this.onTap,
    this.crossAxisCount = 3,
    this.mainAxisSpacing = 12,
    this.crossAxisSpacing = 8,
    this.childAspectRatio = 1.9,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (_, i) {
        final item = items[i];
        return TeamTile(item: item, onTap: () => onTap(item));
      },
    );
  }
}
