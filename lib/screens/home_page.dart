import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../app_colors.dart';
import '../widgets/common_header.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: 백엔드 연동 시 nickname은 API에서 가져오도록 변경
    const String nickname = '망곰 14'; //  현재는 하드코딩됨
    const double winningRateHalPoongRi = 0.332;


    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const CommonHeader(title: '홈'),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  '$nickname님의 직관 승률',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),
            // 직관 승률 카드
            Container(
              width: 359,
              height: 271,
              padding:  EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gray300),
              ),
              child: Column(
                // 카드 내부
                  children: [
                    const SizedBox(height: 12),
                    Image.asset(
                      getImageForRate(winningRateHalPoongRi),
                      width: 60,
                      height: 60,
                    ),

                    const SizedBox(height: 12),
                    Text(
                      winningRateHalPoongRi.toStringAsFixed(3),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary800,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primary300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(40),
                    ),
                    child: const Text(
                      '나의 직관 리포트',
                      style: TextStyle(
                        color: AppColors.primary700,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 우리팀 경기 일정 제목
            const Text(
              '우리팀 경기 일정',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'Pretendard',
              ),
            ),
            const SizedBox(height: 16),

            // 경기 일정 카드
            Container(
              padding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.gray300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Icon(Icons.chevron_left, color: AppColors.gray700),
                      Text(
                        '06.26(목)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                      Icon(Icons.chevron_right, color: AppColors.gray700),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '두산',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'VS',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary700,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'LG',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '17:00',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '@ 잠실 종합운동장 잠실야구장',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.gray600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 예매 버튼
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    '우리팀 예매처 바로가기',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
String getImageForRate(double rate) {
  if (rate <= 0.3) {
    return 'assets/images/bori_30.png';
  } else if (rate <= 0.5) {
    return 'assets/images/bori_50.png';
  } else if (rate <= 0.7) {
    return 'assets/images/bori_70.png';
  } else {
    return 'assets/images/bori_100.png';
  }
}


