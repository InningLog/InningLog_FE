import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:inninglog/app_colors.dart';
import '../constant/team_codes.dart';
import '../widgets/common_header.dart';
import 'alarm_page.dart';
import 'community_search_market.dart';
import 'community_search_page.dart';
import 'post_compose_page.dart';

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
  int _sectionIndex = 0; // ✅ 0: 오직완, 1: 자유, 2: 이닝 장터, 3: 오늘의 뉴스

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return; // 애니메 중복 setState 방지
      setState(() {
        _sectionIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final title = teamNameFromCode(widget.teamCode);
    final teamLabel = teamLabelFromCode(widget.teamCode);

    return Scaffold(
      backgroundColor: AppColors.primary50,
      floatingActionButton: SizedBox(
        width: 56,
        height: 56,
        child: FloatingActionButton(
          backgroundColor: AppColors.primary700,
          shape: const CircleBorder(),
          onPressed: () {
            context.push('/boards/${widget.teamCode}/compose', extra: teamLabel);

          },

          child: const Icon(
            Icons.add,
            size: 40,
            color: AppColors.primary50,
          ),
        ),
      ),


      body: SafeArea(
        child: Column(
          children: [
            // 상단 헤더 (뒤로가기 포함)
            communityHeader(
              context,
              title,
              sectionIndex: _sectionIndex, // ✅ 현재 탭 넘김
            ),





            // 카테고리 세그먼트 (오직완 / 자유 게시판 / 이닝 장터 / 오늘의 뉴스)
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: _SegmentedTabs(controller: _tabController),
            ),

            // 정렬 탭 (최신 | 인기)
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 0),
            //   child: SortSwitch(
            //     index: _sortIndex,
            //     onChanged: (i) => setState(() => _sortIndex = i),
            //   ),
            // ),


            // 구분선
            const Divider(height: 1, thickness: 0.8, color: AppColors.gray400),

            // 탭별 컨텐츠
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _PostList(
                    isOnlywan: true,          // ✅ 0번 탭만 오직완 레이아웃
                    sortIndex: _sortIndex,
                    teamCode: widget.teamCode,
                    teamLabel: teamLabel,
                  ),
                  _PostList(sortIndex: _sortIndex, teamCode: widget.teamCode, teamLabel: teamLabel),
                  _PostList(sortIndex: _sortIndex, teamCode: widget.teamCode, teamLabel: teamLabel),
                  _PostList(sortIndex: _sortIndex, teamCode: widget.teamCode, teamLabel: teamLabel),
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
    final dividerColor = AppColors.primary50;

    return Container(
      height: 40,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.gray400, // 회색 밑줄 (불투명도 0.5)
            width: 0.5,
          ),
        ),
      ),
      child: TabBar(
        controller: controller,
        dividerColor: Colors.transparent,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(
            color: AppColors.primary700, // 선택된 탭 밑줄
            width: 1.5,
          ),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: const Color(0xFF000000),
        unselectedLabelColor: AppColors.gray700,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'Pretendard',
          letterSpacing: -0.14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          fontFamily: 'Pretendard',
          letterSpacing: -0.14,
        ),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
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


// /// “최신 | 인기” 언더라인 스위치
// class SortSwitch extends StatelessWidget {
//   final int index; // 0: 최신, 1: 인기
//   final ValueChanged<int> onChanged;
//
//   const SortSwitch({
//     super.key,
//     required this.index,
//     required this.onChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 40,
//       color: AppColors.primary50,
//       child: Row(
//         children: [
//           // ▶ 최신 탭
//           Expanded(
//             child: InkWell(
//               onTap: () => onChanged(0),
//               splashColor: Colors.transparent,
//               highlightColor: Colors.transparent,
//               child: Container(
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                   border: Border(
//                     bottom: BorderSide(
//                       color: index == 0
//                           ? AppColors.gray800
//                           : AppColors.gray200,
//                       width: index == 0 ? 1.5 : 1,
//                     ),
//                   ),
//                 ),
//                 child: Text(
//                   '최신',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: index == 0
//                         ? const Color(0xFF000000) // 선택됨: 검정
//                         : AppColors.gray700,      // 비선택: 회색
//                   ),
//                 ),
//               ),
//             ),
//           ),
//
//           // ▶ 인기 탭
//           Expanded(
//             child: InkWell(
//               onTap: () => onChanged(1),
//               splashColor: Colors.transparent,
//               highlightColor: Colors.transparent,
//               child: Container(
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                   border: Border(
//                     bottom: BorderSide(
//                       color: index == 1
//                           ? AppColors.gray800
//                           : AppColors.gray200,
//                       width: index == 1 ? 1.5 : 1,
//                     ),
//                   ),
//                 ),
//                 child: Text(
//                   '인기',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: index == 1
//                         ? const Color(0xFF000000) // 선택됨: 검정
//                         : AppColors.gray700,      // 비선택: 회색
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


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
///오직완 부분
class _PostList extends StatelessWidget {
  final bool isOnlywan;
  final int sortIndex;
  final String teamCode;
  final String teamLabel;
  const _PostList({required this.sortIndex, required this.teamCode, required this.teamLabel, this.isOnlywan = false,  });

  @override
  Widget build(BuildContext context) {
    // 정렬에 따라 더미 데이터 순서만 살짝 바꿔보기
    final data = List<_Post>.from(_posts);
    if (sortIndex == 1) {
      data.sort((a, b) => (b.likes + b.comments).compareTo(a.likes + a.comments));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16,8 ),
      itemBuilder: (_, i) {
        final p = data[i];
        return _PostTile(
          isOnlywan: isOnlywan,
          nickname: p.nickname,
          time: p.time,
          title: p.title,
          snippet: p.snippet,
          likes: p.likes,
          comments: p.comments,
          mediaWidth: p.mediaWidth,          // ✅
          mediaHeight: p.mediaHeight,        // ✅ (추가)
          badge: i == 1 ? 5 : null,
          onTap: () {
            context.push('/boards/$teamCode/post/${p.id}',
              extra: {'teamLabel': teamLabel},
            );
          },
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
  final VoidCallback? onTap;
  final bool isOnlywan;
  final double mediaWidth;
  final double mediaHeight;

  const _PostTile({
    super.key,
    required this.isOnlywan,
    required this.nickname,
    required this.time,
    required this.title,
    required this.snippet,
    required this.likes,
    required this.comments,
    required this.mediaWidth,
    required this.mediaHeight,
    this.badge,
    this.onTap,
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

  void _openCommentsSheet({required bool hasComments}) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _CommentsBottomSheet(
        postId: 0, // TODO: 실제 postId 넘겨도 됨
        hasComments: hasComments,
        initialCount: widget.comments,
      ),
    );
  }


  // ✅ 비율 → 타겟 프레임(AspectRatio) 변환
  double _targetAspectRatio(double w, double h) {
    final ratio = w / h;
    if (ratio >= 1.25) {
      return 358 / 266; // 거의 4:3
    } else if (ratio <= 0.85) {
      return 3 / 4;     // 0.75
    } else {
      return 1.0;       // 1:1
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 오직완(0번 탭) 전용 카드
    if (widget.isOnlywan) {
      final ar = _targetAspectRatio(widget.mediaWidth, widget.mediaHeight);

      return Material(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단: 아바타/닉네임/시간/더보기
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 30, height: 30,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE5E7EB),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.nickname,
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.gray800,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Pretendard',
                              letterSpacing: -0.14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.time, // ex) '3분전'
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.gray700,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Pretendard',
                              letterSpacing: -0.12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    SvgPicture.asset(
                      'assets/icons/board_dots.svg',
                      width: 26,
                      height: 17.3,

                    ),

                  ],
                ),

                const SizedBox(height: 12),

                // ✅ 큰 이미지 영역 (비율 프레임: 4:3 / 3:4 / 1:1)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: ar,
                    child: Container(
                      color: const Color(0xFFE5E7EB),
                      // TODO: 실제 이미지가 있으면 Image.network(..., fit: BoxFit.cover)
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 본문 1줄 (피그마: 이미지 아래 본문만 1줄)
                Text(
                  widget.snippet,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.gray900,
                    fontFamily: 'Pretendard',
                    letterSpacing: -0.14,
                  ),
                ),

                const SizedBox(height: 12),

                // 하단 메트릭: 좋아요 / 댓글 / 북마크
                Row(
                  children: [
                    InkWell(
                      onTap: _toggleLike,
                      borderRadius: BorderRadius.circular(4),
                      child: SvgPicture.asset(
                        _liked ? 'assets/icons/Heart_fill.svg' : 'assets/icons/Heart.svg',
                        width: 20.571, height: 18,

                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('$_likeCount', style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.gray800, fontFamily: 'Pretendard',letterSpacing: -0.15,
                    )),

                    const SizedBox(width: 20),
                    // ✅ 댓글 아이콘 + 숫자 탭 → 바텀시트
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _openCommentsSheet(hasComments: widget.comments > 0),
                      child: Row(
                        children: [
                          SvgPicture.asset('assets/icons/comment.svg', width: 19, height: 19),
                          const SizedBox(width: 8),
                          Text('${widget.comments}', style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500,
                            color: AppColors.gray800, fontFamily: 'Pretendard', letterSpacing: -0.15,
                          )),
                        ],
                      ),
                    ),

                    const SizedBox(width: 20),
                    SvgPicture.asset('assets/icons/bookmark.svg', width: 16, height: 16),
                    const SizedBox(width: 8),
                    const Text('2', style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.gray800, fontFamily: 'Pretendard',letterSpacing: -0.15,
                    )),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: widget.onTap,
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 프로필 이미지 (기본 회색 원)
                        Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE5E7EB),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),

                        // 닉네임 + 시간 (세로 정렬)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.nickname,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.gray800,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Pretendard',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.time,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.gray700,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Pretendard',
                              ),
                            ),
                          ],
                        ),
                      ],
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
                    width: 85,
                    height: 85,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  if (widget.badge != null)
                    Positioned(
                      right: 5,
                      bottom:4,
                      child: Container(
                        width: 20,
                        height: 20,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF9E9E9E),
                          borderRadius: BorderRadius.circular(4),

                        ),
                        child: Text(
                          '${widget.badge}',
                          style: const TextStyle(
                            color: AppColors.gray300,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
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
  final int id;
  final String nickname, time, title, snippet;
  final int likes, comments;
  final double mediaWidth;
  final double mediaHeight;

  _Post(this.id, this.nickname, this.time, this.title, this.snippet, this.likes, this.comments,
      {
        required this.mediaWidth,
        required this.mediaHeight,
      }
      );
} // ← 클래스 닫기 꼭!

final _posts = <_Post>[
  // 가로형 (ratio >= 1.25) → 4:3 프레임
  _Post(
    1,
    '닉네임 및 자까진 되더라',
    '3분전',
    '제목_공백 포함 최대 20자까지 가능',
    '본문은 보여지는 건 최대 24자까지 가능',
    23, 22,
    mediaWidth: 1600, mediaHeight: 900,
  ),
  // 정사각형 (사이값) → 1:1 프레임
  _Post(
    22,
    '닉네임 및 자까진 되더라',
    '3분전',
    '제목_공백 포함 최대 20자까지 가능',
    '본문은 보여지는 건 최대 24자까지 가능',
    7, 3,
    mediaWidth: 1000, mediaHeight: 1000,
  ),
  // 세로형 (ratio <= 0.85) → 3:4 프레임
  _Post(
    33333,
    '닉네임 및 자까진 되더라',
    '3분전',
    '제목_공백 포함 최대 20자까지 가능',
    '본문은 보여지는 건 최대 24자까지 가능',
    4, 1,
    mediaWidth: 800, mediaHeight: 1400,
  ),
];



Widget communityHeader(
    BuildContext context,
    String title, {
      required int sectionIndex, // ✅ 추가
    }) {
  return Container(
    height: 56,
    color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 17),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 🔙 뒤로가기 버튼
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).pop(),
          child: SvgPicture.asset(
            'assets/icons/back_but.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(
              Color(0xFF9A9A9A), // 회색 화살표
              BlendMode.srcIn,
            ),
          ),
        ),
        const SizedBox(width: 10),

        // 🏷 팀 이름 (왼쪽 정렬)
        Text(
          title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w400,
            fontFamily: 'MBC1961GulimOTF',
            letterSpacing: -0.26,
            color: AppColors.gray900,
          ),
        ),

        const Spacer(),

        // 🔍 검색 + 🔔 알림 아이콘
        Row(
          children: [
            // 🔍 검색 아이콘
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (sectionIndex == 2) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CommunitySearchMarket()),
                  );
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CommunitySearchPage()),
                  );
                }
              },
              child: SvgPicture.asset(
                'assets/icons/search.svg',
                width: 33,
                colorFilter: const ColorFilter.mode(
                  Colors.black,
                  BlendMode.srcIn,
                ),
              ),
            ),

            const SizedBox(width: 16),

            // 🔔 알림 아이콘 (터치 가능)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AlarmPage()), // ✅ 이동 경로
                );
              },
              child: SvgPicture.asset(
                'assets/icons/Alarm.svg',
                width: 19,
                colorFilter: const ColorFilter.mode(
                  Colors.black,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
// ==========================================
// BottomSheet: PostDetailPage 댓글 UI "그대로" 사용
// ==========================================
class _CommentsBottomSheet extends StatefulWidget {
  final int postId;
  final bool hasComments;
  final int initialCount;

  const _CommentsBottomSheet({
    super.key,
    required this.postId,
    required this.hasComments,
    required this.initialCount,
  });

  @override
  State<_CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<_CommentsBottomSheet> {
  // ▼ PostDetail과 동일한 상태/모델 구성
  final Map<int, List<_Reply>> _replies = {}; // 댓글 index -> 대댓글 목록
  int? _activeReplyIndex;
  final _replyCtrl = TextEditingController();

  final _commentCtrl = TextEditingController();

  final List<_Comment> comments = [
    _Comment(
      nickname: '메롱',
      body: '아아',
      time: '10/24(화) 14:10',
      liked: false,
      likes: 1,
    ),
    _Comment(
      nickname: '박해민가면안되ㅡㄴㄴ데',
      body: '트중박이라고',
      time: '10/24(화) 14:13',
      liked: true,
      likes: 3,
    ),
  ];

  @override
  void dispose() {
    _commentCtrl.dispose();
    _replyCtrl.dispose();
    super.dispose();
  }

  // 댓글 1개 위젯 (PostDetail의 _commentItem과 동일 레이아웃)
  Widget _commentItem(_Comment c) {
    final idx = comments.indexOf(c);
    final bool isReplyingThis = _activeReplyIndex == idx;
    final List<_Reply> replies = _replies[idx] ?? const <_Reply>[];

    return Container(
      decoration: BoxDecoration(
        color: isReplyingThis ? AppColors.primary100 : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 닉네임 + 액션 박스
          Row(
            children: [
              const _AvatarSmall(),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  c.nickname,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray800,
                  ),
                ),
              ),
              Container(
                height: 24,
                padding: const EdgeInsets.symmetric(horizontal: 0),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 댓글 아이콘 → 대댓글 입력 열기
                    _IconButtonBox(
                      onTap: () {
                        setState(() {
                          _activeReplyIndex = idx;
                          _replyCtrl.clear();
                        });
                      },
                      child: SvgPicture.asset(
                        'assets/icons/board_comment.svg',
                        width: 14,
                        height: 12,
                        colorFilter: const ColorFilter.mode(
                            AppColors.gray400, BlendMode.srcIn),
                      ),
                    ),
                    _VBar(),
                    // 하트
                    _IconButtonBox(
                      onTap: () {
                        setState(() {
                          c.liked = !c.liked;
                          c.liked ? c.likes++ : c.likes--;
                        });
                      },
                      child: SvgPicture.asset(
                        'assets/icons/board_heart.svg',
                        width: 14,
                        height: 12,
                        colorFilter: ColorFilter.mode(
                          c.liked ? AppColors.primary700 : AppColors.gray400,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    _VBar(),
                    // 더보기 (세로 점 3개) → board_dots.svg로
                    _IconButtonBox(
                      onTap: () {}, // 신고/삭제 등 메뉴
                      child: SvgPicture.asset(
                        'assets/icons/board_dots.svg',
                        width: 14,
                        height: 14,
                        colorFilter: const ColorFilter.mode(
                            AppColors.gray400, BlendMode.srcIn),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),

          const SizedBox(height: 8),

          // 본문 (작성중 댓글 강조)
          Container(
            color: isReplyingThis ? AppColors.primary100 : Colors.transparent,
            child: Text(
              c.body,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.gray800,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            c.time,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.gray600,
              fontWeight: FontWeight.w500,
            ),
          ),

          // ▼ 대댓글 리스트
          if (replies.isNotEmpty) ...[
            const SizedBox(height: 12),
            Column(
              children: replies.map((r) {
                return Padding(
                  padding: const EdgeInsets.only(left: 0, bottom: 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ㄴ 가이드
                      Container(
                        width: 10,
                        height: 18,
                        margin: const EdgeInsets.only(right: 6, top: 4),
                        child: SvgPicture.asset(
                          'assets/icons/board_reply.svg',
                          width: 11,
                          height: 15,
                          colorFilter: const ColorFilter.mode(
                              AppColors.gray300, BlendMode.srcIn),
                        ),
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.nickname,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.gray800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              r.body,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.gray900,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              r.time,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.gray500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 대댓글 우측 액션 박스 (하트/더보기)
                      Container(
                        height: 24,
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        decoration: BoxDecoration(
                          color: AppColors.gray100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _IconButtonBox(
                              onTap: () {
                                // 필요 시 r.like 토글로 확장 가능
                              },
                              child: SvgPicture.asset(
                                'assets/icons/board_heart.svg',
                                width: 14,
                                height: 12,
                                colorFilter: const ColorFilter.mode(
                                    AppColors.gray400, BlendMode.srcIn),
                              ),
                            ),
                            _VBar(),
                            _IconButtonBox(
                              onTap: () {},
                              child: SvgPicture.asset(
                                'assets/icons/board_dots.svg',
                                width: 14,
                                height: 14,
                                colorFilter: const ColorFilter.mode(
                                    AppColors.gray400, BlendMode.srcIn),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // ====== 바텀시트 전체 UI ======
  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;


    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          ///TODO 이거 실제 폰 연결해서 키보드 올릴 때 올라오는지 봐야됨
          minHeight: MediaQuery.of(context).size.height * 0.668,
          maxHeight: MediaQuery.of(context).size.height * 0.668,
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF8F8F8F),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // 상단 타이틀
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16), // 상하 여백
              child: Center(
                child: Text(
                  '댓글',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Pretendard',
                    color: Color(0xFF000000),
                    letterSpacing: -0.16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),

            const Divider(height: 0.5, color: AppColors.gray200),

            // 내용
            Expanded(
              child: comments.isEmpty
                  ? _EmptyComment() // ← PostDetail과 동일 (board_bori.svg)
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 4),
                itemBuilder: (_, i) => _commentItem(comments[i]),
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemCount: comments.length,
              ),
            ),

            // 하단 입력바 (PostDetail과 동일)
            const Divider(height: 0.5, color: AppColors.gray200),

            (_activeReplyIndex == null)
                ? _CommentInputBar(
              controller: _commentCtrl,
              onPressed: () {
                final text = _commentCtrl.text.trim();
                if (text.isEmpty) return;
                setState(() {
                  comments.add(
                    _Comment(
                      nickname: '닉네임',
                      body: text,
                      time: '방금',
                      liked: false,
                      likes: 0,
                    ),
                  );
                  _commentCtrl.clear();
                });
              },
            )
                : _ReplyBottomBar(
              nickname: comments[_activeReplyIndex!].nickname,
              controller: _replyCtrl,
              onCancel: () => setState(() => _activeReplyIndex = null),
              onSubmit: () {
                final text = _replyCtrl.text.trim();
                if (text.isEmpty) return;
                final i = _activeReplyIndex!;
                setState(() {
                  final cur = List<_Reply>.from(_replies[i] ?? const []);
                  cur.add(_Reply(
                    nickname: '나나ㅏ나',
                    body: text.trim(),
                    time: '방금',
                    likes: 0,
                    liked: false,
                  ));
                  _replies[i] = cur;
                  _activeReplyIndex = null;
                  _replyCtrl.clear();
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ───────── PostDetail에서 쓰던 동일 보조 위젯/모델 ─────────

class _AvatarSmall extends StatelessWidget {
  const _AvatarSmall();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24, height: 24,
      decoration: const BoxDecoration(
          shape: BoxShape.circle, color: Color(0xFFE5E7EB)),
    );
  }
}

class _IconButtonBox extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  const _IconButtonBox({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(width: 36, height: 36, child: Center(child: child)),
    );
  }
}

class _VBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1, height: 16,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: AppColors.gray400,
    );
  }
}

class _Comment {
  final String nickname;
  final String body;
  final String time;
  int likes;
  bool liked;
  _Comment({
    required this.nickname,
    required this.body,
    required this.time,
    required this.liked,
    required this.likes,
  });
}

class _Reply {
  final String nickname;
  final String body;
  final String time;
  int likes;
  bool liked;
  _Reply({
    required this.nickname,
    required this.body,
    required this.time,
    this.likes = 0,
    this.liked = false,
  });
}

/// 댓글 없을 때 (PostDetail과 동일: board_bori.svg 사용)
class _EmptyComment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary50,
      padding: const EdgeInsets.only(top: 120),
      alignment: Alignment.center,
      child: Column(
        children: [
          SvgPicture.asset('assets/icons/board_bori.svg', width: 60, height: 60),
          const SizedBox(height: 24),
          const Text(
            '첫 번째 댓글을 남겨주세요!',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.gray600,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.16,
            ),
          ),
        ],
      ),
    );
  }
}

/// 대댓글 입력 모드 하단바 (PostDetail과 동일)
class _ReplyBottomBar extends StatelessWidget {
  final String nickname;
  final TextEditingController controller;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const _ReplyBottomBar({
    required this.nickname,
    required this.controller,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final hasText = controller.text.isNotEmpty;

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 안내줄
          Container(
            height: 37,
            margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEFEFEF),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12), topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '$nickname님에게 대댓글 남기는 중',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.gray500,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // 입력창
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 45,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: TextField
                      (
                      controller: controller,
                      cursorColor: AppColors.primary700,
                      onChanged: (_) => (context as Element).markNeedsBuild(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.gray800,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: '댓글을 입력하세요.',
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          color: AppColors.gray600,
                          fontWeight: FontWeight.w400,
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: onSubmit,
                            borderRadius: BorderRadius.circular(0),
                            child: Container(
                              height: 21.58,
                              width: 32,
                              decoration: BoxDecoration(
                                color: hasText
                                    ? AppColors.primary700
                                    : const Color(0xFFC0C0C0),
                                borderRadius: BorderRadius.circular(5.95),
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/icons/vector_board.svg',
                                  width: 9.39,
                                  height: 14.13,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.gray50,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        suffixIconConstraints:
                        const BoxConstraints(minWidth: 36, minHeight: 36),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 댓글 입력바 (PostDetail의 _CommentInputBar 그대로 쓸 수도 있지만
/// TeamBoard에서는 바텀시트용으로 기존 구현이 있으면 그걸 써도 OK)
class _CommentInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onPressed;
  const _CommentInputBar({required this.controller, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final hasText = controller.text.isNotEmpty;
    return SafeArea(
      top: false,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 45,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: TextField(
                  cursorColor: AppColors.primary700,
                  controller: controller,
                  onChanged: (_) => (context as Element).markNeedsBuild(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.gray800,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: '댓글을 입력하세요.',
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: AppColors.gray600,
                      fontWeight: FontWeight.w400,
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: onPressed,
                        borderRadius: BorderRadius.circular(0),
                        child: Container(
                          height: 21.58,
                          width: 32,
                          decoration: BoxDecoration(
                            color: hasText
                                ? AppColors.primary700
                                : const Color(0xFFC0C0C0),
                            borderRadius: BorderRadius.circular(5.95),
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/icons/vector_board.svg',
                              width: 9.39,
                              height: 14.13,
                              colorFilter: const ColorFilter.mode(
                                AppColors.gray50,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    suffixIconConstraints:
                    const BoxConstraints(minWidth: 36, minHeight: 36),
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

