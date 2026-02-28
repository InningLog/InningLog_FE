import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inninglog/app_scope.dart';
import 'package:inninglog/feature/community/data/team_catalog.dart';
import 'package:inninglog/feature/community/widgets/root/sections/banner_section.dart';
import 'package:inninglog/feature/community/widgets/root/sections/my_section.dart';
import 'package:inninglog/feature/community/widgets/root/sections/popular_posts_section.dart';
import 'package:inninglog/feature/community/widgets/root/sections/team_boards_section.dart';
import 'package:inninglog/feature/community/viewmodel/root_view_model.dart';
import 'package:inninglog/shared/theme/app_colors.dart';
import 'package:inninglog/router/app_routes.dart';
import 'package:inninglog/shared/widgets/common_header.dart';

import 'package:provider/provider.dart';

class CommunityRootPage extends StatelessWidget {
  const CommunityRootPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = context.read<AppScope>();

    return ChangeNotifierProvider(
      create:
          (_) =>
              CommunityRootViewModel(
                  userRepository: scope.userRepository,
                  postRepository: scope.communityPostRepository,
                )
                ..fetchMyTeam()
                ..fetchPopularPosts(),
      child: const _CommunityRootView(),
    );
  }
}

class _CommunityRootView extends StatelessWidget {
  const _CommunityRootView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CommunityRootViewModel>();
    final myTeamCode = vm.myTeamCode;
    final myTeamBannerPath =
        kboTeamBannerCatalog[myTeamCode] ?? 'assets/images/card_kbo.png';

    return Scaffold(
      backgroundColor: AppColors.primary50,
      body: SafeArea(
        child: Column(
          children: [
            CommonHeader(
              title: '커뮤니티',
              onSearchPressed:
                  () => context.push(
                    AppRoutePaths.searchLocation(
                      teamCode: 'ALL',
                      tab: 'onlywan',
                    ),
                  ),
            ),

            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary700,
                onRefresh: () async {
                  await Future.wait([vm.fetchMyTeam(), vm.fetchPopularPosts()]);
                },
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    spacing: 24,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // MY TEAM
                      BannerSection(
                        title: 'MY TEAM',
                        imagePath: myTeamBannerPath,
                        onTap: () {
                          if (myTeamCode == null || myTeamCode.isEmpty) return;
                          context.push(AppRoutePaths.boardLocation(myTeamCode));
                        },
                      ),
                      // 전체 게시판
                      BannerSection(
                        title: 'KBO 전체 게시판',
                        imagePath: 'assets/images/card_kbo.png',
                        onTap: () {
                          context.push(AppRoutePaths.boardLocation('ALL'));
                        },
                      ),
                      // 팀 게시판
                      TeamBoardsSection(
                        items: vm.teamGridItems,
                        onTap: (team) {
                          context.push(AppRoutePaths.boardLocation(team.code));
                        },
                      ),
                      PopularPostsSection(
                        posts: vm.popularPosts,
                        isLoading: vm.isPopularPostsLoading,
                        onTap: (postId) {
                          final teamCode =
                              vm.popularPosts
                                  .firstWhere((p) => p.postId == postId)
                                  .teamShortCode;
                          context.pushNamed(
                            AppRouteNames.postDetail,
                            pathParameters: {
                              'code': teamCode,
                              'postId': '$postId',
                            },
                          );
                        },
                        onMoreTap:
                            () => context.push(AppRoutePaths.communityPopular),
                      ),
                      const MySection(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
