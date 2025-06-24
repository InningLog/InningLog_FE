import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingPage5 extends StatelessWidget {
  const OnboardingPage5({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/images/onboard_5.svg', height: 200),
          const SizedBox(height: 32),
          const Text(
            '야구장 꿀팁 있나?\n커뮤니티',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          const Text(
            '커뮤니티 이미지\n추후 추가 예정\n(사이즈는 사각형 만큼)',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 36),
          ElevatedButton.icon(
            onPressed: () {
              // 카카오 로그인 또는 시작하기 연결
            },
            icon: const Icon(Icons.chat_bubble),
            label: const Text('5초 안에 카카오로 시작하기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFEE500),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
