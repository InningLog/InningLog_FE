import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:inninglog/navigation/main_navigation.dart';
import 'package:inninglog/screens/onboarding_page1.dart';
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








  final List<Widget> _pages = const [
    OnboardingPage1(),
    OnboardingContentPage(
      image: 'assets/images/onboarding_1.jpg',
      title: '나의 직관 통계,',
      desc: '직관 리포트',
    ),
    OnboardingContentPage(
      image: 'assets/images/onboarding_2.jpg',
      title: '직관의 추억을',
      desc: '일지 쓰기',
    ),
    OnboardingContentPage(
      image: 'assets/images/onboarding_3.jpg',
      title: '구장 별 좌석을 보고 싶을 땐,',
      desc: '구장 보기',
    ),
    OnboardingContentPage(
      image: 'assets/images/onvoarding_4.jpg',
      title: '야구장 꿀팁 없나?,',
      desc: '커뮤니티',
    ),
  ];


  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      context.go('/login');

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
          const SizedBox(height: 81),
          if (_currentPage != _pages.length )
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary600,
                  side: const BorderSide(color: AppColors.primary600),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text('다음',
                  style: TextStyle(fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Pretendard',),),
              ),
            ),
          // if (_currentPage == 4)
          //   Padding(
          //     padding: const EdgeInsets.symmetric(horizontal: 24.0),
          //     child: GestureDetector(
          //       child: SvgPicture.asset(
          //         'assets/icons/kakao_button.svg',
          //         height: 54,
          //       ),
          //     ),
          //   ),


          const SizedBox(height: 30),
        ],
      ),
    );
  }





}

