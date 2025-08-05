import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inninglog/app_colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../analytics/AmplitudeFlutter.dart';



class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
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
      _isButtonEnabled = _idController.text.trim().isNotEmpty &&
          _pwController.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    super.dispose();
  }


  Future<void> _checkDuplicateID() async {
    final userID = _idController.text.trim();
    if (userID.isEmpty) return;

    final uri = Uri.parse('https://api.inninglog.shop/auth/check-id?userID=$userID');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final isDuplicate = json.decode(response.body) as bool;

        AmplitudeFlutter.getInstance().logEvent(
          'click_check_id_duplicate',
          eventProperties: {
            'event_type': 'Custom',
            'component': 'btn_click',
            'is_duplicatecd': isDuplicate, // Boolean
            'importance': 'High',
          },
        );
        if (isDuplicate) {
          _showDialog('이미 사용 중인 아이디입니다.');
        } else {
          _showDialog('사용 가능한 아이디입니다!');
        }
      } else {
        _showDialog('서버 오류가 발생했습니다. 다시 시도해주세요.');
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
  DateTime? _signupStartTime;

  Future<void> _signup() async {
    _signupStartTime = DateTime.now();

    final userID = _idController.text.trim();
    final password = _pwController.text.trim();

    if (userID.isEmpty || password.isEmpty) return;

    final uri = Uri.parse('https://api.inninglog.shop/auth/signup');
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
        // 가입 완료 시간 계산
        final durationSeconds = DateTime.now()
            .difference(_signupStartTime!)
            .inMilliseconds / 1000;

        // ✅ Amplitude 이벤트: 가입 완료
        AmplitudeFlutter.getInstance().logEvent(
          'click_signup_complete',
          eventProperties: {
            'event_type': 'Custom',
            'component': 'btn_click',
            'signup_duration_seconds': durationSeconds, // FLOAT
            'importance': 'High',
          },
        );

        // ✅ 자동 로그인 시도
        await _loginAfterSignup(userID, password);
      }

      else if (response.statusCode == 400) {
        final resBody = jsonDecode(response.body);
        if (resBody['code'] == 'EXIST_USERID') {
          _showDialog('이미 존재하는 아이디입니다.');
        } else {
          _showDialog('회원가입 실패: ${resBody['message']}');
        }
      } else {
        _showDialog('알 수 없는 오류가 발생했습니다. (${response.statusCode})');
      }
    } catch (e) {
      _showDialog('네트워크 오류가 발생했습니다. ($e)');
    }
  }

  Future<void> _loginAfterSignup(String userID, String password) async {
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

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final json = jsonDecode(response.body);
        final memberId = json['memberId'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('member_id', memberId ?? 0);

        // ✅ userId는 세팅하지 않고 device_id만 계속 사용
        debugPrint('📊 회원가입 후 로그인 완료 (deviceId로만 추적)');

        // ✅ 회원가입 성공 이벤트 로깅
        AmplitudeFlutter.getInstance().logEvent(
          'signup_success',
          eventProperties: {'signup_method': 'manual'},
        );

        context.go('/onboarding6');
      }
      else {
        _showDialog('회원가입 후 자동 로그인에 실패했습니다.');
      }
    } catch (e) {
      _showDialog('네트워크 오류: $e');
    }
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
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                  onPressed: () {
                    context.pop(); // 뒤로가기
                  },
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '회원 가입하고 시작해요!',
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
                onChanged: (value) {
                  // ✅ Amplitude 이벤트: 아이디 입력
                  AmplitudeFlutter.getInstance().logEvent(
                    'enter_signup_id',
                    eventProperties: {
                      'event_type': 'Recommended', // 요청한 대로 Recommended
                      'component': 'form_submit',
                      'id_length': value.length, // INT
                      'is_newuser': true, // 항상 true
                      'importance': 'High',
                    },
                  );
                },
                decoration: InputDecoration(
                  filled: true,
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
                      color: AppColors.primary700,
                      width: 1.5,
                    ),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
              ),
              const SizedBox(height: 4),
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text(
                    '* 6~12자리 영문, 숫자로 입력해 주세요',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF747475),
                      fontWeight: FontWeight.w300,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: _checkDuplicateID,

                    // TODO: 아이디 중복확인 기능
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD9D9D9),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: const Size(100, 32),
                  ),
                  child: const Text(
                    '중복 확인',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _pwController,
                onChanged: (value) {
                  // ✅ Amplitude 이벤트: 비밀번호 입력
                  AmplitudeFlutter.getInstance().logEvent(
                    'enter_signup_password',
                    eventProperties: {
                      'event_type': 'Custom',
                      'component': 'form_submit',
                      'password_length': value.length, // INT
                      'importance': 'High',
                    },
                  );
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.primary50,
                  hintText: '비밀 번호',
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
                      color: AppColors.primary700,
                      width: 1.5,
                    ),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
              ),
              const SizedBox(height: 4),
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text(
                    '* 숫자 4자리로 입력해 주세요',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF747475),
                      fontWeight: FontWeight.w300,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isButtonEnabled ? _signup : null,

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
                    '회원 가입',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Pretendard',
                    ),
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

