// lib/screens/kakao_login_webview_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

/// JWT payload 확인용 (디버깅)
String _decodeJwtPayload(String jwt) {
  try {
    final parts = jwt.split('.');
    if (parts.length != 3) return '(not a JWT)';
    String normalize(String s) =>
        s.padRight(s.length + (4 - s.length % 4) % 4, '=')
            .replaceAll('-', '+').replaceAll('_', '/');
    final payload = utf8.decode(base64Url.decode(normalize(parts[1])));
    return payload; // JSON string
  } catch (_) {
    return '(decode failed)';
  }
}

/// JWT에서 memberId 추출: `memberId`가 우선, 없으면 `sub`
int? _extractMemberId(String jwt) {
  try {
    final parts = jwt.split('.');
    if (parts.length != 3) return null;
    String normalize(String s) =>
        s.padRight(s.length + (4 - s.length % 4) % 4, '=')
            .replaceAll('-', '+').replaceAll('_', '/');
    final payloadJson = utf8.decode(base64Url.decode(normalize(parts[1])));
    final map = jsonDecode(payloadJson) as Map<String, dynamic>;
    final v = map['memberId'] ?? map['sub'];
    if (v == null) return null;
    return int.tryParse(v.toString());
  } catch (_) {
    return null;
  }
}

class KakaoLoginWebViewPage extends StatefulWidget {
  const KakaoLoginWebViewPage({super.key});

  @override
  State<KakaoLoginWebViewPage> createState() => _KakaoLoginWebViewPageState();
}

class _KakaoLoginWebViewPageState extends State<KakaoLoginWebViewPage> {
  late final WebViewController _controller;
  bool _loading = true;

  // 중복 실행 방지
  bool _kakaoAuthLaunched = false; // /login/page → 카카오 URL 이동 여부
  bool _callbackHandled = false;   // /callback 처리 완료 여부

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            _log('[WEBVIEW] onPageStarted: $url');
            setState(() => _loading = true);
          },
          onWebResourceError: (err) {
            _log('[WEBVIEW ERROR] $err');
            _showSnack('웹뷰 오류: ${err.description}');
          },
          onPageFinished: (url) async {
            _log('[WEBVIEW] onPageFinished: $url');
            setState(() => _loading = false);

            // 1) /login/page → JSON(location) 파싱 후 카카오 인증 페이지로 이동
            if (!_kakaoAuthLaunched &&
                (url == 'https://api.inninglog.shop/login/page' ||
                    url.startsWith('https://api.inninglog.shop/login/page'))) {
              try {
                final jsResult = await _controller
                    .runJavaScriptReturningResult('document.body.innerText');

                final body = (jsResult as String)
                    .replaceAll(RegExp(r'^"|"$'), '')
                    .replaceAll(r'\"', '"');

                _log('[LOGIN PAGE BODY] $body');

                final map = jsonDecode(body) as Map<String, dynamic>;
                _log('[LOGIN PAGE MAP] $map');

                final location = (map['location'] as String?)?.trim();
                _log('[LOGIN PAGE LOCATION] $location');

                if (location != null && location.isNotEmpty) {
                  _kakaoAuthLaunched = true;
                  await _controller.loadRequest(Uri.parse(location));
                  return;
                } else {
                  _showSnack('location이 비어있습니다.');
                }
              } catch (e) {
                _log('[LOGIN PAGE PARSE ERROR] $e');
                _showSnack('로그인 URL 파싱 실패: $e');
              }
            }

            // 2) /callback → 바디(JSON)에서 토큰/닉네임 파싱 → 저장 → (옵션) 프로빙 → 라우팅
            if (!_callbackHandled &&
                url.startsWith('https://api.inninglog.shop/callback')) {
              try {
                final jsResult = await _controller
                    .runJavaScriptReturningResult('document.body.innerText');

                final body = (jsResult as String)
                    .replaceAll(RegExp(r'^"|"$'), '')
                    .replaceAll(r'\"', '"');

                _log('[CALLBACK BODY RAW] $body');

                final map = jsonDecode(body) as Map<String, dynamic>;
                _log('[CALLBACK MAP] $map');

                final nickname     = map['nickname']     as String?;
                final accessToken  = map['accessToken']  as String?;
                final refreshToken = map['refreshToken'] as String?;
                final isNewMember  = (map['newMember'] ?? false) as bool;

                _log('[CALLBACK nickname] $nickname');
                _log('[CALLBACK accessToken] ${accessToken != null ? accessToken.substring(0, accessToken.length > 16 ? 16 : accessToken.length) : 'null'}...');
                _log('[CALLBACK refreshToken] ${refreshToken != null ? refreshToken.substring(0, refreshToken.length > 16 ? 16 : refreshToken.length) : 'null'}...');
                _log('[CALLBACK newMember] $isNewMember');

                if (accessToken == null || accessToken.isEmpty) {
                  _log('[ERROR] accessToken is NULL or EMPTY');
                  _showSnack('토큰을 찾지 못했습니다.');
                  return;
                }

                // 디버그: JWT 페이로드
                final payload = _decodeJwtPayload(accessToken);
                _log('[CALLBACK TOKEN PAYLOAD] $payload');

                // memberId 추출
                final memberId = _extractMemberId(accessToken);
                _log('👤 parsed memberId = $memberId');

                // 저장
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('accessToken', accessToken);
                if (refreshToken != null) {
                  await prefs.setString('refreshToken', refreshToken);
                }
                if (nickname != null) {
                  await prefs.setString('nickname', nickname);
                }
                if (memberId != null) {
                  await prefs.setInt('memberId', memberId);
                }

                final savedToken = prefs.getString('accessToken');
                final savedMid   = prefs.getInt('memberId');
                _log('[TOKEN SAVED] ${savedToken != null ? 'YES' : 'NO'}');
                _log('[memberId SAVED] ${savedMid ?? 'NO'}');

                // (옵션) 토큰으로 API 프로빙 (인증 유효성 즉시 확인)
                await _probeWithToken(accessToken);

                // 라우팅
                _callbackHandled = true;
                if (!mounted) return;
                context.go(isNewMember ? '/onboarding6' : '/home');
              } catch (e) {
                _log('[CALLBACK PARSE ERROR] $e');
                _showSnack('콜백 파싱 실패: $e');
              }
            }
          },
        ),
      )
      ..loadRequest(Uri.parse('https://api.inninglog.shop/login/page'));
  }

  /// 인증 토큰으로 샘플 API 호출 (성공 시 200)
  Future<void> _probeWithToken(String accessToken) async {
    try {
      final resp = await http.get(
        Uri.parse('https://api.inninglog.shop/home/view'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      _log('[PROBE STATUS] ${resp.statusCode}');
      _log('[PROBE BODY] ${resp.body}');
    } catch (e) {
      _log('[PROBE ERROR] $e');
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _log(String msg) {
    // 긴 문자열도 끊어서 안전하게 출력
    const chunk = 1024;
    for (var i = 0; i < msg.length; i += chunk) {
      debugPrint(msg.substring(i, (i + chunk > msg.length) ? msg.length : i + chunk));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(child: WebViewWidget(controller: _controller)),
          if (_loading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
