import 'package:flutter/material.dart';
import 'package:inninglog/feature/community/model/post_preview.dart';
import 'package:inninglog/feature/community/widgets/root/components/popular_post_card.dart';
import 'package:inninglog/feature/community/widgets/root/components/section_title.dart';

class PopularPostsSection extends StatelessWidget {
  final VoidCallback onTap;
  const PopularPostsSection({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final posts = <PostPreview>[
      PostPreview(
        title: '제목_공백 포함 최대 20자까지 가능',
        preview: '본문 보이는 건 최대 24자 그 이상은 …',
        dateTime: '10/26 09:07',
        likeCount: 12,
        commentCount: 8,
        bookmarkCount: 3,
      ),

      PostPreview(
        title: '제목_공백 포함 최대 20자까지 가능',
        preview: '본문 보이는 건 최대 24자 그 이상은 …',
        dateTime: '10/26 09:07',
        likeCount: 12,
        commentCount: 8,
        bookmarkCount: 3,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SectionTitle(title: '인기 게시물'),
            GestureDetector(
              onTap: onTap,
              child: const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final post in posts) ...[
          PopularPostCard(post: post),
          if (post != posts.last) const SizedBox(height: 8),
        ],
      ],
    );
  }
}
