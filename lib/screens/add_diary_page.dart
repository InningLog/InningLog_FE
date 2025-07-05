import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../app_colors.dart';

class AddDiaryPage extends StatefulWidget {
  const AddDiaryPage({super.key});

  @override
  State<AddDiaryPage> createState() => _AddDiaryPageState();
}

class _AddDiaryPageState extends State<AddDiaryPage> {
  DateTime currentDate = DateTime.now();

  void _goToPreviousDay() {
    setState(() {
      currentDate = currentDate.subtract(const Duration(days: 1));
    });
  }

  void _goToNextDay() {
    setState(() {
      currentDate = currentDate.add(const Duration(days: 1));
    });
  }

  String _formatDate(DateTime date) {
    final today = DateTime.now();
    final isToday = date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
    if (isToday) return 'Today';
    return DateFormat('MM.dd(E)', 'ko').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ✅ 상단 고정 헤더
            Container(
              height: 72,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              alignment: Alignment.center,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    icon: SvgPicture.asset(
                      'assets/icons/back_but.svg',
                      width: 10,
                      height: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '직관 일지 작성',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.26,
                      color: Color(0xFF272727),
                      fontFamily: 'MBC1961GulimOTF',
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    padding: EdgeInsets.zero,
                    icon: SvgPicture.asset(
                      'assets/icons/Alarm.svg',
                      width: 18.05,
                      height: 24,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // ✅ 스크롤 가능한 본문
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // 날짜 & 팀 매치 정보
                      Container(
                        width: double.infinity,
                        height: 148,
                        padding: const EdgeInsets.only(top: 16, left: 19, right: 19),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.gray300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: _goToPreviousDay,
                                  icon: SvgPicture.asset(
                                    'assets/icons/month_left.svg',
                                    width: 20,
                                    height: 27,
                                  ),
                                ),
                                Text(
                                  _formatDate(currentDate),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Pretendard',
                                  ),
                                ),
                                IconButton(
                                  onPressed: _goToNextDay,
                                  icon: SvgPicture.asset(
                                    'assets/icons/month_right.svg',
                                    width: 20,
                                    height: 27,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '두산',
                                  style: TextStyle(
                                      fontSize: 19, fontWeight: FontWeight.w800),
                                ),
                                SizedBox(width: 66),
                                Text(
                                  'VS',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary700,
                                  ),
                                ),
                                SizedBox(width: 66),
                                Text(
                                  'LG',
                                  style: TextStyle(
                                      fontSize: 19, fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '17:00',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Pretendard',
                              ),
                            ),
                            const Text(
                              '@ 잠실 종합운동장 잠실야구장',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Pretendard',
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 23),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '스코어',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Pretendard',
                              ),
                            ),
                            TextSpan(
                              text: '*',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Pretendard',
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 스코어 입력
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _scoreInputField(hintText: '우리팀 스코어'),
                          const Text(
                            'VS',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.black,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                          _scoreInputField(hintText: '상대팀 스코어'),
                        ],
                      ),

                      const SizedBox(height: 26),

                      // 감정 선택
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '오늘 경기를 보고 어떤 감정을 느끼셨나요?',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Pretendard',
                                  ),
                                ),
                                TextSpan(
                                  text: '*',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Pretendard',
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 191,
                            width: 360,// 감정 아이콘 전체 높이 (아이콘 크기에 따라 조절)
                            child: GridView.count(
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              physics: const NeverScrollableScrollPhysics(),
                              childAspectRatio: 112 / 90, // ✅ 카드 너비/높이 비율
                              children: List.generate(6, (index) => _emotionIcon(index)),
                            ),

                          ),

                        ],
                      ),

                      const SizedBox(height: 26),


                      const Text(
                        '사진',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 사진 업로드
                      Container(
                        width: double.infinity,
                        height: 103,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: const Center(child: Icon(Icons.camera_alt_outlined)),
                      ),

                      const SizedBox(height: 24),

                      // 후기 작성
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '후기',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            maxLines: 5,
                            maxLength: 123,
                            decoration: InputDecoration(
                              hintText: '후기를 작성해주세요.',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // 버튼 2개
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                              backgroundColor: Colors.grey[300],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              '좌석 후기 작성하기',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text('작성 완료'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int selectedEmotionIndex = -1; // 선택된 감정 인덱스 상태 변수

  Widget _emotionIcon(int index) {
    final List<String> labels = ['짜릿함', '감동', '흐뭇', '답답함', '아쉬움', '분노'];
    final List<String> emojis = [
      'assets/images/emotion_thrilled.jpg',
      'assets/images/emotion_touched.jpg',
      'assets/images/emotion_satisfied.jpg',
      'assets/images/emotion_suffocated.jpg',
      'assets/images/emotion_ohmy.jpg',
      'assets/images/emotion_angry.jpg',

    ];

    final bool isSelected = selectedEmotionIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedEmotionIndex = index;
        });
      },
      child: Container(
        width: 112,
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFB0B4A4) : const Color(0xFFDEDFE0),
          ),
          color: isSelected ? AppColors.primary200 : AppColors.gray100,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              emojis[index],
              width: 40,
              height: 40,
            ),
            const SizedBox(height: 4),
            Text(
              labels[index],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'Pretendard',
              ),
            ),
          ],
        ),

      ),
    );

  }
  }


Widget _scoreInputField({required String hintText}) {
  return SizedBox(
    width: 140,
    height: 40,
    child: TextField(
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'Pretendard',
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: AppColors.gray700,
          fontWeight: FontWeight.w400,
          fontSize: 16,
        ),
        filled: true,
        fillColor: AppColors.gray100,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.gray300,),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary700),
        ),
      ),
      keyboardType: TextInputType.number,
    ),
  );
}

