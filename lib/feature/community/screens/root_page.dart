import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inninglog/feature/community/data/team_catalog.dart';
import 'package:inninglog/feature/community/widgets/root/sections/banner_section.dart';
import 'package:inninglog/feature/community/widgets/root/sections/team_boards_section.dart';
import 'package:inninglog/shared/theme/app_colors.dart';
import 'package:inninglog/feature/community/screens/teamboard_page.dart';
import '../../../shared/widgets/common_header.dart';
import 'community_search_page.dart';

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
            onSearchPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CommunitySearchPage()),
              );
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
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
            const _PopularAndMySection(),
          ],
        ),
      ),
    );
  }
}

/// 팀 카드 그리드

// ▼ 인기 게시물 + MY 섹션
class _PopularAndMySection extends StatelessWidget {
  const _PopularAndMySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 인기 게시물 타이틀
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '인기 게시물',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Pretendard',
                  letterSpacing: -0.19,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TeamBoardPage(teamCode: '인기 게시물'),
                    ),
                  );
                },
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Colors.grey,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 게시물 카드 2개 (예시)
          const _PopularPostCard(
            title: '제목_공백 포함 최대 20자까지 가능',
            preview: '본문 보이는 건 최대 24자 그 이상은 …',
            dateTime: '10/26 09:07',
            likeCount: 12,
            commentCount: 8,
            bookmarkCount: 3,
          ),
          const SizedBox(height: 12),
          const _PopularPostCard(
            title: '이닝로그 첫 직관 후기 모음',
            preview: '잠실 직관 후기 공유합니다 🔥',
            dateTime: '10/26 11:20',
            likeCount: 9,
            commentCount: 4,
            bookmarkCount: 1,
          ),

          const SizedBox(height: 24),

          const Text(
            'MY',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              fontFamily: 'Pretendard',
              color: Colors.black,
              letterSpacing: -0.19,
            ),
          ),
          const SizedBox(height: 11),

          // MY 섹션
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 내가 쓴 글
                _MyMenuButton(
                  icon: '✏️',
                  label: '내가 쓴 글',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => const TeamBoardPage(
                              teamCode: 'KBO', // 의미상 전체/내 활동용 아무 값
                              mode: BoardMode.myPosts,
                            ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),

                // 댓글 단 글
                _MyMenuButton(
                  icon: '💬',
                  label: '댓글 단 글',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TeamBoardPage(teamCode: '댓글 단 글'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),

                // 스크랩
                _MyMenuButtonSvg(
                  svgPath: 'assets/icons/scrap_full.svg',
                  label: '스크랩',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TeamBoardPage(teamCode: '스크랩'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//// 인기 게시물 카드 위젯
class _PopularPostCard extends StatelessWidget {
  final String title;
  final String preview;
  final String dateTime;
  final int likeCount;
  final int commentCount;
  final int bookmarkCount;

  const _PopularPostCard({
    required this.title,
    required this.preview,
    required this.dateTime,
    required this.likeCount,
    required this.commentCount,
    required this.bookmarkCount,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목 + 날짜
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Pretendard',
                    color: AppColors.gray850,
                    letterSpacing: -0.15,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                dateTime,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Pretendard',
                  color: AppColors.gray700,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // 본문 일부
          Text(
            preview,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontFamily: 'Pretendard',
              color: AppColors.gray900,
              letterSpacing: -0.12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),

          // 하단 아이콘들
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/green_heart.svg',
                width: 12.3,
                height: 10.44,
              ),
              const SizedBox(width: 4),
              Text(
                '$likeCount',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primary700,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.12,
                  height: 1.5,
                ),
              ),
              const SizedBox(width: 11),
              SvgPicture.asset(
                'assets/icons/green_comment.svg',
                width: 14,
                height: 14.4,
              ),
              const SizedBox(width: 4),
              Text(
                '$commentCount',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primary700,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.12,
                  height: 1.5,
                ),
              ),
              const SizedBox(width: 11),
              SvgPicture.asset(
                'assets/icons/green_bookmark.svg',
                width: 12.8,
                height: 14,
              ),
              const SizedBox(width: 4),
              Text(
                '$bookmarkCount',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primary700,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// MY 메뉴 버튼
/// MY 메뉴 버튼
class _MyMenuButton extends StatelessWidget {
  final String icon;
  final String label;
  final Color? iconColor;
  final VoidCallback? onTap;

  const _MyMenuButton({
    required this.icon,
    required this.label,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.gray300, width: 0.8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: TextStyle(
                fontSize: 12,
                color: iconColor ?? Colors.black,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
                letterSpacing: -0.12,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
                letterSpacing: -0.12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// MY 메뉴 버튼 (SVG 버전)
class _MyMenuButtonSvg extends StatelessWidget {
  final String svgPath;
  final String label;
  final VoidCallback? onTap;

  const _MyMenuButtonSvg({
    required this.svgPath,
    required this.label,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.gray300, width: 0.8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              svgPath,
              width: 12,
              height: 14,
              colorFilter: const ColorFilter.mode(
                AppColors.primary700,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
                letterSpacing: -0.12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
