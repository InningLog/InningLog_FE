import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:inninglog/service/api_service.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../analytics/AmplitudeFlutter.dart';
import '../app_colors.dart';
import 'dart:io';
import '../main.dart';
import '../models/home_view.dart';
import '../service/api_service.dart';
import 'add_seat_page.dart';
import 'package:http/http.dart' as http;
import '../service/api_service.dart';
import 'home_page.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // kIsWeb



File? _pickedImage;
//상태변수
int reviewLength = 0;
String ourScore = '';
String opponentScore = '';
String? fileName;
bool hasSeatView = false;




class AddDiaryPage extends StatefulWidget {

  final DateTime? initialDate;
  final bool isEditMode;
  final int? journalId;


  const AddDiaryPage({
    super.key,
    this.initialDate,
    this.isEditMode = false,
    this.journalId,
  });




  @override
  State<AddDiaryPage> createState() => _AddDiaryPageState();
}

class _AddDiaryPageState extends State<AddDiaryPage> {
  bool isSaving = false;
  String? fileName;
  DateTime currentDate = DateTime.now();
  String? writtenStadiumCode;
  Uint8List? _imageBytes;


  final TextEditingController ourScoreController = TextEditingController();
  final TextEditingController theirScoreController = TextEditingController();




  void _updateScheduleForDate(DateTime date) async {
    final schedule = await loadScheduleFromPrefs(date);
    setState(() {
      currentDate = date;
      todaySchedule = schedule;

    });
  }

  void _goToPreviousDay() {
    final newDate = currentDate.subtract(const Duration(days: 1));
    _updateScheduleForDate(newDate);
  }

  void _goToNextDay() {
    final today = DateTime.now();
    // 시간 비교를 위해 시/분/초 제거
    final todayOnly = DateTime(today.year, today.month, today.day);
    final newDate = currentDate.add(const Duration(days: 1));

    if (newDate.isAfter(todayOnly)) {
      // 오늘보다 이후 날짜면 막기
      return;
    }
    _updateScheduleForDate(newDate);
  }


  String _formatDate(DateTime date) {
    final today = DateTime.now();
    final isToday = date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
    if (isToday) return 'Today';
    return DateFormat('MM.dd(E)', 'ko').format(date);
  }

  MyTeamSchedule? todaySchedule;

  @override
  void initState() {
    super.initState();

    if (widget.isEditMode && widget.journalId != null) {
      fetchJournalData(widget.journalId!);



    } else {
      currentDate = widget.initialDate ?? DateTime.now();
      _updateScheduleForDate(currentDate);
    }


  }



  String? mediaUrl;

