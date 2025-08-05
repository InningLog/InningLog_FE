import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inninglog/app_colors.dart';
import '../analytics/AmplitudeFlutter.dart'; // ✅ deviceId 전용 버전 불러오기

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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final amplitude = AmplitudeFlutter.getInstance();
      const amplitudeKey = String.fromEnvironment('AMPLITUDE_API_KEY');

      if (amplitudeKey.isNotEmpty) {
        await amplitude.init(amplitudeKey);
      } else {
        debugPrint('⚠️ AMPLITUDE_API_KEY is missing in Splash');
      }

      final uri = Uri.base;
      final isBridge = uri.fragment.startsWith('/bridge');

      if (isBridge) {
        debugPrint('🌉 /bridge 경로 → Splash 생략');
        return;
      }

      final accessToken = uri.queryParameters['accessToken'];
      final isNewUser = uri.queryParameters['isNewUser'];
      debugPrint('🌐 accessToken: $accessToken');
      debugPrint('🌐 isNewUser: $isNewUser');

      if (accessToken != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', accessToken);
        debugPrint('✅ accessToken 저장 완료');

        if (isNewUser == 'true') {
          context.go('/onboarding6');
        } else {
          context.go('/home');
        }
        return;
      }

      await _startSplashLogic();
    });
  }

  Future<void> _startSplashLogic() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() {
        _switched = true;
      });
    }

    await Future.delayed(const Duration(milliseconds: 1500));

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token != null) {
      context.go('/home');
      return;
    }

    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    if (!mounted) return;

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
