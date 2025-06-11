import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';  // SvgPicture 쓸 때 필요

class AddDiaryPage extends StatelessWidget {
  const AddDiaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                padding: EdgeInsets.zero, // 아이콘 버튼 내부 여백 제거
                icon: SvgPicture.asset(
                  'assets/icons/back_but.svg',
                  width: 10,
                  height: 20,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(width: 0),
              const Text(
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
              const Spacer(),
              IconButton(
                padding: EdgeInsets.zero, // 아이콘 버튼 내부 여백 제거
                icon: SvgPicture.asset(
                  'assets/icons/Alarm.svg',
                  width: 18.05,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),

    );
  }
}