  Future<void> fetchJournalData(int journalId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final memberId = prefs.getInt('member_id');
      if (memberId == null) {
        print('❌ memberId 없음');
        return;
      }

      final response = await http.get(
        Uri.parse('https://api.inninglog.shop/journals/detail/$journalId?memberId=$memberId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('👉 받은 데이터: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final data = json['data']['jourDetail'];
        String? presignedImageUrl = data['media_url'];

        print('📦 journalDetail data: $data');

        setState(() {
          currentDate = DateTime.tryParse(data['gameDate'] ?? '') ?? DateTime.now();
          ourScoreController.text = data['ourScore']?.toString() ?? '';
          theirScoreController.text = data['theirScore']?.toString() ?? '';
          selectedEmotionIndex = getEmotionIndex(data['emotion'] ?? '');
          reviewController.text = data['review_text'] ?? '';
          mediaUrl = presignedImageUrl;
          final seatViewId = json['data']['seatViewId'];
          hasSeatView = seatViewId != null && seatViewId != 0;

          todaySchedule = MyTeamSchedule(
            gameId: json['gameId'],
            myTeam: data['supportTeamSC'] ?? '',
            opponentTeam: data['opponentTeamSC'] ?? '',
            gameDateTime: data['gameDate'] ?? '',
            stadium: data['stadiumSC'] ?? '',
          );
        });

        ourScore = ourScoreController.text;
        opponentScore = theirScoreController.text;
      } else {
        print('❌ 서버 응답 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ fetchJournalData 에러: $e');
    }
  }



  Future<String?> getValidGameId({
    required DateTime date,
    required String myTeam,
    required String opponentTeam,
  }) async {
    final formattedDate = DateFormat('yyyyMMdd').format(date);
    final gameId1 = '${formattedDate}${opponentTeam}${myTeam}0';
    final gameId2 = '${formattedDate}${myTeam}${opponentTeam}0';

    final prefs = await SharedPreferences.getInstance();
    final memberId = prefs.getInt('member_id');
    if (memberId == null) {
      print('❌ memberId 없음');
      return null;
    }

    final baseUri = 'https://api.inninglog.shop/journals/contents';

    // gameId1 확인
    final uri1 = Uri.parse('$baseUri?gameId=$gameId1&memberId=$memberId');
    final res1 = await http.get(uri1);
    if (res1.statusCode == 200) {
      print('✅ 유효한 gameId 찾음: $gameId1');
      return gameId1;
    }

    // gameId2 확인
    final uri2 = Uri.parse('$baseUri?gameId=$gameId2&memberId=$memberId');
    final res2 = await http.get(uri2);
    if (res2.statusCode == 200) {
      print('✅ 유효한 gameId 찾음: $gameId2');
      return gameId2;
    }

    print('❌ 두 gameId 모두 무효');
    return null;
  }



  String getEmotionKor(int index) {
    const emotions = ['짜릿함', '감동', '흡족', '답답함', '아쉬움', '분노'];
    if (index < 0 || index >= emotions.length) return '';
    return emotions[index];
  }



  final TextEditingController reviewController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    bool isFormValid =
        ourScore?.isNotEmpty == true &&
            opponentScore?.isNotEmpty == true &&
            selectedEmotionIndex != -1;


    final bool isSeatButtonEnabled = !widget.isEditMode
        ? isFormValid // 작성 모드: 점수, 감정 필수
        : isFormValid && !hasSeatView; // 수정 모드: 점수 감정 입력 && 아직 좌석 후기 없음


    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ✅ 상단 고정 헤더 (스크롤 바깥)
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
                    onPressed: () {
                      AmplitudeFlutter.getInstance().logEvent(
                          'click_diary_write_back', eventProperties: {
                        'event_type': 'Custom',
                        'component': 'btn_click',
                        'importance': 'Medium',
                      });
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

            // ✅ 스크롤 가능한 본문 (Expanded 안의 SingleChildScrollView)
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior
                    .onDrag,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // 날짜 & 팀 매치 정보
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, bottom: 19),
                        decoration: BoxDecoration(
                          border: Border.all(color: widget.isEditMode
                              ? AppColors.primary400
                              : AppColors.gray300,), // ✅ 조건 분기),
                          borderRadius: BorderRadius.circular(12),
                        ),

                        child: Column(
                          children: [

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                widget.isEditMode
                                    ? const SizedBox(
                                    width: 48, height: 48) // 아이콘 없을 때 공간 유지
                                    : IconButton(
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
                                widget.isEditMode
                                    ? const SizedBox(width: 48) // 오른쪽도 동일
                                    : IconButton(
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
                            if (todaySchedule == null)

                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, right: 16, bottom: 19),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // 🐻 Bori sleepy 이미지 (왼쪽)
                                    Image.asset(
                                      'assets/images/bori_sleepy.jpg',
                                      width: 72,
                                      height: 60,
                                    ),
                                    const SizedBox(width: 13),

                                    // 📝 "경기가 없습니다" 텍스트 (오른쪽)
                                    const Text(
                                      '오늘은 경기가 없어요!',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'omyu pretty',
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        teamNameMap[todaySchedule!.myTeam] ??
                                            todaySchedule!.myTeam,
                                        style: const TextStyle(fontSize: 19,
                                            fontWeight: FontWeight.w800),
                                      ),
                                      const SizedBox(width: 66),
                                      const Text(
                                        'VS',
                                        style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary700,
                                        ),
                                      ),
                                      const SizedBox(width: 66),
                                      Text(
                                        teamNameMap[todaySchedule!
                                            .opponentTeam] ??
                                            todaySchedule!.opponentTeam,
                                        style: const TextStyle(fontSize: 19,
                                            fontWeight: FontWeight.w800),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    todaySchedule!.gameDateTime.contains(' ')
                                        ? todaySchedule!.gameDateTime.split(
                                        ' ')[1]
                                        : '',
                                    style: const TextStyle(fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    '@ ${stadiumNameMap[todaySchedule!
                                        .stadium] ?? todaySchedule!.stadium}',
                                    style: const TextStyle(fontSize: 10,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
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
                            controller: ourScoreController,
                            hintText: '우리팀 스코어',
                            onChanged: (value) {
                              setState(() {
                                ourScore = value;
                              });
                              AmplitudeFlutter.getInstance().logEvent(
                                  'enter_diary_score', eventProperties: {
                                'event_type': 'Custom',
                                'component': 'form_submit',
                                'score_home': ourScore,
                                'importance': 'High',
                              });
                            },
                            isEditable: !widget.isEditMode,
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
                            controller: theirScoreController,
                            hintText: '상대팀 스코어',
                            onChanged: (value) {
                              setState(() {
                                opponentScore = value;
                              });
                              AmplitudeFlutter.getInstance().logEvent(
                                  'enter_diary_score', eventProperties: {
                                'event_type': 'Custom',
                                'component': 'form_submit',
                                'score_away': opponentScore,
                                'importance': 'High',
                              });
                            },
                            isEditable: !widget.isEditMode,
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
                            width: 360, // 감정 아이콘 전체 높이 (아이콘 크기에 따라 조절)

                            child: GridView.count(
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,

                              physics: const NeverScrollableScrollPhysics(),
                              childAspectRatio: 112 / 90,
                              // ✅ 카드 너비/높이 비율
                              children: List.generate(
                                  6, (index) => _emotionIcon(index)),
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
                      DiaryImagePicker(
                        initialImageUrl: mediaUrl,
                        onImageSelected: (image, bytes) {
                          setState(() {
                            _pickedImage = image;
                            _imageBytes = bytes;
                          });
                        },
                        enabled: !widget.isEditMode,
                      ),


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
                            controller: reviewController,
                            maxLines: 4,
                            maxLength: 132,
                            enabled: !widget.isEditMode,
                            style: TextStyle(
                              color: widget.isEditMode ? Colors.black : Colors
                                  .black, // ✅ 글자색
                            ),
                            onChanged: (value) {
                              setState(() {
                                reviewLength = value.length;
                              });
                              // ✅ 글자가 1자 이상 입력된 순간 한 번만 로그 전송

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
                              counterText: '',
                              // ✅ 기본 카운터 숨김
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: AppColors.gray300),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.gray300, // 수정 모드일 때 border
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: AppColors.gray300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: AppColors.gray700),
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


                      if (!widget.isEditMode)
                      // 버튼 2개
                        Column(
                          children: [
                            Center(
                              child: SizedBox(
                                width: 360,
                                height: 54,
                                child: ElevatedButton(

                                  onPressed: (isSeatButtonEnabled && !isSaving)
                                      ? () async {
                                    setState(() {
                                      isSaving = true; // 저장 시작 → 버튼 비활성화
                                    });

                                    try {
                                      if (widget.isEditMode) {
                                        final journalId = widget.journalId!;


                                        context.push(
                                          '/addseat',
                                          extra: {
                                            'journalId': journalId,
                                            'stadium': todaySchedule!.stadium,
                                            'gameDateTime': todaySchedule!
                                                .gameDateTime,
                                          },
                                        );

                                        return;
                                      }

                                      // 작성 모드 → S3 업로드 → 업로드 API 호출 → /addseat로 이동
                                      AmplitudeFlutter.getInstance().logEvent(
                                          'write_diary_review',
                                          eventProperties: {
                                            'event_type': 'Custom',
                                            'component': 'form_submit',
                                            'review_length': reviewController
                                                .text
                                                .trim()
                                                .length,
                                            'importance': 'High',
                                          });

                                      AmplitudeFlutter.getInstance().logEvent(
                                          'click_seat_review_write_start',
                                          eventProperties: {
                                            'event_type': 'Custom',
                                            'component': 'btn_click',
                                            'importance': 'High',
                                          });

                                      if (todaySchedule == null) {
                                        print('❗ 오늘 경기 정보가 없습니다.');
                                        return;
                                      }

                                      if (_pickedImage != null) {
                                        print('✅ 이미지 존재함, fileName 생성 시작');
                                        fileName = 'journal_${DateTime
                                            .now()
                                            .millisecondsSinceEpoch}.jpeg';
                                        final presignedUrl = await getPresignedUrl(
                                            fileName!, 'image/jpeg');
                                        print(
                                            '✅ presigned URL 결과: $presignedUrl');
                                        if (presignedUrl == null) return;

                                        print('📤 S3 업로드 시작');
                                        final uploaded = await uploadImageToS3(
                                            presignedUrl, _imageBytes!);
                                        print('📤 S3 업로드 결과: $uploaded');
                                        if (!uploaded) return;
                                      }


                                      final gameId = await getValidGameId(
                                        date: currentDate,
                                        myTeam: todaySchedule!.myTeam,
                                        opponentTeam: todaySchedule!
                                            .opponentTeam,
                                      );

                                      if (gameId == null) {
                                        print('❌ 유효한 경기 ID를 찾을 수 없음');
                                        return;
                                      }
                                      writtenStadiumCode =
                                          todaySchedule!.stadium;
                                      final journalId = await ApiService
                                          .uploadJournal(
                                        gameId: gameId,
                                        gameDateTime: DateTime.parse(
                                            todaySchedule!.gameDateTime),
                                        stadiumShortCode: todaySchedule!
                                            .stadium,
                                        opponentTeamShortCode: todaySchedule!
                                            .opponentTeam,
                                        ourScore: int.parse(ourScore),
                                        theirScore: int.parse(opponentScore),
                                        fileName: (fileName != null &&
                                            fileName!.isNotEmpty)
                                            ? fileName!
                                            : null,
                                        // ✅ null로 전달
                                        emotion: getEmotionKor(
                                            selectedEmotionIndex),
                                        reviewText: reviewController.text
                                            .trim()
                                            .isNotEmpty
                                            ? reviewController.text.trim()
                                            : ' ',
                                      );

                                      if (journalId == null) {
                                        print('❌ 업로드 실패로 journalId가 null입니다.');
                                        return;
                                      }
                                      print(
                                          '📍 화면 전환 → journalId: $journalId, stadium: $writtenStadiumCode, gameTime: ${todaySchedule!
                                              .gameDateTime}');

                                      context.push(
                                        '/addseat',
                                        extra: {
                                          'journalId': journalId,
                                          'stadium': todaySchedule!.stadium,
                                          'gameDateTime': todaySchedule!
                                              .gameDateTime,
                                        },
                                      );
                                    } finally {
                                      setState(() {
                                        isSaving = false; // 저장 완료 → 버튼 다시 활성화
                                      });
                                    }
                                  }
                                      : null, // 비활성화 상태


                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                    isSeatButtonEnabled
                                        ? AppColors.primary700
                                        : AppColors.gray200,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      side: isSeatButtonEnabled
                                          ? const BorderSide(
                                          color: AppColors.primary700)
                                          : BorderSide.none,
                                    ),
                                  ),
                                  child: isSaving
                                      ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white, // 버튼 배경색과 대비
                                    ),
                                  )
                                      : Text(
                                    '좌석 후기 작성하기',
                                    style: TextStyle(
                                      color: isSeatButtonEnabled
                                          ? Colors.white
                                          : AppColors.gray700,
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
                                // 작성 완료 버튼 내부
                                onPressed: widget.isEditMode || isFormValid
                                    ? () async {
                                  setState(() => isSaving = true);
                                  try {
                                    print('🟡 작성 모드 진입');

                                    if (todaySchedule == null) {
                                      print('❗ 오늘 경기 정보가 없습니다.');
                                      return;
                                    }
                                    print('✅ 오늘 경기 정보 있음');

                                    if (_pickedImage != null &&
                                        _imageBytes != null) {
                                      print('📸 이미지 있음, presigned URL 요청');
                                      fileName = 'journal_${DateTime
                                          .now()
                                          .millisecondsSinceEpoch}.jpeg';
                                      final presignedUrl = await getPresignedUrl(
                                          fileName!, 'image/jpeg');
                                      print('📫 presignedUrl: $presignedUrl');
                                      if (presignedUrl == null) return;

                                      final uploaded = await uploadImageToS3(
                                          presignedUrl,
                                          _imageBytes!); // ✅ Uint8List 사용
                                      print('📤 이미지 업로드 결과: $uploaded');
                                      if (!uploaded) return;
                                    }


                                    print('🎯 gameId 생성 시도');
                                    final gameId = await getValidGameId(
                                      date: currentDate,
                                      myTeam: todaySchedule!.myTeam,
                                      opponentTeam: todaySchedule!.opponentTeam,
                                    );
                                    print('🎯 gameId 결과: $gameId');
                                    if (gameId == null) {
                                      print('❌ 유효한 gameId 찾기 실패');
                                      return;
                                    }

                                    print('📤 uploadJournal 호출 시도');
                                    final journalId = await ApiService
                                        .uploadJournal(
                                      gameId: gameId,
                                      gameDateTime: DateTime.parse(
                                          todaySchedule!.gameDateTime),
                                      stadiumShortCode: todaySchedule!.stadium,
                                      opponentTeamShortCode: todaySchedule!
                                          .opponentTeam,
                                      ourScore: int.parse(ourScore),
                                      theirScore: int.parse(opponentScore),
                                      fileName: (fileName != null &&
                                          fileName!.isNotEmpty)
                                          ? fileName!
                                          : null,
                                      // ✅ null로 전달
                                      emotion: getEmotionKor(
                                          selectedEmotionIndex),
                                      reviewText: reviewController.text
                                          .trim()
                                          .isNotEmpty
                                          ? reviewController.text.trim()
                                          : ' ',
                                    );

                                    print('📦 journalId 응답: $journalId');

                                    if (journalId == null) {
                                      print('❌ 업로드 실패로 journalId가 null입니다.');
                                      return;
                                    }

                                    if (context.mounted) {
                                      print('🚀 context.go 실행');
                                      context.go('/diary');
                                    }
                                  } finally {
                                    setState(() => isSaving = false); // 저장 종료
                                  }
                                }
                                    : null,


                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  isFormValid ? Colors.white : AppColors
                                      .gray200,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    side: BorderSide(
                                      color: isFormValid
                                          ? AppColors.primary700
                                          : Colors.transparent,
                                    ),
                                  ),
                                ),
                                child: isSaving
                                    ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white, // 버튼 배경색과 대비
                                  ),
                                )
                                    : Text(
                                  widget.isEditMode ? '수정 완료' : '작성 완료',
                                  style: TextStyle(
                                    color:
                                    isFormValid
                                        ? AppColors.primary700
                                        : AppColors.gray700,
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
    final List<String> labels = ['짜릿함', '감동', '흡족', '답답함', '아쉬움', '분노'];
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
        if (widget.isEditMode) return; // 👉 수정 모드일 때 클릭 막기
        setState(() {
          selectedEmotionIndex = index;
        });
        // ✅ Amplitude 이벤트 로깅
        AmplitudeFlutter.getInstance().logEvent('select_diary_emotion',
            eventProperties: {
          'event_type': 'Custom',
          'component': 'btn_click',
          'emotion': labels[index],
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
  required TextEditingController controller,
  required ValueChanged<String> onChanged,
  required bool isEditable,
}) {
  return SizedBox(
    width: 140,
    height: 40,
    child: TextField(
      onChanged: onChanged,
      readOnly: !isEditable,

      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'Pretendard',
      ),
      keyboardType: TextInputType.number,
      controller: controller,

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
  final void Function(File image, Uint8List bytes) onImageSelected;

  final String? initialImageUrl;
  final bool enabled;

  const DiaryImagePicker({
    super.key,
    required this.onImageSelected,
    this.initialImageUrl,
    this.enabled = true,
  });

  @override
  State<DiaryImagePicker> createState() => _DiaryImagePickerState();
}

class _DiaryImagePickerState extends State<DiaryImagePicker> {
  File? _pickedImage;
  Uint8List? _pickedImageBytes;

  @override
  Widget build(BuildContext context) {
    Widget? content;

    // 1. 갤러리에서 사진을 선택한 경우
    if (_pickedImageBytes != null) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          _pickedImageBytes!,
          fit: BoxFit.fitWidth,
          width: double.infinity,
        ),
      );
    }

    // 2. 수정 모드에서 initialImageUrl이 있을 경우
    else if (!widget.enabled &&
        widget.initialImageUrl != null &&
        widget.initialImageUrl!.isNotEmpty) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          widget.initialImageUrl!,
          fit: BoxFit.fitWidth,
          width: double.infinity,
          // ✅ 여기서 실패했을 경우 기본 업로드 UI를 보여줌
          errorBuilder: (context, error, stackTrace) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: SvgPicture.asset(
                  "assets/icons/camera_icon.svg",
                  width: 28.3,
                  height: 28.3,
                ),
              ),
            );
          },
        ),
      );
    }
    else {
      // 그 외 (작성 모드 && 아직 사진 없음) → 기본 UI 보여줌
      content = _buildDefaultUploadBox();
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.enabled ? _pickImage : null,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFD9D9D9)),
          color: const Color(0xFFF5F5F5),
        ),
        child: content,
      ),
    );
  }
  Widget _buildDefaultUploadBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Center(
        child: SvgPicture.asset(
          "assets/icons/camera_icon.svg",
          width: 28.3,
          height: 28.3,
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (image != null) {
      final Uint8List bytes = await image.readAsBytes();

      setState(() {
        _pickedImageBytes = bytes;
      });

      widget.onImageSelected(File(image.path), bytes); // ❗️이제 bytes도 같이 넘겨줌



      AmplitudeFlutter.getInstance().logEvent('upload_diary_photo', eventProperties: {
        'event_type': 'Custom',
        'component': 'event',
        'photo_count': 1,
        'importance': 'High',
      });
    }
  }
}


