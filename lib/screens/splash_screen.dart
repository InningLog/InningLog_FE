import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inninglog/navigation/main_navigation.dart';
import 'package:inninglog/screens/onboarding_screen.dart';
import 'package:inninglog/app_colors.dart';

import 'home_page.dart';

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
    _startSplashLogic();
  }

  void _startSplashLogic() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() {
        _switched = true;
      });
    }

    await Future.delayed(const Duration(milliseconds: 1500));

    final prefs = await SharedPreferences.getInstance();

    // 개발 중 계속 온보딩 보게 하려면 false)
    await prefs.setBool('hasSeenOnboarding', true);

    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? true;

    if (!mounted) return;

    // ✅ go_router 사용한 화면 전환
    if (hasSeenOnboarding) {
      context.go('/home');
    } else {
      context.go('/onboarding');
    }
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
            const SizedBox(height: 20),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 600),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w400,
                fontFamily: 'MBC1961GulimOTF',
                color: _switched ? AppColors.primary700 : const Color(0xFF1A1A1A),
              ),
              child: const Text('이닝로그'),
            ),
          ],
        ),
      ),
    );
  }
}
