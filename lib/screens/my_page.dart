import 'package:flutter/material.dart';
import '../widgets/common_header.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: const [
            CommonHeader(title: '마이페이지'),
            // 여기에 캘린더나 탭바 등 추가
          ],
        ),
      ),
    );
  }
}
