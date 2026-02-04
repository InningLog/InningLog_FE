import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:inninglog/feature/community/data/tabs_config.dart';
import 'package:inninglog/feature/community/data/team_catalog.dart';
import 'package:inninglog/feature/community/widgets/shared/segmented_tabs.dart';
import 'package:inninglog/router/app_routes.dart';
import 'package:inninglog/shared/theme/app_colors.dart';
import 'package:inninglog/feature/community/screens/post_detail_market.dart';
import 'package:inninglog/shared/widgets/common_header.dart';
import 'tabs/free_board_tab.dart';
import 'tabs/onlywan_tab.dart';

enum BoardMode { normal, myPosts, myComments, scraps }

class TeamBoardPage extends StatefulWidget {
  final String teamCode; // e.g. 'HT', 'LG', ...
  final BoardTab? activeTab;
  final BoardMode mode;

  const TeamBoardPage({
    super.key,
    required this.teamCode,
    this.activeTab,
    this.mode = BoardMode.normal,
  });

  @override
  State<TeamBoardPage> createState() => _TeamBoardPageState();
}

class _TeamBoardPageState extends State<TeamBoardPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final List<CommunityTabItem> _tabs;
  bool _isSyncingRoute = false;

  @override
  void initState() {
    super.initState();

    _tabs = communityTabsByMode(widget.mode);

    final safeIndex = _resolveTabIndex(widget.activeTab);

    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: safeIndex,
    );

    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TeamBoardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeTab != widget.activeTab) {
      final nextIndex = _resolveTabIndex(widget.activeTab);
      if (_tabController.index != nextIndex) {
        _isSyncingRoute = true;
        _tabController.index = nextIndex;
        _isSyncingRoute = false;
      }
    }
  }

  int _resolveTabIndex(BoardTab? tab) {
    final resolvedTab = tab ?? BoardTab.onlywan;
    final index = _tabs.indexWhere((item) => item.type == resolvedTab);
    if (index >= 0) return index;
    return 0;
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging || _isSyncingRoute) return;
    if (widget.mode != BoardMode.normal) return;
    final tabType = _tabs[_tabController.index].type;
    final tabPath = boardTabPath(tabType);
    context.go(AppRoutePaths.boardLocation(widget.teamCode, tab: tabPath));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary50,
      floatingActionButton: SizedBox(
        width: 56,
        height: 56,

        child: FloatingActionButton(
          backgroundColor: AppColors.primary700,
          shape: const CircleBorder(),
          onPressed: () {
            // 기존 게시판 글쓰기
            context.push(AppRoutePaths.boardPostWriteLocation(widget.teamCode));
            debugPrint('[Team Board Page] teamCode: ${widget.teamCode}');
          },
          child: const Icon(Icons.add, size: 40, color: AppColors.primary50),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // 상단 헤더 (뒤로가기 포함)
            CommonHeader(
              title:
                  widget.teamCode == 'ALL'
                      ? 'KBO 전체게시판'
                      : kboTeamLabelOf(widget.teamCode),
              onSearchPressed: () => context.push(AppRoutePaths.search),
            ),

            SegmentedTabs(controller: _tabController, items: _tabs),

            // 구분선
            const Divider(height: 1, thickness: 0.8, color: AppColors.gray400),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: List.generate(_tabs.length, (index) {
                  final tab = _tabs[index];
                  final isActive = index == _tabController.index;
                  switch (tab.type) {
                    case BoardTab.onlywan:
                      return OnlyWanTab(isActive: isActive);
                    case BoardTab.free:
                      return FreeBoardTab(
                        teamCode: widget.teamCode,
                        isActive: isActive,
                      );
                    case BoardTab.news:
                      return const Center(child: Text('오늘의 뉴스'));
                  }
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
                          AppColors.gray400,
                          BlendMode.srcIn,
                        ),
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
                          AppColors.gray400,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
              children:
                  replies.map((r) {
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
                                AppColors.gray300,
                                BlendMode.srcIn,
                              ),
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
                                      AppColors.gray400,
                                      BlendMode.srcIn,
                                    ),
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
                                      AppColors.gray400,
                                      BlendMode.srcIn,
                                    ),
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
              width: 36,
              height: 4,
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
              child:
                  comments.isEmpty
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
                      cur.add(
                        _Reply(
                          nickname: '나나ㅏ나',
                          body: text.trim(),
                          time: '방금',
                          likes: 0,
                          liked: false,
                        ),
                      );
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
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFE5E7EB),
      ),
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
      width: 1,
      height: 16,
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
          SvgPicture.asset(
            'assets/icons/board_bori.svg',
            width: 60,
            height: 60,
          ),
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
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
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
                    child: TextField(
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
                                color:
                                    hasText
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
                        suffixIconConstraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
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
                            color:
                                hasText
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
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
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

/// ============================
/// 🛒 이닝 장터 탭
/// ============================
class _InningMarketTab extends StatefulWidget {
  final String teamCode;
  final String teamLabel;

  const _InningMarketTab({
    super.key,
    required this.teamCode,
    required this.teamLabel,
  });

  @override
  State<_InningMarketTab> createState() => _InningMarketTabState();
}

class _InningMarketTabState extends State<_InningMarketTab> {
  bool showOnSaleOnly = false;

  @override
  Widget build(BuildContext context) {
    final posts = [
      {
        'status': '판매중',
        'title': '제목_공백 포함 최대 40자까지 가능 줄로 따지면 2줄까지 가능합니다',
        'comments': 2,
        'bookmarks': 2,
        'time': '3분 전',
        'onSale': true,
      },
      {
        'status': '판매완료',
        'title': '제목_공백 포함 최대 40자까지 가능 줄로 따지면 2줄까지 가능합니다',
        'comments': 2,
        'bookmarks': 2,
        'time': '3분 전',
        'onSale': false,
      },
      {
        'status': '판매완료',
        'title': '제목_공백 포함 최대 40자까지 가능 줄로 따지면 2줄까지 가능합니다',
        'comments': 2,
        'bookmarks': 2,
        'time': '3분 전',
        'onSale': false,
      },
      {
        'status': '판매중',
        'title': '제목_공백 포함 최대 40자까지 가능 줄로 따지면 2줄까지 가능합니다',
        'comments': 2,
        'bookmarks': 2,
        'time': '3분 전',
        'onSale': true,
      },
    ];

    final filtered =
        showOnSaleOnly
            ? posts.where((p) => p['onSale'] == true).toList()
            : posts;

    return Column(
      children: [
        // 🔹 고정 공지
        Container(
          width: double.infinity,
          color: AppColors.gray200,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: const Center(
            child: Text(
              '★필독★ 이닝 장터 규정',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.gray800,
                fontFamily: 'Pretendard',
                letterSpacing: -0.15,
              ),
            ),
          ),
        ),

        // 🔹 스위치 영역
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Row(
            children: [
              CustomMarketSwitch(
                value: showOnSaleOnly,
                onChanged: (v) => setState(() => showOnSaleOnly = v),
              ),
              const SizedBox(width: 6),
              const Text(
                '판매중인 상품만 보기',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.gray800,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Pretendard',
                  letterSpacing: -0.14,
                ),
              ),
            ],
          ),
        ),

        // 🔹 게시글 리스트
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            itemBuilder: (_, i) {
              final p = filtered[i];

              return Material(
                color: AppColors.primary50, // 배경 유지
                child: InkWell(
                  onTap: () {
                    context.pushNamed(
                      'post_detail_market',
                      extra: PostDetailMarketArgs(
                        teamCode: widget.teamCode, // ex) 'LG', 'HT'
                        teamLabel: widget.teamLabel, // ex) 'LG 트윈스 👶🏻👶🏻'
                        postId: i + 1, // 더미 ID (나중에 실제 값으로 교체)
                      ),
                    );
                  },

                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary50,
                      borderRadius: BorderRadius.circular(0),
                      border: Border(
                        bottom: BorderSide(color: AppColors.gray200, width: 1),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Row(
                      children: [
                        // 왼쪽 텍스트
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 🔸 상태 배지
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      p['status'] == '판매중'
                                          ? AppColors.primary600
                                          : const Color(0xFFC0C0C0),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  p['status']!.toString(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary50,
                                    fontFamily: 'Pretendard',
                                    letterSpacing: -0.1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),

                              // 🔸 제목
                              Text(
                                p['title']!.toString(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.gray850,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Pretendard',
                                  letterSpacing: -0.16,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // 🔸 하단 정보 (댓글, 북마크, 시간)
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/comment.svg',
                                    width: 14.4,
                                    height: 14.4,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${p['comments']}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.gray700,
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: -0.12,
                                    ),
                                  ),
                                  const SizedBox(width: 11),
                                  SvgPicture.asset(
                                    'assets/icons/bookmark.svg',
                                    width: 14,
                                    height: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${p['bookmarks']}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.gray700,
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: -0.12,
                                    ),
                                  ),
                                  const SizedBox(width: 98.6),
                                  Text(
                                    p['time']!.toString(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.gray700,
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: -0.14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // 오른쪽 썸네일 (정사각형)
                        ///TODO 연동 후 분기처리
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: filtered.length,
          ),
        ),
      ],
    );
  }
}

//이닝장터 커스텀 스위치
class CustomMarketSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomMarketSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<CustomMarketSwitch> createState() => _CustomMarketSwitchState();
}

class _CustomMarketSwitchState extends State<CustomMarketSwitch> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 35,
        height: 21,
        padding: const EdgeInsets.symmetric(horizontal: 2.5),
        decoration: BoxDecoration(
          color:
              widget.value
                  ? const Color(0xFFAFD956) // 활성 시 연두
                  : const Color(0xFF8F8F8F), // 비활성 회색
          borderRadius: BorderRadius.circular(36.5),
        ),
        alignment: widget.value ? Alignment.centerRight : Alignment.centerLeft,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: 17.8,
          height: 18.2,
          decoration: BoxDecoration(
            color: AppColors.primary50,
            borderRadius: BorderRadius.circular(100), // 완전 둥글게
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                offset: const Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
