import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app_colors.dart';

class OnboardingContentPage extends StatelessWidget {
  final String image;
  final String title;
  final String desc;

  const OnboardingContentPage({
    super.key,
    required this.image,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.primary50,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 57),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                fontFamily: 'Pretendard',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w400,
                color: AppColors.primary700,
                fontFamily: 'MBC1961GulimOTF',
              ),
            ),
            const SizedBox(height: 25),
            Image.asset(
              image,
              height: 238,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Text('❌ 이미지 로딩 실패');
              },
            ),

          ],
        ),
      ),
    );
  }
}
