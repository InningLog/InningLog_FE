import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:inninglog/app_scope.dart';
import 'package:inninglog/router/app_routes.dart';
import 'package:inninglog/router/route_observer.dart';
import 'package:inninglog/shared/widgets/main_navigation.dart';
import 'package:inninglog/feature/login/models/KakaoLoginWebViewPage.dart';
import 'package:inninglog/feature/diary/screens/add_diary_page.dart';
import 'package:inninglog/feature/diary/screens/add_seat_page.dart';
import 'package:inninglog/feature/community/screens/community_search_page.dart';
import 'package:inninglog/feature/field/screens/field_hashtag_filter_sheet.dart';
import 'package:inninglog/feature/community/screens/market_upload_step1.dart';
import 'package:inninglog/feature/community/screens/market_upload_step2.dart';
import 'package:inninglog/feature/community/screens/market_upload_step3.dart';
import 'package:inninglog/feature/community/screens/writing_post_page.dart';
import 'package:inninglog/feature/community/screens/post_detail_market.dart';
import 'package:inninglog/feature/community/screens/post_detail_page.dart';
import 'package:inninglog/feature/field/screens/seat_detail_page.dart';
import 'package:inninglog/feature/onboarding/screens/onboarding_page6.dart';
import 'package:inninglog/feature/onboarding/screens/splash_screen.dart';
import 'package:inninglog/feature/onboarding/screens/onboarding_screen.dart';
import 'package:inninglog/feature/home/screens/home_page.dart';
import 'package:inninglog/feature/diary/screens/diary_page.dart';
import 'package:inninglog/feature/field/screens/seat_page.dart';
import 'package:inninglog/feature/community/screens/root_page.dart';
import 'package:inninglog/feature/mypage/screens/my_page.dart';
import 'package:inninglog/feature/community/screens/teamboard_page.dart';
import 'package:inninglog/feature/community/widgets/shared/segmented_tabs.dart';
import 'package:provider/provider.dart';
import 'package:inninglog/shared/amplitude/AmplitudeFlutter.dart';

const amplitudeKey = String.fromEnvironment('AMPLITUDE_API_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final amplitude = AmplitudeFlutter.getInstance();

  if (amplitudeKey.isNotEmpty) {
    await amplitude.init(amplitudeKey);
  } else {
    print('⚠️ AMPLITUDE_API_KEY is missing');
  }
  final scope = await AppScope.create();

  runApp(Provider<AppScope>.value(value: scope, child: const InningLogApp()));
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  observers: [rootRouteObserver],

  routes: [
    GoRoute(path: '/', redirect: (_, __) => '/splash'),

    /// GNB 없는 화면들
    GoRoute(
      path: '/kakaoWebView',
      name: 'kakaoWebView',
      builder: (context, state) => const KakaoLoginWebViewPage(),
    ),

    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),

    GoRoute(
      path: '/adddiary',
      builder: (context, state) {
        print('✅ AddDiarPage 빌더 진입!');
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
      path: '/add-seat',
      name: 'add_seat',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};

        // ✅ stadium만 필수
        final stadium = extra['stadium'] as String?;
        if (stadium == null || stadium.trim().isEmpty) {
          return const Scaffold(
            body: Center(child: Text('잘못된 접근입니다')),
          );
        }

        // ✅ journalId는 null 가능 + 타입도 안전하게 변환
        final rawJournalId = extra['journalId'];
        final int? journalId = rawJournalId is int
            ? rawJournalId
            : int.tryParse(rawJournalId?.toString() ?? '');

        // ✅ gameDateTime도 null 가능
        final gameDateTime = extra['gameDateTime'] as String?;

        return AddSeatPage(
          stadium: stadium,
          journalId: journalId,                 // ✅ nullable
          gameDateTime: gameDateTime,           // ✅ nullable
          initialSection: extra['initialSection'] as String?,
          initialRow: extra['initialRow'] as String?,
          showGameTime: (extra['showGameTime'] as bool?) ?? true,
        );
      },
    ),





    GoRoute(path: '/onboarding6', builder: (_, __) => const OnboardingPage6()),
    GoRoute(
      path: AppRoutePaths.search,
      builder: (_, __) => const CommunitySearchPage(),
    ),

    GoRoute(
      path: '/market/:code/upload',
      name: 'market_upload',
      builder: (ctx, state) {
        final code = state.pathParameters['code']!;
        return MarketUploadStep1(teamCode: code);
      },
    ),

    GoRoute(
      path: '/market/:code/upload/step2',
      builder:
          (ctx, state) =>
              MarketUploadStep2(teamCode: state.pathParameters['code']!),
    ),
    GoRoute(
      path: '/market/:code/upload/step3',
      builder:
          (ctx, state) =>
              MarketUploadStep3(teamCode: state.pathParameters['code']!),
    ),

    GoRoute(
      name: 'post_detail_market',
      path: '/post/market/detail',
      builder: (context, state) {
        final args = state.extra as PostDetailMarketArgs;
        return PostDetailMarketPage(args: args);
      },
    ),





    /// GNB 있는 ShellRoute
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      observers: [shellRouteObserver],
      builder: (context, state, child) {
        return MainNavigation(child: child);
      },
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomePage()),
        GoRoute(path: '/diary', builder: (_, __) => const DiaryPage()),
        GoRoute(
          path: '/seat',
          builder: (_, __) => const SeatPage(),
          routes: [


          ],
        ),

        GoRoute(path: '/mypage', builder: (_, __) => const MyPage()),

        GoRoute(
          path: '/seat_detail',
          name: 'seat_detail',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            final int seatViewId = extra['seatViewId'];
            final String imageUrl = extra['imageUrl'];

            return SeatDetailPage(seatViewId: seatViewId, imageUrl: imageUrl, stadiumName: '',);
          },
        ),
        // 커뮤니티
        GoRoute(
          path: '/community',
          builder: (_, __) => const CommunityRootPage(),
        ),

        GoRoute(
          path: AppRoutePaths.board,
          builder: (_, state) {
            final code = state.pathParameters['code']!;
            final tabParam = state.uri.queryParameters['tab'] ?? 'onlywan';
            return TeamBoardPage(
              teamCode: code,
              activeTab: boardTabFromPath(tabParam),
            );
          },
          routes: [
            GoRoute(
              path: AppRoutePaths.boardPostWrite,
              name: AppRouteNames.writingPost,
              builder: (_, state) {
                final code = state.pathParameters['code']!;
                return WritingPostPage(teamCode: code);
              },
            ),
            GoRoute(
              path: AppRoutePaths.boardPostDetail,
              name: AppRouteNames.postDetail,
              builder: (context, state) {
                final teamCode = state.pathParameters['code']!;
                final postId = int.parse(state.pathParameters['postId']!);
                return PostDetailPage(teamCode: teamCode, postId: postId);
              },
            ),
          ],

        ),
        GoRoute(
          name: 'field_result',
          path: '/field_result',
          builder: (context, state) {
            debugPrint('[GoRouter] field_result state.extra=${state.extra}');
            final extra = state.extra as Map<String, dynamic>;

            final index = extra['index'] as int? ?? 0;
            final stadiumName = extra['stadiumName'] as String;
            final section = extra['section'] as String?;

            debugPrint('[GoRouter] parsed index=$index stadiumName=$stadiumName section=$section');

            return FieldHashtagSearchResultPage(
              stadiumName: stadiumName,
              section: section,
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
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
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
                child: child,
              ),
            );
          },
        );
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ko', 'KR')],
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
