import 'package:flutter/material.dart';
import '../components/section_title.dart';
import '../components/banner_card.dart';

class BannerSection extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;
  final EdgeInsetsGeometry padding;
  final double bottomSpacing;

  const BannerSection({
    super.key,
    required this.title,
    required this.imagePath,
    required this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.bottomSpacing = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title),
        const SizedBox(height: 8),
        Padding(
          padding: padding,
          child: BannerCard(imagePath: imagePath, onTap: onTap),
        ),
        SizedBox(height: bottomSpacing),
      ],
    );
  }
}
