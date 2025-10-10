import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../app_colors.dart';
import '../widgets/common_header.dart';

class BoardPage extends StatelessWidget {
  const BoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3CC14B),
        onPressed: () {},
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const CommonHeader(title: '커뮤니티'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                children: [
                  // breadcrumb
                  Row(
                    children: [
                      const Text('팀 게시판',
                          style: TextStyle(
                            fontSize: 19,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w700,
                          )),
                      const SizedBox(width: 4),
                      SvgPicture.asset(
                        'assets/icons/month_right.svg',
                        width: 8,
                        height: 14,
                      ),
                      const SizedBox(width: 4),
                      const Text('두산 베어스 🐻',
                          style: TextStyle(
                            fontSize: 19,
                            color: Color(0xFF111827),
                            fontWeight: FontWeight.w700,
                          )),
                    ],
                  ),
                  const SizedBox(height: 10),

                  ///여기 뭔가가 들어가야 함

                  // 목록
                  ...List.generate(_posts.length, (i) {
                    final p = _posts[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PostTile(
                        nickname: p.nickname,
                        time: p.time,
                        title: p.title,
                        snippet: p.snippet,
                        likes: p.likes,
                        comments: p.comments,
                        badge: i == 1 ? 5 : null,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostTile extends StatelessWidget {
  final String nickname, time, title, snippet;
  final int likes, comments;
  final int? badge;

  const _PostTile({
    required this.nickname,
    required this.time,
    required this.title,
    required this.snippet,
    required this.likes,
    required this.comments,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // 텍스트 영역
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$nickname',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.gray800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$time',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.gray700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.1,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      snippet,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.favorite_border,
                            size: 16, color: Color(0xFF6B7280)),
                        const SizedBox(width: 4),
                        Text('$likes',
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF4B5563))),
                        const SizedBox(width: 12),
                        const Icon(Icons.mode_comment_outlined,
                            size: 16, color: Color(0xFF6B7280)),
                        const SizedBox(width: 4),
                        Text('$comments',
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF4B5563))),
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
                  if (badge != null)
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
                          border:
                          Border.all(color: Colors.white, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x29000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            )
                          ],
                        ),
                        child: Text(
                          '$badge',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
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
  _Post(this.nickname, this.time, this.title, this.snippet, this.likes, this.comments);
}

final _posts = <_Post>[
  _Post('닉네임 및 자까진 되더라', '2025/05/25(일) 11:02',
      '제목_공백 포함 최대 20자까지 가능', '본문은 보여지는 건 최대 24자까지 가능', 2, 2),
  _Post('닉네임 및 자까진 되더라', '2025/05/25(일) 11:02',
      '제목_공백 포함 최대 20자까지 가능', '본문은 보여지는 건 최대 24자까지 가능', 2, 2),
  _Post('닉네임 및 자까진 되더라', '2025/05/25(일) 11:02',
      '제목_공백 포함 최대 20자까지 가능', '본문은 보여지는 건 최대 24자까지 가능', 2, 2),
];
