import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../app_colors.dart';
import 'dart:io';
import 'add_seat_page.dart';

File? _pickedImage;
//상태변수
int reviewLength = 0;
String ourScore = '';
String opponentScore = '';




class AddDiaryPage extends StatefulWidget {
  const AddDiaryPage({super.key, this.initialDate});

  final DateTime? initialDate;



  @override
  State<AddDiaryPage> createState() => _AddDiaryPageState();
}

class _AddDiaryPageState extends State<AddDiaryPage> {
  DateTime currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    currentDate = widget.initialDate ?? DateTime.now(); // 전달받은 날짜 or 오늘
  }


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

    bool isFormValid =
        ourScore?.isNotEmpty == true &&
            opponentScore?.isNotEmpty == true &&
            selectedEmotionIndex != -1;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ✅ 상단 고정 헤더
            Container(
              height: 72,
              padding: const EdgeInsets.symmetric(vertical: 10),
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
                  const SizedBox(width: 0),
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
                        height: 153,
                        padding: const EdgeInsets.only(top: 8, left: 19, right: 19,bottom: 8),
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
                          _scoreInputField(
                            hintText: '우리팀 스코어',
                            onChanged: (value) {
                              setState(() {
                                ourScore = value;
                              });
                            },
                          ),
                          const Text(
                            'VS',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.black,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                          _scoreInputField(
                            hintText: '상대팀 스코어',
                            onChanged: (value) {
                              setState(() {
                                opponentScore = value;
                              });
                            },
                          ),
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
                            height: 192,
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
                      DiaryImagePicker(),


                      const SizedBox(height: 26),



                      // 후기 작성
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '후기',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                          const SizedBox(height: 8),
                          // 글자 수 표시

                          // 텍스트필드
                          TextField(
                            maxLines: 4,
                            maxLength: 132,
                            onChanged: (value) {
                              setState(() {
                                reviewLength = value.length;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: '후기를 작성해주세요.',
                              hintStyle: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.gray700,
                              ),
                              filled: true,
                              fillColor: AppColors.gray100,
                              counterText: '', // ✅ 기본 카운터 숨김
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.gray300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.gray300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.gray700),
                              ),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Spacer(), // 왼쪽 빈 공간
                            Text(
                              '($reviewLength/132)',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: AppColors.gray600,
                                fontFamily: 'Pretendard',
                              ),
                            ),
                          ],
                        ),
                      ),


                      const SizedBox(height: 16),



                      // 버튼 2개
                      Column(
                        children: [
                          Center(
                          child : SizedBox(
                            width: 360,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: isFormValid
                                  ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const AddSeatPage()),
                                );
                              }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                isFormValid ? AppColors.primary700 : AppColors.gray200,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  side: isFormValid
                                      ? const BorderSide(color: AppColors.primary700)
                                      : BorderSide.none,
                                ),
                              ),
                              child: Text(
                                '좌석 후기 작성하기',
                                style: TextStyle(
                                  color: isFormValid ? Colors.white : AppColors.gray700,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          ),

                          const SizedBox(height: 12),

                          // ✅ 아래 버튼도 SizedBox로 감싸기
                          SizedBox(
                            width: 360,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: isFormValid ? () {} : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                isFormValid ? Colors.white : AppColors.gray200,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  side: BorderSide(
                                    color: isFormValid
                                        ? AppColors.primary700
                                        : Colors.transparent,
                                  ),
                                ),
                              ),
                              child: Text(
                                '작성 완료',
                                style: TextStyle(
                                  color:
                                  isFormValid ? AppColors.primary700 : AppColors.gray700,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
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
      'assets/icons/emotion_thrilled.svg',
      'assets/icons/emotion_touched.svg',
      'assets/icons/emotion_satisfied.svg',
      'assets/icons/emotion_suffocated.svg',
      'assets/icons/emotion_ohmy.svg',
      'assets/icons/emtion_angry.svg',
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
            SvgPicture.asset(
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


Widget _scoreInputField({
  required String hintText,
  required Function(String) onChanged,
}) {
  return SizedBox(
    width: 140,
    height: 40,
    child: TextField(
      onChanged: onChanged,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'Pretendard',
      ),
      keyboardType: TextInputType.number,
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
          borderSide: const BorderSide(color: AppColors.gray300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary700),
        ),
      ),
    ),
  );
}



//사진 가져오기
class DiaryImagePicker extends StatefulWidget {
  const DiaryImagePicker({super.key});

  @override
  State<DiaryImagePicker> createState() => _DiaryImagePickerState();
}

class _DiaryImagePickerState extends State<DiaryImagePicker> {
  File? _pickedImage;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image =
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque, // ✅ 터치가 빈 공간에도 반응하도록 설정
      onTap: _pickImage, // ✅ 이게 실행돼야 갤러리 열림
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFD9D9D9)),
          color: const Color(0xFFF5F5F5),
        ),
        child: _pickedImage == null
            ? Padding(
          padding: const EdgeInsets.symmetric(vertical: 36),
          child: Center(
            child: SvgPicture.asset(
              "assets/icons/camera_icon.svg",
              width: 28.3,
              height: 28.3,
            ),
          ),
        )
            : ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            _pickedImage!,
            fit: BoxFit.fitWidth,
            width: double.infinity,
          ),
        ),
      ),
    );
  }
}


