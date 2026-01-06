import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inninglog/shared/constant/team_codes.dart';
import 'package:inninglog/shared/theme/app_colors.dart';

class PostDetailPage extends StatefulWidget {
  final String teamCode;
  final int postId;

  const PostDetailPage({
    super.key,
    required this.teamCode,
    required this.postId,
  });

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  // ▼ 대댓글 상태 저장 (기존 코드 보존)
  final Map<int, List<_Reply>> _replies = {}; // 댓글 index -> 대댓글 목록
  final Set<int> _replying = {}; // 대댓글 입력창 열려있는 댓글 index

  int? _activeReplyIndex;
  final _replyCtrl = TextEditingController();

  // 상태
  bool liked = false;
  int likeCount = 20;

  bool scrapped = false;
  int scrapCount = 0;

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

  @override
  Widget build(BuildContext context) {
    final teamLabel = teamLabelFromCode(widget.teamCode);
    final commentCount = comments.length;

    return Scaffold(
      backgroundColor: AppColors.primary50,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leadingWidth: 54,
          leading: IconButton(
            icon: SvgPicture.asset(
              'assets/icons/back_but.svg',
              width: 10,
              height: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Column(
            children: [
              const Text(
                '자유 게시판',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                teamLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray700,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: SvgPicture.asset('assets/icons/board_dots.svg', width: 18),
              onPressed: () {},
            ),
          ],
        ),
      ),

      // 하단 입력바 (디자인 유지)
      bottomNavigationBar:
          (_activeReplyIndex == null)
              // 기본 댓글 입력창
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
              // ✅ 대댓글 모드일 때
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

      body: ListView(
        children: [
          _postHeader(),
          // ✅ 액션 바: 한 군데만 존재
          _ActionBar(
            likeActive: liked,
            likeCount: likeCount,
            onTapLike: () {
              setState(() {
                liked = !liked;
                liked ? likeCount++ : likeCount--;
              });
            },
            scrapActive: scrapped,
            scrapCount: scrapCount,
            onTapScrap: () {
              setState(() {
                scrapped = !scrapped;
                scrapped ? scrapCount++ : scrapCount--;
              });
            },
            commentCount: commentCount,
          ),
          const Divider(height: 8, color: AppColors.gray200),
          // 댓글은 고정 노출(토글 X)
          if (comments.isEmpty)
            _EmptyComment()
          else
            ...comments.map(_commentItem),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  //게시판
  Widget _postHeader() {
    return Container(
      color: AppColors.primary50,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 작성자
          Row(
            //작성자 프사 -> 어차피 바꿀거라
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFE5E7EB),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '디디는디디',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.gray800,
                    ),
                  ),
                  SizedBox(height: 0),
                  Text(
                    '05/25(일) 11:02',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.gray700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          const Text(
            '강백호 ㅇㄷ 갈거가틈',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: AppColors.gray850,
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'ㅈㄱㄴ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.gray900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _commentItem(_Comment c) {
    // ▼ 리스트 밖에서 사전 계산 (컴파일 에러 원인 제거)
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
              // 옆 댓글하트박스
              Container(
                height: 24,
                padding: const EdgeInsets.symmetric(horizontal: 0),
                decoration: BoxDecoration(
                  color: AppColors.gray100, // 연한 회색 배경
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 댓글 아이콘 (항상 회색) → 대댓글 입력 열기
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

                    // 하트 (토글 색상)
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

                    // 더보기 (세로 점 3개)
                    _IconButtonBox(
                      onTap: () {}, // 신고/삭제 등 메뉴 오픈
                      child: const Icon(
                        Icons.more_vert,
                        size: 14,
                        color: AppColors.gray400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 원댓글 본문 (작성중이면 하이라이트)
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
                      padding: const EdgeInsets.only(
                        left: 0,
                        bottom: 0,
                      ), // 들여쓰기
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ㄴ 모양 가이드
                          Container(
                            width: 10,
                            height: 18,
                            margin: const EdgeInsets.only(
                              right: 0,
                              top: 4,
                              left: 0,
                            ),
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
                          Container(
                            height: 24,
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            decoration: BoxDecoration(
                              color: AppColors.gray100, // 연한 회색 배경
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 하트 (토글 색상)
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
                                      c.liked
                                          ? AppColors.primary700
                                          : AppColors.gray400,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),

                                _VBar(),

                                // 더보기 (세로 점 3개)
                                _IconButtonBox(
                                  onTap: () {}, // 신고/삭제 등 메뉴 오픈
                                  child: const Icon(
                                    Icons.more_vert,
                                    size: 14,
                                    color: AppColors.gray400,
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
}

/// ───────────────────────── 위젯들 ─────────────────────────

class _ActionBar extends StatelessWidget {
  final bool likeActive;
  final int likeCount;
  final VoidCallback onTapLike;

  final bool scrapActive;
  final int scrapCount;
  final VoidCallback onTapScrap;

  final int commentCount;

  const _ActionBar({
    required this.likeActive,
    required this.likeCount,
    required this.onTapLike,
    required this.scrapActive,
    required this.scrapCount,
    required this.onTapScrap,
    required this.commentCount,
  });

  String _labelWithCount(String base, int count) {
    // 0이면 숫자 미표시, 그 외엔 "base n"
    return count <= 0 ? base : '$base $count';
  }

  @override
  Widget build(BuildContext context) {
    const gray = Color(0xFFD3D3D3);

    return Container(
      color: AppColors.primary50,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        children: [
          // 공감
          Expanded(
            child: Center(
              child: _InlineAction(
                asset: 'assets/icons/board_heart.svg',
                color: likeActive ? AppColors.primary700 : AppColors.gray500,
                label: _labelWithCount('공감', likeCount),
                onTap: onTapLike,
                iconSize: 18, // ← 아이콘 크기
              ),
            ),
          ),

          // 댓글 (항상 회색, 숫자만 변화)
          Expanded(
            child: Center(
              child: _InlineAction(
                asset: 'assets/icons/board_comment.svg',
                color: AppColors.gray500,
                label: _labelWithCount('댓글', commentCount),
                onTap: null, // 눌러도 아무 동작 없음
                iconSize: 18,
              ),
            ),
          ),

          // 스크랩
          Expanded(
            child: Center(
              child: _InlineAction(
                asset: 'assets/icons/board_scrap.svg',
                color: scrapActive ? AppColors.primary700 : AppColors.gray500,
                label: _labelWithCount('스크랩', scrapCount),
                onTap: onTapScrap,
                iconSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineAction extends StatelessWidget {
  final String asset;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final double iconSize;

  const _InlineAction({
    required this.asset,
    required this.label,
    required this.color,
    required this.onTap,
    this.iconSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          asset,
          width: 16,
          height: 16,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );

    if (onTap == null) return content;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: content,
      ),
    );
  }
}

/// 댓글 없을 때
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
            ),
          ),
        ],
      ),
    );
  }
}

/// 댓글 입력바
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
                    // ✅ 텍스트필드 내부 오른쪽 버튼
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
                    // ✅ suffixIcon이 TextField 안쪽에 잘 맞게 패딩 조절
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

class _ElbowPainter extends CustomPainter {
  final Color color;
  const _ElbowPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final p =
        Paint()
          ..color = color
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke;
    final path =
        Path()
          ..moveTo(size.width - 1, 0)
          ..lineTo(size.width - 1, size.height - 6)
          ..lineTo(0, size.height - 6);
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ✅ 대댓글 입력 모드일 때 사용하는 하단바
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
              color: Color(0xFFEFEFEF),
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
          // 기존 입력창 그대로 재사용
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 45,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8F8),
                      borderRadius: const BorderRadius.only(
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
