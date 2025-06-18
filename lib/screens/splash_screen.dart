import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inninglog/navigation/main_navigation.dart';
import 'package:inninglog/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _switched = false;

  @override
  void initState() {
    super.initState();

    // 1.5초 후 배경 + 아이콘 + 글씨 전환
    Timer(const Duration(milliseconds: 1500), () {
      setState(() {
        _switched = true;
      });
    });

    // 3초 후 메인 화면으로 이동
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (_, __, ___) => const MainNavigation(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      color: _switched ? Colors.white : AppColors.primary700,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 로고
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              child: _switched
                  ? SvgPicture.asset(
                'assets/icons/splash_white.svg',
                key: const ValueKey('white'),
                width: 162,
              )
                  : SvgPicture.asset(
                'assets/icons/splash_green.svg',
                key: const ValueKey('green'),
                width: 162,
              ),
            ),

            const SizedBox(height: 20.38),

            // 텍스트
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 600),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w400,
                fontFamily: 'MBC1961GulimOTF',
                color: _switched ? AppColors.primary700 : Color(0xFF1A1A1A), // 반대로하기
              ),
              child: const Text('이닝로그'),
            ),
          ],
        ),
      ),
    );
  }
}
