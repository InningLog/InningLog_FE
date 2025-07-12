import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:inninglog/navigation/main_navigation.dart';
import 'package:inninglog/screens/add_diary_page.dart';
import 'package:inninglog/screens/add_seat_page.dart';
import 'package:inninglog/screens/onboarding_page6.dart';
import 'package:inninglog/screens/splash_screen.dart';
import 'package:inninglog/screens/onboarding_screen.dart';
import 'package:inninglog/screens/home_page.dart';
import 'package:inninglog/screens/diary_page.dart';
import 'package:inninglog/screens/seat_page.dart';
import 'package:inninglog/screens/board_page.dart';
import 'package:inninglog/screens/my_page.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';

void main() {

  KakaoSdk.init(nativeAppKey: '3e0a9528d7ddb6147c97af78f60ab300');
  runApp(const InningLogApp());
}


final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    /// GNB 없는 화면들
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/adddiary', builder: (_, __) => const AddDiaryPage()),
    GoRoute(path: '/addseat', builder: (_, __) => const AddSeatPage()),
    GoRoute(path: '/onboarding6', builder: (_, __) => const OnboardingPage6()),


    /// GNB 있는 ShellRoute
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainNavigation(child: child); // ✅ 아래에서 정의할 MainNavigation
      },
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomePage()),
        GoRoute(path: '/diary', builder: (_, __) => const DiaryPage()),
        GoRoute(path: '/seat', builder: (_, __) => const SeatPage()),
        GoRoute(path: '/board', builder: (_, __) => const BoardPage()),
        GoRoute(path: '/mypage', builder: (_, __) => const MyPage()),
      ],
    ),
  ],
);

class InningLogApp extends StatelessWidget {
  const InningLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'InningLog',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
      ],
      routerConfig: _router, // go_router 연결
    );
  }
}
