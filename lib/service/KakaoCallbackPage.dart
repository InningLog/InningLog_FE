import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class KakaoCallbackPage extends StatefulWidget {
  const KakaoCallbackPage({super.key});

  @override
  State<KakaoCallbackPage> createState() => _KakaoCallbackPageState();
}

class _KakaoCallbackPageState extends State<KakaoCallbackPage> {
  @override
  void initState() {
    super.initState();
    _handleKakaoLogin();
  }

  Future<void> _handleKakaoLogin() async {
    final uri = Uri.base;
    final code = uri.queryParameters['code'];

    if (code == null) {
      print('❌ code 없음');
      return;
    }

    try {
      final res = await http.post(
        Uri.parse('https://api.inninglog.shop/login/kakao'),
        body: {'code': code},
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final token = data['accessToken'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', token);

        print('✅ 토큰 저장 완료: $token');

        if (!mounted) return;
        context.go('/home');
      } else {
        print('❌ 토큰 요청 실패: ${res.body}');
      }
    } catch (e) {
      print('❌ 예외 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
