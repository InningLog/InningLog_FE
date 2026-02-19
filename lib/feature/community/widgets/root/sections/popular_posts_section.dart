import 'package:flutter/material.dart';
import 'package:inninglog/feature/community/model/post_base.dart';
import 'package:inninglog/feature/community/widgets/root/components/popular_post_card.dart';
import 'package:inninglog/feature/community/widgets/root/components/section_title.dart';

class PopularPostsSection extends StatelessWidget {
  final List<PostBase> posts;
  final bool isLoading;
  final void Function(int postId) onTap;

  const PopularPostsSection({
    super.key,
    required this.posts,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: '인기 게시물'),
        const SizedBox(height: 8),
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(),
            ),
          )
        else if (posts.isEmpty)
          const SizedBox.shrink()
        else
          for (final post in posts) ...[
            PopularPostCard(
              post: post,
              onTap: () => onTap(post.postId),
            ),
            if (post != posts.last) const SizedBox(height: 8),
          ],
      ],
    );
  }
}
