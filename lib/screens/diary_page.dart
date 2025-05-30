import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class DiaryPage extends StatelessWidget {
  const DiaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center, // 세로 가운데 정렬
              child: Row(
                children: [
                  const Text(
                    '직관 기록',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,      // Pretendard 기준 800
                      letterSpacing: -0.26,
                      color: Color(0xFF272727),
                      // fontFamily: 'Pretendard',     // 폰트 등록 후 활성화 필요
                      textBaseline: TextBaseline.alphabetic,
                    ),
                  ),

                  const Spacer(),
                  IconButton(
                    icon: SvgPicture.asset(
                      'assets/icons/Alarm.svg',
                      width: 24,
                    ),
                    onPressed: () {},
                  )

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
