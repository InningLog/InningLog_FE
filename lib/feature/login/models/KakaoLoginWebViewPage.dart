import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inninglog/app_scope.dart';
import 'package:inninglog/shared/auth/auth_session.dart';
import 'package:inninglog/shared/auth/token_storage.dart';
import 'package:inninglog/shared/utils/jwt_utils.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class KakaoLoginWebViewPage extends StatefulWidget {
  const KakaoLoginWebViewPage({super.key});

  @override
  State<KakaoLoginWebViewPage> createState() => _KakaoLoginWebViewPageState();
}

class _KakaoLoginWebViewPageState extends State<KakaoLoginWebViewPage> {
  late final WebViewController _controller;
  bool _loading = true;

  bool _kakaoAuthLaunched = false;
  bool _callbackHandled = false;

  static const _base = 'https://api.inninglog.shop';
  late final _scope = context.read<AppScope>();

  @override
  void initState() {
    super.initState();

    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (url) {
                _log('[WEBVIEW] onPageStarted: $url');
                if (mounted) setState(() => _loading = true);
              },
              onWebResourceError: (err) {
                _log('[WEBVIEW ERROR] $err');
                _showSnack('웹뷰 오류: ${err.description}');
              },
              onPageFinished: (url) async {
                _log('[WEBVIEW] onPageFinished: $url');
                if (mounted) setState(() => _loading = false);

                // 1) /login/page → location 파싱 후 카카오 인증 URL로 이동
                if (!_kakaoAuthLaunched && _isLoginPage(url)) {
                  await _handleLoginPage();
                  return;
                }

                // 2) /callback → JSON 파싱 → 토큰 저장 → 라우팅
                if (!_callbackHandled && _isCallback(url)) {
                  await _handleCallback();
                  return;
                }
              },
            ),
          )
          ..loadRequest(Uri.parse('$_base/login/page'));
  }

  bool _isLoginPage(String url) =>
      url == '$_base/login/page' || url.startsWith('$_base/login/page');

  bool _isCallback(String url) => url.startsWith('$_base/callback');

  Future<void> _handleLoginPage() async {
    try {
      final bodyText = await _readBodyInnerText();
      _log('[LOGIN PAGE BODY] $bodyText');

      final map = jsonDecode(bodyText) as Map<String, dynamic>;
      final location = (map['location'] as String?)?.trim();

      _log('[LOGIN PAGE LOCATION] $location');

      if (location != null && location.isNotEmpty) {
        _kakaoAuthLaunched = true;
        await _controller.loadRequest(Uri.parse(location));
      } else {
        _showSnack('location이 비어있습니다.');
      }
    } catch (e) {
      _log('[LOGIN PAGE PARSE ERROR] $e');
      _showSnack('로그인 URL 파싱 실패: $e');
    }
  }

  Future<void> _handleCallback() async {
    try {
      final bodyText = await _readBodyInnerText();
      _log('[CALLBACK BODY] $bodyText');

      final map = jsonDecode(bodyText) as Map<String, dynamic>;

      // 1) callback json → session
      var session = AuthSession.fromCallbackJson(map);

      // 2) memberId는 JWT에서 추출 (있으면 저장)
      final memberId = JwtUtils.extractMemberId(session.accessToken);
      session = session.copyWith(memberId: memberId);

      if (kDebugMode) {
        _log('[CALLBACK nickname] ${session.nickname}');
        _log('[CALLBACK newMember] ${session.isNewMember}');
        _log('[CALLBACK memberId] ${session.memberId}');
        _log(
          '[CALLBACK TOKEN PAYLOAD] ${JwtUtils.decodePayload(session.accessToken)}',
        );
      }

      // 3) 저장 (SharedPreferences 직접 접근 제거)
      await _scope.tokenStorage.saveSession(session);

      // 4) (옵션) 토큰 검증이 필요하면 repository 호출로 대체
      // await widget.homeRepository?.fetchHomeData();

      // 5) 라우팅
      _callbackHandled = true;
      if (!mounted) return;
      context.go(session.isNewMember ? '/onboarding6' : '/home');
    } catch (e) {
      _log('[CALLBACK PARSE ERROR] $e');
      _showSnack('콜백 처리 실패: $e');
    }
  }

  /// WebView의 document.body.innerText를 JSON string으로 안전하게 가져오기
  Future<String> _readBodyInnerText() async {
    final jsResult = await _controller.runJavaScriptReturningResult(
      'document.body.innerText',
    );

    // webview_flutter 환경마다 반환 타입이 달라질 수 있어 안전 처리
    final raw = jsResult?.toString() ?? '';

    // 기존 코드에서 하던 따옴표/이스케이프 보정 유지
    return raw.replaceAll(RegExp(r'^"|"$'), '').replaceAll(r'\"', '"');
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _log(String msg) {
    const chunk = 1024;
    for (var i = 0; i < msg.length; i += chunk) {
      debugPrint(
        msg.substring(i, (i + chunk > msg.length) ? msg.length : i + chunk),
      );
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
