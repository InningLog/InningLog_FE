import 'package:flutter/material.dart';
import 'package:inninglog/shared/theme/app_colors.dart';

class PostImageGallery extends StatelessWidget {
  final List<String> imageUrls;

  /// 갤러리 높이 (고정)
  final double height;

  /// 모서리 라운드
  final double radius;

  const PostImageGallery({
    super.key,
    required this.imageUrls,
    this.height = 220,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final urls = imageUrls;
    if (urls.isEmpty) return const SizedBox.shrink();

    // ✅ 1장일 때는 그냥 단일 이미지
    if (urls.length == 1) {
      return _ImageCard(url: urls.first, height: height, radius: radius);
    }

    // ✅ 2장 이상: 가로 스크롤
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: urls.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          return SizedBox(
            width: MediaQuery.of(context).size.width - 32, // 기본 여백 고려
            child: _ImageCard(url: urls[i], height: height, radius: radius),
          );
        },
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  final String url;
  final double height;
  final double radius;

  const _ImageCard({
    required this.url,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final img = Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: height,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: AppColors.gray100,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (_, __, ___) {
        return Container(
          color: AppColors.gray100,
          alignment: Alignment.center,
          child: const Icon(
            Icons.broken_image_outlined,
            color: AppColors.gray500,
          ),
        );
      },
    );

    if (radius <= 0) return img;

    return ClipRRect(borderRadius: BorderRadius.circular(radius), child: img);
  }
}
