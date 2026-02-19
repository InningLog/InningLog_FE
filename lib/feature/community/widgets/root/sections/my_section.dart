import 'package:flutter/material.dart';
import 'package:inninglog/feature/community/model/my_menu_action.dart';
import 'package:inninglog/feature/community/screens/teamboard_page.dart';
import 'package:inninglog/feature/community/widgets/root/components/my_menu_button.dart';
import 'package:inninglog/feature/community/widgets/root/components/my_menu_item.dart';
import 'package:inninglog/feature/community/widgets/root/components/section_title.dart';

class MySection extends StatelessWidget {
  const MySection({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = <MyMenuAction>[
      MyMenuAction.emoji(
        label: '내가 쓴 글',
        emoji: '✏️',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => const TeamBoardPage(
                    teamCode: 'KBO',
                    mode: BoardMode.myPosts,
                  ),
            ),
          );
        },
      ),
      MyMenuAction.emoji(
        label: '댓글 단 글',
        emoji: '💬',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => const TeamBoardPage(
                    teamCode: '댓글 단 글',
                    mode: BoardMode.myComments,
                  ),
            ),
          );
        },
      ),
      MyMenuAction.svg(
        label: '스크랩',
        svgPath: 'assets/icons/scrap_full.svg',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => const TeamBoardPage(
                    teamCode: '스크랩',
                    mode: BoardMode.scraps,
                  ),
            ),
          );
        },
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 11,
      children: [
        SectionTitle(title: 'MY'),
        Center(
          child: Column(
            children: [
              for (final action in actions) ...[
                MyMenuButton(
                  onTap: action.onTap,
                  child: _buildMenuItem(action),
                ),
                if (action != actions.last) const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(MyMenuAction action) {
    switch (action.iconKind) {
      case MyMenuIconKind.emoji:
        return MyMenuItem.emoji(
          emoji: action.emoji!,
          label: action.label,
          emojiColor: action.emojiColor,
          emojiSize: action.emojiSize ?? 12,
        );

      case MyMenuIconKind.svg:
        return MyMenuItem.svg(
          svgPath: action.svgPath!,
          label: action.label,
          iconColor: action.svgColor!,
          width: action.svgWidth ?? 12,
          height: action.svgHeight ?? 14,
        );
    }
  }
}
