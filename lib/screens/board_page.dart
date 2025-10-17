import 'package:flutter/material.dart';
import 'package:inninglog/app_colors.dart';
import '../widgets/common_header.dart';

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
              const CommonHeader(title: '커뮤니티'),

              // MY TEAM
              const _SectionTitle('MY TEAM'),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _BannerCard(
                  imagePath: 'assets/images/mydoo_banner.png', // 네모 배너 이미지
                  height: 88,
                  onTap: () {
                    // TODO: 내 팀 보드로 이동
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
                  imagePath: 'assets/images/kbo_banner.png',
                  height: 88,
                  onTap: () {
                    // TODO: KBO 전체 게시판으로 이동
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
                    TeamItem('기아 타이거즈 🐯', 'assets/images/card_kia.png'),
                    TeamItem('한화 이글스 🦅', 'assets/images/card_hh.png'),
                    TeamItem('키움 히어로즈 🦸🏻️', 'assets/images/card_kw.png'),
                    TeamItem('LG 트윈스 👶🏻👶🏻', 'assets/images/card_lg.png'),
                    TeamItem('NC 다이노스 🦖', 'assets/images/card_nc.png'),
                    TeamItem('SSG 랜더스 🗺️', 'assets/images/card_ssg.png'),
                    TeamItem('삼성 라이온즈 🦁', 'assets/images/card_ss.png'),
                    TeamItem('롯데 자이언츠 🌊️', 'assets/images/card_lt.png'),
                    TeamItem('KT 위즈 🧙🏻', 'assets/images/card_kt.png'),
                  ],
                  onTap: (item) {
                    // TODO: 각 팀 게시판 라우팅
                    // context.push('/boards/${teamShortCode}');
                  },
                ),
              ),
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
  final String label;     // 버튼 위에 얹을 텍스트 (이모지 포함)
  final String imagePath; // 네모 배경 이미지
  const TeamItem(this.label, this.imagePath);
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
        // 중앙 텍스트 오버레이
        Positioned.fill(
          child: Center(
            child: Text(
              item.label,
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
