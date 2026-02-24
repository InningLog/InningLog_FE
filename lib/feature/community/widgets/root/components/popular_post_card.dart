import 'package:flutter/material.dart';
import 'package:inninglog/feature/community/model/post_base.dart';
import 'package:inninglog/feature/community/widgets/post/post_action_counts.dart';
import 'package:inninglog/feature/community/widgets/post/post_texts.dart';
import 'package:inninglog/shared/theme/app_colors.dart';
import 'package:inninglog/shared/utils/date_time_utils.dart';
import 'package:inninglog/shared/utils/image_url_utils.dart';

class PopularPostCard extends StatelessWidget {
  final PostBase post;
  final VoidCallback onTap;

  const PopularPostCard({required this.post, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: PostTitle(text: post.title, isPreview: true),
                      ),
                      const SizedBox(width: 8),
                      PostDateTimeText(
                        text: DateTimeUtils.formatToKoreanDateTime(
                          post.postAt ?? '',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  PostBody(text: post.content, isPreview: true),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      LikeCount(count: post.likeCount),
                      const SizedBox(width: 11),
                      CommentCount(count: post.commentCount),
                      const SizedBox(width: 11),
                      ScrapCount(count: post.scrapCount),
                    ],
                  ),
                ],
              ),
            ),
            if (post.thumbImageUrl != null &&
                post.thumbImageUrl!.isNotEmpty) ...[
              const SizedBox(width: 10),
              _ThumbImage(
                imageUrl: post.thumbImageUrl!,
                imageCount: post.imageCount,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ThumbImage extends StatefulWidget {
  final String imageUrl;
  final int imageCount;

  const _ThumbImage({required this.imageUrl, required this.imageCount});

  @override
  State<_ThumbImage> createState() => _ThumbImageState();
}

class _ThumbImageState extends State<_ThumbImage> {
  late String _currentImageUrl;
  bool _triedOriginalFallback = false;
  bool _fallbackScheduled = false;

  @override
  void initState() {
    super.initState();
    _currentImageUrl = widget.imageUrl;
  }

  @override
  void didUpdateWidget(covariant _ThumbImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _currentImageUrl = widget.imageUrl;
      _triedOriginalFallback = false;
      _fallbackScheduled = false;
    }
  }

  void _fallbackToOriginalIfNeeded(Object error) {
    if (_triedOriginalFallback || _fallbackScheduled) return;
    if (error is! NetworkImageLoadException || error.statusCode != 403) return;

    final originalUrl = originalImageUrlFromThumb(widget.imageUrl);
    if (originalUrl == null || originalUrl == _currentImageUrl) return;

    _fallbackScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _currentImageUrl = originalUrl;
        _triedOriginalFallback = true;
        _fallbackScheduled = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 64,
        height: 64,
        child: Image.network(
          _currentImageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            _fallbackToOriginalIfNeeded(error);
            return const SizedBox.expand();
          },
        ),
      ),
    );
  }
}
