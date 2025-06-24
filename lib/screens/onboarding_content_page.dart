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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24,
                fontWeight: FontWeight.w600,
                fontFamily: 'Pretendard'),
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
          const SizedBox(height: 35),

          SvgPicture.asset(image, height: 282),

        ],
      ),
    );
  }
}
