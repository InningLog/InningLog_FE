import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app_colors.dart';

class OnboardingPage5 extends StatelessWidget {
  const OnboardingPage5({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 77),
          const Text(
            '야구장 꿀팁 없나?',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              fontFamily: 'Pretendard',
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '커뮤니티',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w400,
              color: AppColors.primary700,
              fontFamily: 'MBC1961GulimOTF',
            ),
          ),
          const SizedBox(height: 35),
          SvgPicture.asset('assets/images/onboard_5.svg', height: 282),
        ],
      ),
    );
  }
}
