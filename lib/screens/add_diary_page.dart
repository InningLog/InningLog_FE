import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';  // SvgPicture 쓸 때 필요

class AddDiaryPage extends StatelessWidget {
  const AddDiaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            children: [
              // 뒤로가기 버튼 (왼쪽 여백 줄이기)
              Padding(
                padding: const EdgeInsets.only(left: 0), // 여백 조정 가능
                child: IconButton(
                  icon: SvgPicture.asset(
                    'assets/icons/back_but.svg',
                    width: 10,
                    height: 20,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              // 글씨 (약간 오른쪽으로 밀기)
              Padding(
                padding: const EdgeInsets.only(left: 0), // 글씨 왼쪽 padding 추가
                child: const Text(
                  '직관 일지 작성',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.26,
                    color: Color(0xFF272727),
                    fontFamily: 'MBC1961GulimOTF',
                    textBaseline: TextBaseline.alphabetic,
                  ),
                ),
              ),
              const Spacer(),
              // 알람 버튼
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/Alarm.svg',
                  width: 18.05,
                ),
                onPressed: () {
                  // 알람 버튼 눌렀을 때 동작 (원하면 내용 추가 가능)
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
