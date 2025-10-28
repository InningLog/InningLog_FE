import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inninglog/app_colors.dart';

class PostDetailArgs {
  final String teamCode;
  final String teamLabel;
  final int postId;
  const PostDetailArgs({
    required this.teamCode,
    required this.teamLabel,
    required this.postId,
  });
}

class PostDetailPage extends StatefulWidget {
  final PostDetailArgs args;
  const PostDetailPage({super.key, required this.args});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  // 상태
  bool liked = false;
  int agreeCount = 20;
  bool showComments = false;

  final _commentCtrl = TextEditingController();

  final List<_Comment> comments = [
    _Comment(
      nickname: '엘지우승가즈아',
      body: '한화꺼져',
      time: '10/24(화) 14:10',
      liked: false,
      likes: 1,
    ),
    _Comment(
      nickname: '신일즈를 숭배해',
      body: '문보경김현수언제까지 잘할건대대대대',
      time: '10/24(화) 14:13',
      liked: true,
      likes: 9,
    ),
  ];

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teamLabel = widget.args.teamLabel;

    return Scaffold(
      backgroundColor: AppColors.primary50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop(); // 뒤로가기 동작
          },
          child: SvgPicture.asset(
            'assets/icons/back_but.svg',
            width: 20,
            height: 10,
          ),
        ),
        title: const Text(
          '자유 게시판',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.more_horiz, color: Color(0xFF9CA3AF)),
          )
        ],
        // ▼ 피그마처럼 제목 아래 팀명
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(22),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              teamLabel,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ),
      ),

      // 하단 댓글 입력바
      bottomNavigationBar: _CommentInputBar(
        controller: _commentCtrl,
        onPressed: () {
          final text = _commentCtrl.text.trim();
          if (text.isEmpty) return;
          setState(() {
            comments.add(_Comment(
              nickname: '닉네임',
              body: text,
              time: '방금',
              liked: false,
              likes: 0,
            ));
            showComments = true;
            _commentCtrl.clear();
          });
        },
      ),

      body: CustomScrollView(
        slivers: [
          // 상단 작성자/본문
          SliverToBoxAdapter(child: _postHeader(teamLabel)),
          const SliverToBoxAdapter(
            child: Divider(height: 1, color: Color(0xFFE5E7EB)),
          ),

          // 공감/댓글 요약 바
          SliverToBoxAdapter(
            child: _ReactionSummaryBar(
              agreeCount: agreeCount,
              showAgree: (liked || agreeCount > 0),
              showCommentIcon: showComments,
            ),
          ),

          // 댓글 없을 때
          if (!showComments)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyComment(),
            ),

          // 댓글 있을 때
          if (showComments) _commentListSliver(),
        ],
      ),
    );
  }

  // ───────────────────────── UI 블록들 ─────────────────────────

  Widget _postHeader(String teamLabel) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 작성자 메타
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFE5E7EB),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '닉네임 / Head 9 (Sb) - 14pt',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '05/25(일) 11:02 / 시각 / Head 10(M) - 12pt',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 제목
          const Text(
            '제목_공백 포함 최대 20자까지 가능 / Head 5',
            style: TextStyle(
              fontSize: 18,
              height: 1.25,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),

          // 본문
          const Text(
            '내용 / Body 1 (16pt, Regular)\n최대 글자 공백 포함 1,500자 정도 하면 되겠지?',
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              fontWeight: FontWeight.w400,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),

          // 반응 버튼 (회색 배경, 아이콘 교체)
          Row(
            children: [
              _ReactionButtonSvg(
                asset: 'assets/icons/board_heart.svg',
                label: '공감',
                active: liked,
                activeColor: const Color(0xFF7BC21F),
                onTap: () {
                  setState(() {
                    liked = !liked;
                    liked ? agreeCount++ : agreeCount--;
                  });
                },
              ),
              const SizedBox(width: 12),
              _ReactionButtonSvg(
                asset: 'assets/icons/board_comment.svg', // 파일명이 정확히 이거라면 사용
                // 만약 파일명이 comment_board.svg 라면 위 라인을 'comment_board.svg'로 바꿔줘
                label: '댓글',
                active: false,
                onTap: null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _commentListSliver() {
    return SliverList.separated(
      itemCount: comments.length + 2,
      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFE5E7EB)),
      itemBuilder: (context, index) {
        if (index == 0) {
          // 댓글 상단 요약(“닉네임 / Head 10 ... 댓글 내용”)
          return Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: const [
                _AvatarSmall(),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '닉네임 / Head 10 (sb) - 12pt\n댓글 내용',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                ),
              ],
            ),
          );
        }
        if (index == comments.length + 1) return const SizedBox(height: 60);

        final c = comments[index - 1];
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 라인
              Row(
                children: [
                  const _AvatarSmall(),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      c.nickname,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  // 하트 + 개수 + 더보기
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() {
                          c.liked = !c.liked;
                          c.liked ? c.likes++ : c.likes--;
                        }),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: SvgPicture.asset(
                            'assets/icons/board_heart.svg',
                            colorFilter: ColorFilter.mode(
                              c.liked ? const Color(0xFF7BC21F) : const Color(0xFF9CA3AF),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${c.likes}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.more_horiz, size: 18, color: Color(0xFF9CA3AF)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                c.body,
                style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF111827)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(c.time, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 공감/댓글 요약 바 (피그마 가운데 화면)
class _ReactionSummaryBar extends StatelessWidget {
  final int agreeCount;
  final bool showAgree;
  final bool showCommentIcon;

  const _ReactionSummaryBar({
    required this.agreeCount,
    required this.showAgree,
    required this.showCommentIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          if (showAgree) ...[
            SizedBox(
              width: 18,
              height: 18,
              child: SvgPicture.asset(
                'assets/icons/board_heart.svg',
                colorFilter: const ColorFilter.mode(Color(0xFF7BC21F), BlendMode.srcIn),
              ),
            ),
            const SizedBox(width: 6),
            const Text('공감 ', style: TextStyle(fontSize: 13, color: Color(0xFF7BC21F), fontWeight: FontWeight.w600)),
            Text('$agreeCount', style: const TextStyle(fontSize: 13, color: Color(0xFF7BC21F), fontWeight: FontWeight.w600)),
          ],
          const Spacer(),
          if (showCommentIcon)
            Row(
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: SvgPicture.asset(
                    'assets/icons/board_comment.svg', // 파일명이 다르면 수정
                    colorFilter: const ColorFilter.mode(Color(0xFF9CA3AF), BlendMode.srcIn),
                  ),
                ),
                const SizedBox(width: 6),
                const Text('댓글', style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
              ],
            ),
        ],
      ),
    );
  }
}

/// 빈 댓글 상태(왼쪽 목업)
class _EmptyComment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 60),
          SizedBox(
            width: 88,
            height: 88,
            child: SvgPicture.asset('assets/icons/board_bori.svg'),
          ),
          const SizedBox(height: 12),
          const Text(
            '첫 번째 댓글을 남겨주세요!',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}

/// 댓글 입력 바 (하단 고정)
class _CommentInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onPressed;

  const _CommentInputBar({
    required this.controller,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.centerLeft,
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: '댓글로 의견을 남겨보세요.',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/board_vector.svg',
                    width: 18,
                    height: 18,
                    colorFilter: const ColorFilter.mode(Color(0xFF6B7280), BlendMode.srcIn),
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

/// 회색 배경 반응 버튼(SVG)
class _ReactionButtonSvg extends StatelessWidget {
  final String asset;
  final String label;
  final bool active;
  final VoidCallback? onTap;
  final Color activeColor;

  const _ReactionButtonSvg({
    required this.asset,
    required this.label,
    required this.active,
    required this.onTap,
    this.activeColor = const Color(0xFF111827),
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : const Color(0xFF9CA3AF);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              asset,
              width: 16,
              height: 16,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
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
      width: 26,
      height: 26,
      decoration: const BoxDecoration(
        color: Color(0xFFE5E7EB),
        shape: BoxShape.circle,
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
