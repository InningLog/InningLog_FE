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



import '../app_colors.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;


  void loginWithKakaoWeb() async {
    if (!kIsWeb) return; // 웹이 아니면 리턴

    const kakaoLoginUrl =
        'https://kauth.kakao.com/oauth/authorize'
        '?response_type=code'
        '&client_id=293f7036654f2a9155a87e05f84b2d7e'
        '&redirect_uri=https://api.inninglog.shop/callback';

    final uri = Uri.parse(kakaoLoginUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print('❌ 카카오 로그인 URL 실행 실패');
    }
  }


Future<void> _saveToken(String jwt) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('access_token', jwt);
  print('🪪 토큰 저장 완료');
}



  final List<Widget> _pages = const [
    OnboardingPage1(),
    OnboardingContentPage(
      image: 'assets/images/onboard_2.svg',
      title: '나의 직관 통계,',
      desc: '직관 리포트',
    ),
    OnboardingContentPage(
      image: 'assets/images/onboard_3.svg',
      title: '직관의 추억을',
      desc: '일지 쓰기',
    ),
    OnboardingContentPage(
      image: 'assets/images/onboard_4.svg',
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

  // @override
  // void initState() {
  //   super.initState();
  //
  //   final uri = Uri.base;
  //   final fragment = uri.fragment; // ← 여기서 파라미터가 옴
  //   print('🟡 fragment: $fragment');
  //
  //   final fragUri = Uri.parse('https://dummy.com/$fragment'); // dummy 붙여서 파싱
  //   final jwt = fragUri.queryParameters['jwt']; // 카카오 로그인 후 주소에 있을 수도 있음
  //   final isNewUser = fragUri.queryParameters['isNewUser']; // ✅ 이거 체크
  //   final nickname = fragUri.queryParameters['nickname'];
  //
  //   if (jwt != null) {
  //     _saveToken(jwt); // 이건 그대로 유지
  //   }
  //
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     if (!mounted) return;
  //
  //     if (isNewUser == 'true') {
  //       context.go('/onboarding6'); // 신규 회원 → 닉네임/응원팀 선택
  //     } else {
  //       context.go('/home'); // 기존 회원 바로 홈
  //     }
  //   });
  // }




  @override
  Widget build(BuildContext context) {
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
          // //로그인 시발 터져서
          // ElevatedButton(
          //   onPressed: skipLoginForDebug,
          //   child: const Text('카카오 없이 시작하기 (디버그용)'),
          // ),




          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // //로그인 시발 터져서
  // Future<void> skipLoginForDebug() async {
  //   final prefs = await SharedPreferences.getInstance();
  //
  //   // ✅ 테스트용 토큰 (실제로 API 호출이 되려면 유효한 토큰이어야 함)
  //   await prefs.setString('access_token', 'test-token-for-user-2');
  //
  //   // ✅ userId 직접 저장 (필요한 경우)
  //   await prefs.setInt('user_id', 2);
  //
  //   print('🛠️ 테스트 유저로 로그인 우회 완료');
  //
  //   // ✅ 원하는 화면으로 이동
  //   if (!context.mounted) return;
  //   context.go('/home');
  // }



}

