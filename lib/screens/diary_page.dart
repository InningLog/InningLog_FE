import 'package:flutter/material.dart';
import '../widgets/common_header.dart';


class DiaryPage extends StatelessWidget {
  const DiaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: const [
            CommonHeader(title: '직관 기록'),
            // 여기에 캘린더나 탭바 등 추가
          ],
        ),
      ),
    );
  }
}
