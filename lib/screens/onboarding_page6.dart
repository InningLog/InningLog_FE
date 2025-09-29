import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../analytics/AmplitudeFlutter.dart';
import '../app_colors.dart';
import '../main.dart';
import '../navigation/main_navigation.dart';
import 'home_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:inninglog/service/member_api.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'dart:convert';
import 'package:flutter/material.dart';

// /// 🧩 웹에서만 dart:html import
// // ignore: avoid_web_libraries_in_flutter
// import 'dart:html' as html;




class OnboardingPage6 extends StatefulWidget {
  const OnboardingPage6({super.key});

  @override
  State<OnboardingPage6> createState() => _OnboardingPage6State();
}

class _OnboardingPage6State extends State<OnboardingPage6> {
  final TextEditingController _nicknameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final int _maxLength = 10;
  String? _selectedTeam;

  //숏코드랑 매핑
  Map<String, String> teamShortCodes = {
    'LG 트윈스': 'LG',
    '두산 베어스': 'OB',
    'SSG 랜더스': 'SK',
    '한화 이글스': 'HH',
    '삼성 라이온즈': 'SS',
    'KT 위즈': 'KT',
    '롯데 자이언츠': 'LT',
    '기아 타이거즈': 'HT',
    'NC 다이노스': 'NC',
    '키움 히어로즈': 'WO',
  };



  final List<String> _teams = [
    '기아 타이거즈',
    '두산 베어스',
    '롯데 자이언츠',
    '삼성 라이온즈',
    '키움 히어로즈',
    '한화 이글스',
    'KT 위즈',
    'LG 트윈스',
    'NC 다이노스',
    'SSG 랜더스',
  ];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
    _saveDebugToken();

    // if (kIsWeb) {
    //   handleWebLoginRedirectFromOnboarding6(context);
    // }

  }

  // void handleWebLoginRedirectFromOnboarding6(BuildContext context) async {
  //   final currentUrl = html.window.location.href;
  //   if (!currentUrl.contains('/callback')) return;
  //
  //   try {
  //     final response = await html.HttpRequest.request(currentUrl, method: 'GET');
  //     final authorizationHeader = response.getResponseHeader('Authorization');
  //     final token = authorizationHeader?.replaceFirst('Bearer ', '');
  //
  //     if (token != null) {
  //       final prefs = await SharedPreferences.getInstance();
  //       await prefs.setString('access_token', token);
  //       print('🪪 토큰 저장 완료: $token');
  //     }
  //
  //     final json = jsonDecode(response.responseText!);
  //     final isNewUser = json['data']['newMember'];
  //
  //     if (isNewUser == false) {
  //       context.go('/home'); // 기존 유저는 바로 홈으로
  //     } else {
  //       print('🧑‍🎓 신규 유저, Onboarding6 진행 계속');
  //       // 그대로 페이지 유지 (Onboarding6 UI 보여주기)
  //     }
  //
  //     html.window.history.replaceState(null, '', '/');
  //   } catch (e) {
  //     print('⚠️ 로그인 처리 실패: $e');
  //   }
  // }


  void _saveDebugToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', 'token');
    print('🪪 테스트용 토큰 저장 완료');
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isButtonEnabled =
        _nicknameController.text.trim().isNotEmpty && _selectedTeam != null;
    bool isFocusedOrFilled =
        _focusNode.hasFocus || _nicknameController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.primary50,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 18),
            const Text(
              '닉네임을 입력해주세요!',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 24,
                fontFamily: 'Pretendard',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nicknameController,
              focusNode: _focusNode,
              maxLength: _maxLength,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                fontFamily: 'Pretendard',
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: isFocusedOrFilled
                    ? AppColors.primary50
                    : AppColors.gray100,
                hintText: '닉네임을 입력해주세요.',
                hintStyle: const TextStyle(
                  fontSize: 16,
                  color: AppColors.gray700,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Pretendard',
                ),
                counter: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '(${_nicknameController.text.length}/$_maxLength)',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.gray500,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.gray300),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.primary700),
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 38),
            const Text(
              '응원팀을 선택해주세요!',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 24,
                fontFamily: 'Pretendard',
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.zero,
                itemCount: _teams.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 169,
                  mainAxisExtent: 70,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 21,
                ),
                itemBuilder: (context, index) {
                  final team = _teams[index];
                  final isSelected = _selectedTeam == team;

                  return OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedTeam = team;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary600
                            : const Color(0xFFD3D3D3),
                      ),
                      backgroundColor: isSelected
                          ? AppColors.primary100
                          : AppColors.primary50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      team,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isButtonEnabled
                  ? () async {
                final nickname = _nicknameController.text.trim();
                final selectedTeam = _selectedTeam!;
                final shortCode = teamShortCodes[selectedTeam]!;

                // ✅ 이벤트 로깅은 그대로 유지
                await  AmplitudeFlutter.getInstance().logEvent('onboarding_complete', eventProperties: {
                  'nickname': nickname,
                  'team': selectedTeam,
                  'team_short_code': shortCode,
                  'category': 'User',
                  'action': 'setup_complete',
                });

                await  AmplitudeFlutter.getInstance().logEvent('enter_onboarding_nickname', eventProperties: {
                  'component': 'form_submit',
                  'nickname_length': nickname.length,
                  'nickname_value': nickname,
                  'importance': 'Medium',
                });

                await  AmplitudeFlutter.getInstance().logEvent('select_onboarding_team', eventProperties: {
                  'component': 'btn_click',
                  'team_name': selectedTeam,
                  'importance': 'Medium',
                });

                // ✅ 여기부터 새로 작성
                try {
                  final prefs = await SharedPreferences.getInstance();
                  final memberId = prefs.getInt('member_id');

                  if (memberId == null) {
                    throw Exception('memberId가 없습니다.');
                  }

                  final url = Uri.parse('https://api.inninglog.shop/member/setup?memberId=$memberId');

                  final response = await http.post(
                    url,
                    headers: {
                      'Content-Type': 'application/json',
                    },
                    body: jsonEncode({
                      'nickname': nickname,
                      'teamShortCode': shortCode,
                    }),
                  );

                  if (response.statusCode == 200) {
                    if (!mounted) return;
                    context.go('/home');
                  } else {
                    final resBody = jsonDecode(response.body);
                    throw Exception(resBody['message'] ?? '회원 설정 실패');
                  }
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
                  : null,



              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: isButtonEnabled
                    ? AppColors.primary700
                    : const Color(0xFFD3D3D3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(36),
                ),
              ),
              child: const Text(
                '이닝로그 시작하기',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  fontFamily: 'Pretendard',
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
