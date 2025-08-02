import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inninglog/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _idController.addListener(_validateInput);
    _pwController.addListener(_validateInput);
  }

  void _validateInput() {
    setState(() {
      _isButtonEnabled =
          _idController.text.trim().isNotEmpty &&
              _pwController.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              const Text(
                '나만의 야구기록,\n이닝로그에 오신 걸\n환영합니다!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Pretendard',
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Image.asset(
                'assets/images/bori_onboard.jpg',
                height: 112.5,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _idController,
                decoration: InputDecoration(
                  filled: true, // 배경색 활성화
                  fillColor: AppColors.primary50,
                  hintText: '아이디',
                  hintStyle: const TextStyle(
                    color: Color(0xFF747475),
                    fontFamily: 'Pretendard',
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.black, // 원하는 색으로 변경
                      width: 1.5,
                    ),
                  ),

                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
              ),
              const SizedBox(height: 4),
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 4), // 텍스트박스 내부 여백과 맞추려면 12 또는 4 정도로 조절
                  child: Text(
                    '* 6~12자리 영문, 숫자로 입력해 주세요',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF747475),
                      fontWeight: FontWeight.w300,
                      fontFamily: 'Pretendard',
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
              ),

              const SizedBox(height: 16),
              TextField(
                controller: _pwController,
                decoration: InputDecoration(
                  filled: true, // 배경색 활성화
                  fillColor: AppColors.primary50,
                  hintText: '비밀번호',
                  hintStyle: const TextStyle(
                    color: Color(0xFF747475),
                    fontFamily: 'Pretendard',
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.black, // 원하는 색으로 변경
                      width: 1.5,
                    ),
                  ),

                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
              ),
              const SizedBox(height: 4),
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 4), // 텍스트박스 내부 여백과 맞추려면 12 또는 4 정도로 조절
                  child: Text(
                    ' * 숫자 4자리로 입력해 주세요',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF747475),
                      fontWeight: FontWeight.w300,
                      fontFamily: 'Pretendard',
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isButtonEnabled ? () {} : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isButtonEnabled
                        ? AppColors.primary700
                        : const Color(0xFFD3D3D3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFD9D9D9),
                    disabledForegroundColor: Colors.white,
                  ),
                  child: const Text(
                    '로그인',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  // 회원가입 페이지로 이동
                context.go('/signup');

                },
                child: const Text(
                  '회원가입하기',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Color(0xFF747475), // 회색
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
