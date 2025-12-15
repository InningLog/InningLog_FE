import 'package:flutter/material.dart';
import 'package:inninglog/feature/community/model/team_item.dart';
import 'package:inninglog/feature/community/widgets/components/image_button.dart';

class TeamTile extends StatelessWidget {
  final TeamItem item;
  final VoidCallback onTap;

  const TeamTile({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ImageButton(
            imagePath: item.imagePath,
            borderRadius: 8,
            onTap: onTap,
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Text(
              item.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontFamily: 'Pretendard',
                letterSpacing: -0.12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
