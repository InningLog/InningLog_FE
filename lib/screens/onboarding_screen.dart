import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:inninglog/navigation/main_navigation.dart';
import 'package:inninglog/screens/onboarding_page1.dart';
import 'package:inninglog/screens/onboarding_page5.dart';
import 'package:inninglog/screens/onboarding_content_page.dart';
import 'package:inninglog/screens/onboarding_page6.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html;




import '../app_colors.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    // if (kIsWeb) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     handleWebLoginRedirect(context);
    //   });
    // }
  }

  void loginWithKakaoWeb() async {
    if (!kIsWeb) return; // 웹이 아니면 리턴

    // 👉 로그인 시작 마킹
    html.window.sessionStorage['login_in_progress'] = 'true';


    const kakaoLoginUrl =
        'https://kauth.kakao.com/oauth/authorize'
        '?response_type=code'
        '&client_id=293f7036654f2a9155a87e05f84b2d7e'
        '&redirect_uri=https://api.inninglog.shop/callback';

    html.window.location.href = kakaoLoginUrl;

    // final uri = Uri.parse(kakaoLoginUrl);
    // if (await canLaunchUrl(uri)) {
    //   await launchUrl(uri, mode: LaunchMode.externalApplication);
    // } else {
    //   print('❌ 카카오 로그인 URL 실행 실패');
    // }
  }


  Future<void> _saveToken(String jwt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', jwt);
    print('🪪 토큰 저장 완료');
  }



  final List<Widget> _pages = const [
    OnboardingPage1(),
    OnboardingContentPage(
      image: 'assets/images/onboard_1.jpg',
      title: '나의 직관 통계,',
      desc: '직관 리포트',
    ),
    OnboardingContentPage(
      image: 'assets/images/onboard_2.jpg',
      title: '직관의 추억을',
      desc: '일지 쓰기',
    ),
    OnboardingContentPage(
      image: 'assets/images/onboard_3.jpg',
      title: '구장 별 좌석을 보고 싶을 땐,',
      desc: '구장 보기',
    ),
    OnboardingPage5(),
  ];


  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingPage6()),
      );
    }
  }


  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
            (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 36 : 15,
          height: 15,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? const Color(0xFF94C32C)  // 지금
                : const Color(0xFFE5F2C8), // 지금아님
            borderRadius: BorderRadius.circular(7.5),

          ),
        ),
      ),
    );
  }




    @override
    Widget build(BuildContext context) {
      if (kIsWeb && html.window.sessionStorage['login_in_progress'] == 'true') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          html.window.sessionStorage.remove('login_in_progress');
          handleWebLoginRedirect(context);
        });

    }

      return Scaffold(
      backgroundColor: AppColors.primary50,
      body: Column(
        children: [

          const SizedBox(height: 67),

          if (_currentPage > 0)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16), // 여백 조절 가능
                child: GestureDetector(
                  onTap: () {
                    _controller.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  },
                  child: SvgPicture.asset(
                    'assets/icons/back_but.svg',
                    height: 20,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),


          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _pages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) => _pages[index],

            ),
          ),
          _buildDots(),
          const SizedBox(height: 121),
          if (_currentPage != _pages.length - 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green,
                  side: const BorderSide(color: Colors.green),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text('다음'),
              ),
            ),
          if (_currentPage == 4)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: GestureDetector(
                onTap: loginWithKakaoWeb,
                child: SvgPicture.asset(
                  'assets/icons/kakao_button.svg',
                  height: 54,
                ),
              ),
            ),


          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void handleWebLoginRedirect(BuildContext context) async {
    if (!kIsWeb) return;

    final uri = Uri.parse(html.window.location.href);
    final isNewUser = uri.queryParameters['isNewUser'];
    final jwt = uri.queryParameters['accessToken']; // ✅ 주의: 'jwt'가 아니라 'accessToken'

    print('🔁 URL: $uri');
    print('🪪 토큰: $jwt');
    print('🆕 신규유저: $isNewUser');

    if (jwt != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', jwt);
      print('✅ access_token 저장 완료');
    }

    if (isNewUser == 'true') {
      context.go('/onboarding6');
    } else if (isNewUser == 'false') {
      context.go('/home');
    } else {
      print('❌ isNewUser 파라미터 없음');
    }
  }




}

