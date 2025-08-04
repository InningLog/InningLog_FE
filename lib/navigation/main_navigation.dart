import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../screens/home_page.dart';
import '../screens/diary_page.dart';
import '../screens/board_page.dart';
import '../screens/my_page.dart';
import '../screens/seat_page.dart';
import 'package:inninglog/navigation/main_navigation.dart';
import 'package:go_router/go_router.dart';


class MainNavigation extends StatelessWidget {
  final Widget child;
  const MainNavigation({super.key, required this.child});

  static const List<String> _routes = ['/home', '/diary', '/seat', '/board', '/mypage'];

  @override
  Widget build(BuildContext context) {
    final location = GoRouter.of(context).routeInformationProvider.value.location;
    final currentIndex = _routes.indexWhere((r) => location.startsWith(r));

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
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
            _buildTabItem(context, 0, '홈', 'assets/icons/Home_black.svg', 'assets/icons/Home_gray.svg', currentIndex),
            _buildTabItem(context, 1, '직관 기록', 'assets/icons/Diary_black.svg', 'assets/icons/Diary_gray.svg', currentIndex),
            _buildTabItem(context, 2, '좌석', 'assets/icons/field_black.svg', 'assets/icons/field_gray.svg', currentIndex),
            _buildTabItem(context, 3, '커뮤니티', 'assets/icons/Community_black.svg', 'assets/icons/Community_gray.svg', currentIndex),
            _buildTabItem(context, 4, '마이페이지', 'assets/icons/Mypage_black.svg', 'assets/icons/Mypage_gray.svg', currentIndex),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(BuildContext context, int index, String label, String selectedIcon, String unselectedIcon, int currentIndex) {
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
              color: isSelected ? const Color(0xFF272727) : const Color(0xFFD3D3D3),
              fontFamily: 'Pretendard',
            ),
          ),
        ],
      ),
    );
  }
}
