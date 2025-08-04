import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inninglog/app_colors.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


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

  Future<void> _login() async {
    final userID = _idController.text.trim();
    final password = _pwController.text.trim();

    if (userID.isEmpty || password.isEmpty) return;

    final uri = Uri.parse('https://api.inninglog.shop/auth/login');
    final body = {
      'userID': userID,
      'password': password,
    };

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final memberId = data['memberId'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('member_id', memberId); // ✅ 멤버 ID 저장

        context.go('/home'); // 👈 홈이 아니라 온보딩6으로 가야지
// 라우트 이름은 상황에 따라 수정 가능
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        if (error['code'] == 'INVALID_PASSWORD') {
          _showDialog('비밀번호가 일치하지 않습니다.');
        } else {
          _showDialog('로그인 실패: ${error['message']}');
        }
      } else {
        _showDialog('알 수 없는 오류가 발생했습니다. (${response.statusCode})');
      }
    } catch (e) {
      _showDialog('네트워크 오류가 발생했습니다. ($e)');
    }
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
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
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                      color: AppColors.primary700, // 원하는 색으로 변경
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
                      color: AppColors.primary700,  // 원하는 색으로 변경
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
                  onPressed: _isButtonEnabled ? _login : null,
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
      ),
    );
  }
}
