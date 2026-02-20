import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:inninglog/router/navigation_policies.dart';

class MainNavigation extends StatelessWidget {
  final Widget child;
  const MainNavigation({super.key, required this.child});

  static const List<String> _routes = [
    '/home',
    '/diary',
    '/seat',
    '/community',
    '/mypage',
  ];

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    // 라우트 변경을 감지해 하단 네비게이션 표시 여부를 즉시 갱신한다.
    return AnimatedBuilder(
      animation: router.routerDelegate,
      builder: (context, _) {
        // 현재 위치로 활성 탭 인덱스를 계산한다.
        final location = router.routeInformationProvider.value.location;
        // /boards/:code 경로는 커뮤니티(index 3) 탭 하위로 간주한다.
        final currentIndex = location.startsWith('/boards')
            ? 3
            : _routes.indexWhere((r) => location.startsWith(r));
        // 현재 활성 라우트의 name을 기준으로 하단 네비 노출 여부를 판단한다.
        final hideBottomNav = _shouldHideBottomNav(router);

        return Scaffold(
          body: child,
          bottomNavigationBar:
              hideBottomNav
                  ? null
                  : Container(
                    height: 104,
                    padding: const EdgeInsets.fromLTRB(23, 18, 23, 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(0, -2),
                          blurRadius: 6.8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTabItem(
                          context,
                          0,
                          '홈',
                          'assets/icons/Home_black.svg',
                          'assets/icons/Home_gray.svg',
                          currentIndex,
                        ),
                        _buildTabItem(
                          context,
                          1,
                          '직관 일지',
                          'assets/icons/Diary_black.svg',
                          'assets/icons/Diary_gray.svg',
                          currentIndex,
                        ),
                        _buildTabItem(
                          context,
                          2,
                          '구장',
                          'assets/icons/field_black.svg',
                          'assets/icons/field_gray.svg',
                          currentIndex,
                        ),
                        _buildTabItem(
                          context,
                          3,
                          '커뮤니티',
                          'assets/icons/Community_black.svg',
                          'assets/icons/Community_gray.svg',
                          currentIndex,
                        ),
                        _buildTabItem(
                          context,
                          4,
                          '마이페이지',
                          'assets/icons/Mypage_black.svg',
                          'assets/icons/Mypage_gray.svg',
                          currentIndex,
                        ),
                      ],
                    ),
                  ),
        );
      },
    );
  }

  bool _shouldHideBottomNav(GoRouter router) {
    final config = router.routerDelegate.currentConfiguration;
    if (config.matches.isEmpty) return false;
    // 중첩 라우트에서 실제로 활성화된 GoRoute name을 찾는다.
    final name = _findLastGoRouteName(config.matches);
    return name != null && hideBottomNavRouteNames.contains(name);
  }

  String? _findLastGoRouteName(List<RouteMatchBase> matches) {
    // ShellRoute 등을 통과하므로, 가장 안쪽 GoRoute를 찾기 위해 역순으로 탐색한다.
    for (final match in matches.reversed) {
      final route = match.route;
      if (route is GoRoute) {
        return route.name;
      }
      final nested = match is ShellRouteMatch ? match.matches : null;
      if (nested != null && nested.isNotEmpty) {
        // ShellRoute 내부 매칭이 있으면 재귀적으로 더 내려간다.
        final nestedName = _findLastGoRouteName(nested);
        if (nestedName != null) return nestedName;
      }
    }
    return null;
  }

  Widget _buildTabItem(
    BuildContext context,
    int index,
    String label,
    String selectedIcon,
    String unselectedIcon,
    int currentIndex,
  ) {
    final isSelected = index == currentIndex;
    final route = _routes[index];
    return GestureDetector(
      onTap: () {
        context.go(route);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            isSelected ? selectedIcon : unselectedIcon,
            width: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color:
                  isSelected
                      ? const Color(0xFF272727)
                      : const Color(0xFFD3D3D3),
              fontFamily: 'Pretendard',
            ),
          ),
        ],
      ),
    );
  }
}
