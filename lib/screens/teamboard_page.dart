import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inninglog/app_colors.dart';
import '../constant/team_codes.dart';
import '../widgets/common_header.dart';

class TeamBoardPage extends StatefulWidget {
  final String teamCode; // e.g. 'HT', 'LG', ...

  const TeamBoardPage({super.key, required this.teamCode});

  @override
  State<TeamBoardPage> createState() => _TeamBoardPageState();
}

class _TeamBoardPageState extends State<TeamBoardPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _sortIndex = 0; // 0: 최신, 1: 인기

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = teamNameFromCode(widget.teamCode);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3CC14B),
        onPressed: () {
          // TODO: 글쓰기 라우팅
        },
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 상단 헤더 (뒤로가기 포함)
            CommonHeader(title: title),

            // 카테고리 세그먼트 (오직완 / 자유 게시판 / 이닝 장터 / 오늘의 뉴스)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _SegmentedTabs(controller: _tabController),
            ),

            // 정렬 탭 (최신 | 인기)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
              child: _SortSwitch(
                index: _sortIndex,
                onChanged: (i) => setState(() => _sortIndex = i),
              ),
            ),

            // 구분선
            const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),

            // 탭별 컨텐츠
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 오직완
                  _PostList(sortIndex: _sortIndex),
                  // 자유 게시판
                  _PostList(sortIndex: _sortIndex),
                  // 이닝 장터
                  _PostList(sortIndex: _sortIndex),
                  // 오늘의 뉴스
                  _PostList(sortIndex: _sortIndex),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 연한 톤 배경의 세그먼트 탭 (피그마 느낌)
class _SegmentedTabs extends StatelessWidget {
  final TabController controller;
  const _SegmentedTabs({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9F2), // 살짝 연한 녹톤 배경
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TabBar(
        controller: controller,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: const Color(0xFFEFF5E6), // 선택 칸 배경
          borderRadius: BorderRadius.circular(8),
        ),
        labelColor: const Color(0xFF111827),
        unselectedLabelColor: const Color(0xFF6B7280),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          fontFamily: 'Pretendard',
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'Pretendard',
        ),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        indicatorSize: TabBarIndicatorSize.tab,
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        tabs: const [
          Tab(text: '오직완'),
          Tab(text: '자유 게시판'),
          Tab(text: '이닝 장터'),
          Tab(text: '오늘의 뉴스'),
        ],
      ),
    );
  }
}

/// “최신 | 인기” 언더라인 스위치
class _SortSwitch extends StatelessWidget {
  final int index; // 0: 최신, 1: 인기
  final ValueChanged<int> onChanged;
  const _SortSwitch({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SortTab(
          text: '최신',
          selected: index == 0,
          onTap: () => onChanged(0),
        ),
        const SizedBox(width: 24),
        _SortTab(
          text: '인기',
          selected: index == 1,
          onTap: () => onChanged(1),
        ),
      ],
    );
  }
}

class _SortTab extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const _SortTab({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              color: selected ? const Color(0xFF111827) : const Color(0xFF6B7280),
              fontFamily: 'Pretendard',
            ),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            height: 2,
            width: selected ? 28 : 0,
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }
}

/// 리스트 (피그마 카드)
class _PostList extends StatelessWidget {
  final int sortIndex;
  const _PostList({required this.sortIndex});

  @override
  Widget build(BuildContext context) {
    // 정렬에 따라 더미 데이터 순서만 살짝 바꿔보기
    final data = List<_Post>.from(_posts);
    if (sortIndex == 1) {
      data.sort((a, b) => (b.likes + b.comments).compareTo(a.likes + a.comments));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemBuilder: (_, i) {
        final p = data[i];
        return _PostTile(
          nickname: p.nickname,
          time: p.time,
          title: p.title,
          snippet: p.snippet,
          likes: p.likes,
          comments: p.comments,
          // 예시: 두 번째 카드에만 배지
          badge: i == 1 ? 5 : null,
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: data.length,
    );
  }
}

class _PostTile extends StatefulWidget {
  final String nickname, time, title, snippet;
  final int likes, comments;
  final int? badge;

  const _PostTile({
    super.key,
    required this.nickname,
    required this.time,
    required this.title,
    required this.snippet,
    required this.likes,
    required this.comments,
    this.badge,
  });

  @override
  State<_PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<_PostTile> {
  bool _liked = false;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.likes;
  }

  void _toggleLike() {
    setState(() {
      _liked = !_liked;
      _likeCount += _liked ? 1 : -1;
    });
    // TODO: 서버 좋아요/취소 API
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {}, // TODO: 게시글 상세
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              // 왼쪽 텍스트
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 18, height: 18,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE5E7EB),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.nickname, // ← widget.
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.gray800,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.time, // ← widget.
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.gray700,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.title, // ← widget.
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray900,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.snippet, // ← widget.
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.gray900,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 좋아요/댓글
                    Row(
                      children: [
                        InkWell(
                          onTap: _toggleLike,
                          borderRadius: BorderRadius.circular(4),
                          child: SvgPicture.asset(
                            _liked
                                ? 'assets/icons/Heart_fill.svg' // 채워진 하트
                                : 'assets/icons/Heart.svg',      // 비워진 하트
                            width: 16,
                            height: 16,
                            colorFilter: ColorFilter.mode(
                              _liked ? const Color(0xFF94C32C) : const Color(0xFF4E4E4E),
                              BlendMode.srcIn, // 필요 시 srcATop으로 교체
                            ),
                          ),
                        ),



                        const SizedBox(width: 4),
                        Text(
                          '$_likeCount',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF4E4E4E),
                            fontFamily: 'Pretendard',
                          ),
                        ),
                        const SizedBox(width: 11),
                        SvgPicture.asset(
                          'assets/icons/comment.svg',
                          width: 16, height: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.comments}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF4E4E4E),
                            fontFamily: 'Pretendard',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // 썸네일 + 배지
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  if (widget.badge != null)
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE74B3C),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x29000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            )
                          ],
                        ),
                        child: Text(
                          '${widget.badge}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/* 더미 데이터 */
class _Post {
  final String nickname, time, title, snippet;
  final int likes, comments;
  _Post(
      this.nickname,
      this.time,
      this.title,
      this.snippet,
      this.likes,
      this.comments,
      );
}

final _posts = <_Post>[
  _Post('닉네임 및 자까진 되더라', '2025/05/25(일) 11:02',
      '제목_공백 포함 최대 20자까지 가능', '본문은 보여지는 건 최대 24자까지 가능', 2, 2),
  _Post('닉네임 및 자까진 되더라', '2025/05/25(일) 11:02',
      '제목_공백 포함 최대 20자까지 가능', '본문은 보여지는 건 최대 24자까지 가능', 7, 3),
  _Post('닉네임 및 자까진 되더라', '2025/05/25(일) 11:02',
      '제목_공백 포함 최대 20자까지 가능', '본문은 보여지는 건 최대 24자까지 가능', 4, 1),
];



