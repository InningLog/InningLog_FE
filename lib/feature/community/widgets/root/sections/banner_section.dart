import 'package:flutter/material.dart';
import '../components/section_title.dart';
import '../components/banner_card.dart';

class BannerSection extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;

  const BannerSection({
    super.key,
    required this.title,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: title),
        const SizedBox(height: 8),
        BannerCard(imagePath: imagePath, onTap: onTap),
        // SizedBox(height: bottomSpacing),
      ],
    );
  }
}
