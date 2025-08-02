import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BridgePage extends StatefulWidget {
  const BridgePage({super.key});

  @override
  State<BridgePage> createState() => _BridgePageState();
}

class _BridgePageState extends State<BridgePage> {
  @override
  void initState() {
    super.initState();
    _handleRedirect();
  }

  Future<void> _handleRedirect() async {
    final uri = Uri.parse(html.window.location.href);
    final id = uri.queryParameters['id'];

    if (id == null) return;

    try {
      final res = await http.get(Uri.parse('https://api.inninglog.shop/auth/temp?id=$id'));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final accessToken = data['accessToken'];
        final isNewUser = data['newMember'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', accessToken);
        await prefs.setString('nickname', data['nickname']);

        print('📡 GET 요청 보내는 중: /auth/temp?id=$id');
        print('📦 응답 코드: ${res.statusCode}');
        print('📦 응답 바디: ${res.body}');


        if (!mounted) return;
        context.go(isNewUser ? '/onboarding6' : '/home');
      } else {
        debugPrint('로그인 실패: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('에러 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('로그인이 완료되었습니다')),
    );
  }
}
