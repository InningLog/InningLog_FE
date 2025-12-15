import 'package:flutter/material.dart';
import 'package:inninglog/feature/community/widgets/components/image_button.dart';

/// 상단 배너(내 팀 / KBO 전체)
class BannerCard extends StatelessWidget {
  final String imagePath;
  final VoidCallback? onTap;

  const BannerCard({super.key, required this.imagePath, this.onTap});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 343 / 88,
      child: ImageButton(imagePath: imagePath, borderRadius: 10, onTap: onTap),
    );
  }
}
