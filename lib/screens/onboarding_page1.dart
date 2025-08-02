import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingPage1 extends StatelessWidget {
  const OnboardingPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 39),
          const Text(
            '나만의 야구기록,\n이닝로그에 오신 걸\n환영합니다!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 50),
          Image.asset(
            'assets/images/bori_onboard.jpg',
            height: 112.5,
            fit: BoxFit.contain,
          ),

          const SizedBox(height: 19.5),

          const Text(
            '이름: 보리\n* 직관 많이 다녀서 꼬질꼬질 해짐',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, color: Colors.black, fontFamily: 'omyu pretty.ttf'),
          ),
        ],
      ),
    );
  }
}
