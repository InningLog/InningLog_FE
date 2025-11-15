import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inninglog/app_colors.dart';
import 'package:inninglog/screens/teamboard_page.dart';
import '../widgets/common_header.dart';
import 'community_search_page.dart';

class BoardPage extends StatelessWidget {
  const BoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            CommonHeader(
            title: '커뮤니티',
            onSearchPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CommunitySearchPage()),
              );
            },
          ),


              // MY TEAM
              const _SectionTitle('MY TEAM'),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _BannerCard(
                  imagePath: 'assets/images/mydoo_banner.png',
                  height: 88,
                  onTap: () {
                    // TODO: 실제 내 팀 코드로 교체
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TeamBoardPage(teamCode: 'OB'), // 두산 예시
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),

// KBO 전체 게시판
              const _SectionTitle('KBO 전체 게시판'),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _BannerCard(
                  imagePath: 'assets/images/card_kbo.png',
                  height: 88,
                  onTap: () {
                    // KBO 전체 게시판용
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TeamBoardPage(teamCode: 'KBO'),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),

              // 팀 게시판
              const _SectionTitle('팀 게시판'),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _TeamGrid(
                  items: const [
                    TeamItem('HT', '기아 타이거즈 🐯', 'assets/images/card_kia.png'),
                    TeamItem('HH', '한화 이글스 🦅', 'assets/images/card_hh.png'),
                    TeamItem('WO', '키움 히어로즈 🦸🏻️', 'assets/images/card_kw.png'),
                    TeamItem('LG', 'LG 트윈스 👶🏻👶🏻', 'assets/images/card_lg.png'),
                    TeamItem('NC', 'NC 다이노스 🦖', 'assets/images/card_nc.png'),
                    TeamItem('SK', 'SSG 랜더스 🗺️', 'assets/images/card_ssg.png'),
                    TeamItem('SS', '삼성 라이온즈 🦁', 'assets/images/card_ss.png'),
                    TeamItem('LT', '롯데 자이언츠 🌊️', 'assets/images/card_lt.png'),
                    TeamItem('KT', 'KT 위즈 🧙🏻', 'assets/images/card_kt.png'),
                  ],
                  onTap: (item) {
                    // GoRouter 사용 시:
                    // context.push('/boards/${item.code}');
                    // 또는 Navigator 사용 시:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TeamBoardPage(teamCode: item.code),
                      ),
                    );
                  },
                ),
              ),const _PopularAndMySection(),


            ],
          ),
        ),
      ),
    );
  }
}

/// 섹션 타이틀
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 19,
          fontFamily: 'pretendard',
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
    );
  }
}

/// 상단 배너(내 팀 / KBO 전체)
class _BannerCard extends StatelessWidget {
  final String imagePath;
  final double height;
  final VoidCallback? onTap;

  const _BannerCard({
    required this.imagePath,
    this.height = 88,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 343 / 88, // 대략 디자인 비율
      child: _ImageButton(
        imagePath: imagePath,
        borderRadius: 10,
        onTap: onTap,
      ),
    );
  }
}

/// 팀 카드 그리드
class _TeamGrid extends StatelessWidget {
  final List<TeamItem> items;
  final void Function(TeamItem) onTap;
  const _TeamGrid({required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 8,
        childAspectRatio: 1.9, // 네모 느낌
      ),
      itemBuilder: (_, i) => _TeamTile(
        item: items[i],
        onTap: () => onTap(items[i]),
      ),
    );
  }
}

class TeamItem {
  final String code;
  final String label;     // 버튼 위에 얹을 텍스트 (이모지 포함)
  final String imagePath; // 네모 배경 이미지
  const TeamItem(this.code, this.label, this.imagePath);
}

class _TeamTile extends StatelessWidget {
  final TeamItem item;
  final VoidCallback onTap;
  const _TeamTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: _ImageButton(
            imagePath: item.imagePath,
            borderRadius: 8,
            onTap: onTap,
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Text(
              item.label, // 이모지 포함 라벨
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontFamily: 'pretendard',
              ),
            ),
          ),
        ),

      ],
    );
  }
}


/// 공통: 이미지 배경 + 라운드 + 탭 효과
class _ImageButton extends StatelessWidget {
  final String imagePath;
  final double borderRadius;
  final VoidCallback? onTap;

  const _ImageButton({
    required this.imagePath,
    this.borderRadius = 12,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius),
      clipBehavior: Clip.antiAlias,
      child: Ink.image(
        image: AssetImage(imagePath),
        fit: BoxFit.cover,
        child: InkWell(onTap: onTap),
      ),
    );
  }
}




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
                      builder: (_) =>
                      const TeamBoardPage(teamCode: '인기 게시물'),
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
                        builder: (_) => const TeamBoardPage(
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
                        builder: (_) =>
                        const TeamBoardPage(teamCode: '댓글 단 글'),
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
                        builder: (_) =>
                        const TeamBoardPage(teamCode: '스크랩'),
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
