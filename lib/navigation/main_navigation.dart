import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../screens/home_page.dart';
import '../screens/diary_page.dart';
import '../screens/board_page.dart';
import '../screens/my_page.dart';
import '../screens/seat_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    DiaryPage(),
    SeatPage(),
    BoardPage(),
    MyPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
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
            _buildTabItem(0, '홈', 'assets/icons/Home_black.svg', 'assets/icons/Home_gray.svg'),
            _buildTabItem(1, '직관 기록', 'assets/icons/Diary_black.svg', 'assets/icons/Diary_gray.svg'),
            _buildTabItem(2, '좌석', 'assets/icons/field_black.svg', 'assets/icons/field_gray.svg'),
            _buildTabItem(3, '커뮤니티', 'assets/icons/Community_black.svg', 'assets/icons/Community_gray.svg'),
            _buildTabItem(4, '마이페이지', 'assets/icons/Mypage_black.svg', 'assets/icons/Mypage_gray.svg'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, String label, String selectedIcon, String unselectedIcon) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
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
              fontSize: 10,
              color: isSelected ? const Color(0xFF272727) : const Color(0xFFD3D3D3),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
