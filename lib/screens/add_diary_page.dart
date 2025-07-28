import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:inninglog/service/api_service.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_colors.dart';
import 'dart:io';
import '../main.dart';
import '../models/home_view.dart';
import '../service/api_service.dart';
import 'add_seat_page.dart';
import 'package:http/http.dart' as http;
import '../service/api_service.dart';
import 'home_page.dart';


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
  String? fileName;
  DateTime currentDate = DateTime.now();

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
    final newDate = currentDate.add(const Duration(days: 1));
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
      print('🟡 initState 실행');
      print('🟡 isEditMode: ${widget.isEditMode}, journalId: ${widget.journalId}');


    } else {
      currentDate = widget.initialDate ?? DateTime.now();
      _updateScheduleForDate(currentDate);
    }


  }



  String? mediaUrl;

  Future<void> fetchJournalData(int journalId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final response = await http.get(
        Uri.parse('https://api.inninglog.shop/journals/detail/$journalId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('👉 받은 데이터: ${response.body}'); // ✅ 여기!

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final data = json['data']['jourDetail'];
        // ✅ presigned URL 먼저 await으로 가져오고
        String? presignedImageUrl = data['media_url'];

        print('📦 journalDetail data: $data');
        print('🖼️ presignedImageUrl: $presignedImageUrl');



        setState(() {
          currentDate = DateTime.tryParse(data['gameDate'] ?? '') ?? DateTime.now();
          ourScoreController.text = data['ourScore']?.toString() ?? '';
          theirScoreController.text = data['theirScore']?.toString() ?? ''; // ✅ 이걸로 수정
          selectedEmotionIndex = getEmotionIndex(data['emotion'] ?? '');
          reviewController.text = data['review_text'] ?? '';
          mediaUrl = presignedImageUrl;// 네트워크 URL로 저장
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
    final token = prefs.getString('access_token');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final baseUri = 'https://api.inninglog.shop/journals/contents?gameId=';


    // gameId1 확인
    final res1 = await http.get(Uri.parse('$baseUri$gameId1'), headers: headers);
    if (res1.statusCode == 200) {
      print('✅ 유효한 gameId 찾음: $gameId1');
      return gameId1;
    }

    // gameId2 확인
    final res2 = await http.get(Uri.parse('$baseUri$gameId2'), headers: headers);
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
        ? isFormValid  // 작성 모드: 점수, 감정 필수
        : isFormValid && !hasSeatView; // 수정 모드: 점수 감정 입력 && 아직 좌석 후기 없음



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
                    onPressed: () {
                  // ✅ Amplitude 이벤트 로깅
                  analytics.logEvent('click_diary_write_back', properties: {
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
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 19),
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
                            if (todaySchedule == null)

                              Padding(
                                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 19),
                                child:  Row(
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
                                        teamNameMap[todaySchedule!.myTeam] ?? todaySchedule!.myTeam,
                                        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
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
                                        teamNameMap[todaySchedule!.opponentTeam] ?? todaySchedule!.opponentTeam,
                                        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    todaySchedule!.gameDateTime.contains(' ')
                                        ? todaySchedule!.gameDateTime.split(' ')[1]
                                        : '',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    '@ ${stadiumNameMap[todaySchedule!.stadium] ?? todaySchedule!.stadium}',
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
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
                              analytics.logEvent('enter_diary_score', properties: {
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
                              analytics.logEvent('enter_diary_score', properties: {
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
                      DiaryImagePicker(
                        initialImageUrl: mediaUrl,
                        onImageSelected: (image) {
                          setState(() {
                            _pickedImage = image;
                          });
                        },
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
                                onPressed: isSeatButtonEnabled? () async {

                                  if (widget.isEditMode) {
                                    // 수정 모드 → PATCH
                                    final journalId = widget.journalId!;
                                    await ApiService.updateJournal(
                                      journalId: journalId,
                                      ourScore: int.parse(ourScore),
                                      theirScore: int.parse(opponentScore),
                                      mediaUrl: extractFileName(mediaUrl),
                                      emotion: getEmotionKor(selectedEmotionIndex),
                                      reviewText: reviewController.text.trim().isNotEmpty
                                          ? reviewController.text.trim()
                                          : ' ',

                                    );
                                    context.push(
                                      '/addseat',
                                      extra: {
                                        'journalId': journalId,
                                        'stadium': todaySchedule!.stadium,
                                        'gameDateTime': todaySchedule!.gameDateTime,
                                      },
                                    );
                                    return;
                                  }

                                  // 작성 모드 → S3 업로드 → 업로드 API 호출 → /addseat로 이동
                                  analytics.logEvent('write_diary_review', properties: {
                                    'event_type': 'Custom',
                                    'component': 'form_submit',
                                    'review_length': reviewController.text.trim().length,
                                    'importance': 'High',
                                  });

                                  analytics.logEvent('click_seat_review_write_start', properties: {
                                    'event_type': 'Custom',
                                    'component': 'btn_click',
                                    'importance': 'High',
                                  });

                                  if (todaySchedule == null) {
                                    print('❗ 오늘 경기 정보가 없습니다.');
                                    return;
                                  }

                                  if (_pickedImage != null) {
                                    fileName = 'journal_${DateTime.now().millisecondsSinceEpoch}.jpeg';
                                    final presignedUrl = await getPresignedUrl(fileName!, 'image/jpeg');
                                    if (presignedUrl == null) return;
                                    final uploaded = await uploadImageToS3(presignedUrl, _pickedImage!);
                                    if (!uploaded) return;
                                  }

                                  final gameId = await getValidGameId(
                                    date: currentDate,
                                    myTeam: todaySchedule!.myTeam,
                                    opponentTeam: todaySchedule!.opponentTeam,
                                  );

                                  if (gameId == null) {
                                    print('❌ 유효한 경기 ID를 찾을 수 없음');
                                    return;
                                  }

                                  final int? journalId = await ApiService.uploadJournal(
                                    gameId: gameId,
                                    gameDateTime: DateTime.parse(todaySchedule!.gameDateTime),
                                    stadiumShortCode: todaySchedule!.stadium,
                                    opponentTeamShortCode: todaySchedule!.opponentTeam,
                                    ourScore: int.parse(ourScore),
                                    theirScore: int.parse(opponentScore),
                                    fileName: fileName ?? '',
                                    emotion: getEmotionKor(selectedEmotionIndex),
                                    reviewText: reviewController.text.trim().isNotEmpty
                                        ? reviewController.text.trim()
                                        : ' ',

                                  );

                                  if (journalId == null) {
                                    print('❌ 업로드 실패로 journalId가 null입니다.');
                                    return;
                                  }

                                  context.push(
                                    '/addseat',
                                    extra: {
                                      'journalId': journalId,
                                      'stadium': todaySchedule!.stadium,
                                      'todaySchedule': todaySchedule?.toJson(),
                                    },
                                  );
                                }
                                    : null,


                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  isSeatButtonEnabled ? AppColors.primary700 : AppColors.gray200,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    side:  isSeatButtonEnabled
                                        ? const BorderSide(color: AppColors.primary700)
                                        : BorderSide.none,
                                  ),
                                ),
                                child: Text(
                               '좌석 후기 작성하기',
                                style: TextStyle(
                                    color:  isSeatButtonEnabled ? Colors.white : AppColors.gray700,
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
                                  print('🟢 [작성완료 버튼] 클릭됨');

                                  if (widget.isEditMode) {
                                    print('🟡 수정 모드 진입');
                                    final journalId = widget.journalId!;
                                    await ApiService.updateJournal(
                                      journalId: journalId,
                                      ourScore: int.parse(ourScore),
                                      theirScore: int.parse(opponentScore),
                                      mediaUrl: extractFileName(mediaUrl),
                                      emotion: getEmotionKor(selectedEmotionIndex),
                                      reviewText: reviewController.text.trim().isNotEmpty
                                          ? reviewController.text.trim()
                                          : ' ',

                                    );
                                    if (context.mounted) context.go('/diary');
                                    return;
                                  }

                                  // ✅ 작성 모드 로직
                                  print('🟡 작성 모드 진입');

                                  analytics.logEvent('write_diary_review', properties: {
                                    'event_type': 'Custom',
                                    'component': 'form_submit',
                                    'review_length': reviewController.text.trim().length,
                                    'importance': 'High',
                                  });

                                  analytics.logEvent('complete_diary_write', properties: {
                                    'event_type': 'Custom',
                                    'component': 'btn_click',
                                    'importance': 'High',
                                  });

                                  if (todaySchedule == null) {
                                    print('❗ 오늘 경기 정보가 없습니다.');
                                    return;
                                  }

                                  String? fileName;
                                  if (_pickedImage != null) {
                                    fileName = 'journal_${DateTime.now().millisecondsSinceEpoch}.jpeg';
                                    final presignedUrl = await getPresignedUrl(fileName, 'image/jpeg');
                                    if (presignedUrl == null) return;
                                    final uploaded = await uploadImageToS3(presignedUrl, _pickedImage!);
                                    if (!uploaded) return;
                                  }

                                  final gameId = await getValidGameId(
                                    date: currentDate,
                                    myTeam: todaySchedule!.myTeam,
                                    opponentTeam: todaySchedule!.opponentTeam,
                                  );

                                  if (gameId == null) {
                                    print('❌ 유효한 경기 ID를 찾을 수 없음');
                                    return;
                                  }

                                  final journalId = await ApiService.uploadJournal(
                                    gameId: gameId,
                                    gameDateTime: DateTime.parse(todaySchedule!.gameDateTime),
                                    stadiumShortCode: todaySchedule!.stadium,
                                    opponentTeamShortCode: todaySchedule!.opponentTeam,
                                    ourScore: int.parse(ourScore),
                                    theirScore: int.parse(opponentScore),
                                    fileName: fileName ?? '',
                                    emotion: getEmotionKor(selectedEmotionIndex),
                                    reviewText: reviewController.text.trim().isNotEmpty
                                        ? reviewController.text.trim()
                                        : ' ',

                                  );

                                  if (journalId == null) {
                                    print('❌ 업로드 실패로 journalId가 null입니다.');
                                    return;
                                  }

                                  if (context.mounted) {
                                    context.go('/diary'); // 👈 extra 없이도 기본 화면으로
                                  }
                                }
                                    : null,






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
                                widget.isEditMode ? '수정 완료' : '작성 완료',
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
        setState(() {
          selectedEmotionIndex = index;
        });
        // ✅ Amplitude 이벤트 로깅
        analytics.logEvent('select_diary_emotion', properties: {
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
  final void Function(File image) onImageSelected;
  final String? initialImageUrl;


  const DiaryImagePicker({super.key, required this.onImageSelected,  this.initialImageUrl,});


  @override
  State<DiaryImagePicker> createState() => _DiaryImagePickerState();
}

class _DiaryImagePickerState extends State<DiaryImagePicker> {
  File? _pickedImage;
  String? _initialImageUrl;

  @override
  void initState() {
    super.initState();
    _initialImageUrl = widget.initialImageUrl; // ✅ 이거 추가
  }



  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);



    if (image != null) {
      final file = File(image.path);
      setState(() {
        _pickedImage = file;
      });
      widget.onImageSelected(file);

      analytics.logEvent('upload_diary_photo', properties: {
        'event_type': 'Custom',
        'component': 'event',
        'photo_count': 1, // UT에서는 1장만 업로드하므로 고정
        'importance': 'High',
      });
    }
  }




  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_pickedImage != null) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          _pickedImage!,
          fit: BoxFit.fitWidth,
          width: double.infinity,
        ),
      );
    } else if (_initialImageUrl != null && _initialImageUrl!.isNotEmpty) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          _initialImageUrl!,
          fit: BoxFit.fitWidth,
          width: double.infinity,
          errorBuilder: (_, __, ___) {
            print('❌ 이미지 로드 실패!');
            return const Icon(Icons.broken_image);
          },
        ),
      );
    } else {
      content = Padding(
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
    print('📸 DiaryImagePicker _initialImageUrl: $_initialImageUrl');

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

Future<String?> getPresignedUrl(String fileName, String contentType) async {

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token'); // ✅ 토큰 불러오기

  final url = Uri.parse(
    'https://api.inninglog.shop/s3/journal/presigned?fileName=$fileName&contentType=$contentType',
  );
  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token', // ✅ 인증 헤더 추가
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    return json['data']; // presigned URL
  } else {
    print('❌ Presigned URL 발급 실패: ${response.body}');
    return null;
  }
}
Future<bool> uploadImageToS3(String presignedUrl, File file) async {
  final bytes = await file.readAsBytes();

  final response = await http.put(
    Uri.parse(presignedUrl),
    headers: {

      'Content-Type': 'image/jpeg',
    },
    body: bytes,
  );

  print('📤 S3 업로드 응답 코드: ${response.statusCode}');
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
  } else if (mediaUrl.startsWith('http')) {
    return Image.network(
      mediaUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
    );
  } else {
    final file = File(mediaUrl);
    if (!file.existsSync()) {
      return const Icon(Icons.broken_image);
    }
    return Image.file(
      file,
      fit: BoxFit.cover,
    );
  }
}


String extractFileName(String? url) {
  if (url == null || url.isEmpty) return '';
  final uri = Uri.parse(url);
  final segments = uri.pathSegments;
  return segments.isNotEmpty ? segments.last : '';
}




