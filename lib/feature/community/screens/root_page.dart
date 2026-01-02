import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inninglog/feature/community/data/team_catalog.dart';
import 'package:inninglog/feature/community/widgets/root/sections/banner_section.dart';
import 'package:inninglog/feature/community/widgets/root/sections/my_section.dart';
import 'package:inninglog/feature/community/widgets/root/sections/popular_posts_section.dart';
import 'package:inninglog/feature/community/widgets/root/sections/team_boards_section.dart';
import 'package:inninglog/shared/theme/app_colors.dart';
import 'package:inninglog/feature/community/screens/teamboard_page.dart';
import 'package:inninglog/router/app_routes.dart';
import '../../../shared/widgets/common_header.dart';

class CommunityRootPage extends StatelessWidget {
  const CommunityRootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary50,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: SafeArea(
          child: CommonHeader(
            title: '커뮤니티',
            onSearchPressed: () => context.push(AppRoutePaths.search),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          spacing: 24,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // MY TEAM
            BannerSection(
              title: 'MY TEAM',
              imagePath: 'assets/images/mydoo_banner.png',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TeamBoardPage(teamCode: 'OB'),
                  ),
                );
              },
            ),
            //전체 게시판
            BannerSection(
              title: 'KBO 전체 게시판',
              imagePath: 'assets/images/card_kbo.png',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TeamBoardPage(teamCode: 'KBO'),
                  ),
                );
              },
            ),

            // 팀 게시판
            TeamBoardsSection(
              items: kboTeams,
              onTap: (team) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TeamBoardPage(teamCode: team.code),
                  ),
                );
              },
            ),
            PopularPostsSection(onTap: () {}),
            MySection(),
          ],
        ),
      ),
    );
  }
}
