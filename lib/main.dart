
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:inninglog/navigation/main_navigation.dart';
import 'package:inninglog/screens/add_diary_page.dart';
import 'package:inninglog/screens/add_seat_page.dart';
import 'package:inninglog/screens/field_hashtag_filter_sheet.dart';
import 'package:inninglog/screens/seat_detail_page.dart';
import 'package:inninglog/screens/onboarding_page6.dart';
import 'package:inninglog/screens/splash_screen.dart';
import 'package:inninglog/screens/onboarding_screen.dart';
import 'package:inninglog/screens/home_page.dart';
import 'package:inninglog/screens/diary_page.dart';
import 'package:inninglog/screens/seat_page.dart';
import 'package:inninglog/screens/board_page.dart';
import 'package:inninglog/screens/my_page.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'analytics/analytics.dart';
import 'package:inninglog/analytics/amplitude_flutter.dart';


final analytics = AnalyticsService();


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  analytics.init();



  runApp(const InningLogApp());
}


// void initAmplitude() {
//   if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
//     amplitude.init("821c8925a751c008310e896ad437b1bc");
//     amplitude.trackingSessionEvents(true);
//   } else {
//     print("⚠️ Amplitude is not supported on this platform.");
//   }
// }


final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    /// GNB 없는 화면들
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    GoRoute(
      path: '/adddiary',
      builder: (context, state) {
        print('✅ AddDiaryPage 빌더 진입!');
        final extra = state.extra as Map<String, dynamic>;
        print('🟢 받은 extra: $extra');

        return AddDiaryPage(
          initialDate: extra['initialDate'], // 작성 모드라면 무시됨
          isEditMode: extra['isEditMode'] ?? false,
          journalId: extra['journalId'], // 수정 모드일 때만 필요
        );
      },
    ),


    GoRoute(
      path: '/addseat',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return AddSeatPage(
          stadium: extra['stadium'],
          gameDateTime: extra['gameDateTime'],
          journalId: extra['journalId'],
        );
      },
    ),





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
        GoRoute(
          path: '/field_result',
          name: 'field_result',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            final index = extra['index'] as int;
            final stadiumName = extra['stadiumName'] as String;

            return FieldHashtagSearchResultPage(
              index: index,
              stadiumName: stadiumName,
              zone: extra['zone'],
              section: extra['section'],
              row: extra['row'],
              selectedTags: Map<String, String>.from(extra['selectedTags'] ?? {}),
              tagCategories: tagCategories,
            );
          },
        ),

        GoRoute(
          path: '/seat_detail',
          name: 'seat_detail',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            final int seatViewId = extra['seatViewId'];
            final String imageUrl = extra['imageUrl'];

            return SeatDetailPage(
              seatViewId: seatViewId,
              imageUrl: imageUrl,
            );
          },
        ),






      ],
    ),
  ],
);

class InningLogApp extends StatelessWidget {
  const InningLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ResponsiveWrapper(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
      ],
    );
  }
}

class ResponsiveWrapper extends StatelessWidget {
  const ResponsiveWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const aspectRatio = 9 / 16;

        double maxHeight = constraints.maxHeight;
        double calculatedWidth = maxHeight * aspectRatio;

        return Center(
          child: Container(
            width: calculatedWidth,
            height: maxHeight,
            color: Colors.white,
            child: MaterialApp.router(
              routerConfig: _router,
              debugShowCheckedModeBanner: false,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('ko', 'KR'),
              ],
            ),
          ),
        );
      },
    );
  }
}




// 각 카테고리 정의
final Map<String, List<String>> tagCategories = {
  '응원': ['#일어남', '#일어날_사람은_일어남', '#앉아서'],
  '햇빛': ['#강함', '#있다가_그늘짐', '#없음'],
  '지붕': ['#있음', '#없음'],
  '시야 방해': ['#그물', '#아크릴_가림막', '#없음'],
  '좌석 공간': ['#아주_넓음', '#넓음', '#보통', '#좁음'],
};