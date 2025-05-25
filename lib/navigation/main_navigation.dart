import 'package:flutter/material.dart';
// 각 페이지 import
import '../screens/home_page.dart';
import '../screens/diary_page.dart';
import '../screens/board_page.dart';
import '../screens/my_page.dart';
import '../screens/seat_page.dart';

/// 메인 네비게이션 바를 담당하는 StatefulWidget
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

/// 상태를 관리하는 State 클래스
class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0; // 현재 선택된 탭 인덱스

  // 각 탭에서 보여줄 페이지 리스트
  final List<Widget> _pages = const [
    HomePage(),   // 야구 홈
    DiaryPage(),  // 일지
    BoardPage(),  // 게시판
    SeatPage(),   // 좌석
    MyPage(),     // 마이페이지
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 현재 선택된 페이지 보여주기
      body: _pages[_currentIndex],

      // 하단 네비게이션 바
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // 현재 선택된 인덱스 지정
        onTap: (index) => setState(() {
          _currentIndex = index; // 탭 클릭 시 상태 변경 → 화면 전환
        }),
        type: BottomNavigationBarType.fixed, // 탭 개수가 4개 이상이면 이거 필수
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_baseball),
            label: '야구 홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note),
            label: '일지',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: '게시판',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_seat),
            label: '좌석',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '마이페이지',
          ),
        ],
      ),
    );
  }
}