Future<String?> getPresignedUrl(String fileName, String contentType) async {
  final prefs = await SharedPreferences.getInstance();
  final memberId = prefs.getInt('member_id'); // ✅ memberId 불러오기

  if (memberId == null) {
    print('❌ memberId 없음');
    return null;
  }

  final url = Uri.parse(
    'https://api.inninglog.shop/s3/journal/presigned?fileName=$fileName&contentType=$contentType&memberId=$memberId',
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    return json['data']; // presigned URL
  } else {
    print('❌ Presigned URL 발급 실패: ${response.body}');
    return null;
  }
}

Future<bool> uploadImageToS3(String presignedUrl, Uint8List bytes) async {
  final response = await http.put(
    Uri.parse(presignedUrl),
    headers: {
      'Content-Type': 'image/jpeg',
    },
    body: bytes,
  );

  return response.statusCode == 200;
}




Future<MyTeamSchedule?> loadScheduleFromPrefs(DateTime date) async {

  final prefs = await SharedPreferences.getInstance();
  final key = 'schedule_${DateFormat('yyyy-MM-dd').format(date)}';
  final jsonString = prefs.getString(key);
  if (jsonString == null) return null;


  final jsonData = jsonDecode(jsonString);
  return MyTeamSchedule.fromJson(jsonData);


}

int getEmotionIndex(String emotion) {
  const emotions = ['짜릿함', '감동', '흡족', '답답함', '아쉬움', '분노'];
  return emotions.indexOf(emotion);
}

Widget buildMediaWidget(String mediaUrl) {
  if (mediaUrl.isEmpty) {
    return const Text('이미지가 없습니다');
  }

  // 웹일 경우 무조건 network 이미지 사용
  if (kIsWeb || mediaUrl.startsWith('http')) {
    return Image.network(
      mediaUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
    );
  }

  // 모바일에서만 File 객체 사용
  try {
    final file = File(mediaUrl);
    if (!file.existsSync()) {
      return const Icon(Icons.broken_image);
    }
    return Image.file(file, fit: BoxFit.cover);
  } catch (e) {
    return const Icon(Icons.broken_image);
  }
}



String extractFileName(String? url) {
  if (url == null || url.isEmpty) return '';
  final uri = Uri.parse(url);
  final segments = uri.pathSegments;
  return segments.isNotEmpty ? segments.last : '';
}

