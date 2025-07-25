import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../widgets/common_header.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'FieldSearchPage.dart';

final List<_TeamStadium> teamStadiums = [
  _TeamStadium('assets/icons/seoul_seat.svg', '두산 & LG','잠실 야구장'),
  _TeamStadium('assets/icons/kw_seat.svg', '키움','고척 스카이돔'),
  _TeamStadium('assets/icons/busan_seat.svg', '롯데','사직 야구장'),
  _TeamStadium('assets/icons/ssg_seat.svg', 'SSG','랜더스 필드'),
  _TeamStadium('assets/icons/lion_seat.svg', '삼성','라이온즈 파크'),
  _TeamStadium('assets/icons/hh_seat.svg', '한화','한화생명 볼파크'),
  _TeamStadium('assets/icons/kia_seat.svg', '기아','챔피언스 월드'),
  _TeamStadium('assets/icons/kt_seat.svg', 'KT','위즈 파크'),
  _TeamStadium('assets/icons/nc_seat.svg', 'NC','NC 파크장'),
];

class _TeamStadium {
  final String assetPath;
  final String teamName;
  final String stadiumName;

  _TeamStadium(this.assetPath, this.teamName, this.stadiumName);
}

class SeatPage extends StatelessWidget {
  const SeatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const CommonHeader(title: '구장'),
            const SizedBox(height: 6),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '구장을 선택하여 ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                    TextSpan(
                      text: '좌석 시야',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Pretendard',
                        color: AppColors.primary700,
                      ),
                    ),
                    TextSpan(
                      text: '를 검색해보세요!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),


            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.25),
                child: GridView.builder(
                  itemCount: teamStadiums.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 106.5 / 153,
                  ),
                  itemBuilder: (context, index) {
                    final stadium = teamStadiums[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FieldSearchPage(stadiumName: stadium.stadiumName),
                          ),
                        );
                      },

                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            stadium.assetPath,
                            width: 100,
                            height: 130,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            stadium.teamName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Pretendard',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                )

              ),
            ),
          ],
        ),
      ),
    );
  }
}
