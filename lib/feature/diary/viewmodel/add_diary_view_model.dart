import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/service/api_service.dart';
import '../repositories/add_diary_repository.dart';
import '../../../shared/service/home_view.dart'; // MyTeamSchedule

class AddDiaryViewModel extends ChangeNotifier {
  final AddDiaryRepository repo;

  AddDiaryViewModel({required this.repo});

  // ====== 상태 ======
  bool isSaving = false;
  DateTime currentDate = DateTime.now();
  MyTeamSchedule? todaySchedule;

  // 폼 상태
  String ourScore = '';
  String opponentScore = '';
  int selectedEmotionIndex = -1;
  int reviewLength = 0;
  String reviewText = '';

  // 이미지 상태
  File? pickedImageFile;
  Uint8List? pickedImageBytes;
  String? initialMediaUrl; // 수정모드에서 서버에서 받아온 url
  bool hasSeatView = false;

  bool get isFormValid =>
      ourScore.isNotEmpty && opponentScore.isNotEmpty && selectedEmotionIndex != -1;

  // ====== init ======
  Future<void> init({
    required DateTime? initialDate,
    required bool isEditMode,
    required int? journalId,
  }) async {
    if (isEditMode && journalId != null) {
      await _loadJournalDetail(journalId);
    } else {
      currentDate = initialDate ?? DateTime.now();
      await updateScheduleForDate(currentDate);
    }
  }

  // ====== 일정 로딩 ======
  Future<void> updateScheduleForDate(DateTime date) async {
    final schedule = await _loadScheduleFromPrefs(date);
    currentDate = date;
    todaySchedule = schedule;
    notifyListeners();
  }

  Future<void> goToPreviousDay() async {
    await updateScheduleForDate(currentDate.subtract(const Duration(days: 1)));
  }

  Future<void> goToNextDay() async {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final next = currentDate.add(const Duration(days: 1));
    if (next.isAfter(todayOnly)) return;
    await updateScheduleForDate(next);
  }

  String formatDate(DateTime date) {
    final today = DateTime.now();
    final isToday = date.year == today.year && date.month == today.month && date.day == today.day;
    if (isToday) return 'Today';
    return DateFormat('MM.dd(E)', 'ko').format(date);
  }

  Future<MyTeamSchedule?> _loadScheduleFromPrefs(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'schedule_${DateFormat('yyyy-MM-dd').format(date)}';
    final jsonString = prefs.getString(key);
    if (jsonString == null) return null;
    return MyTeamSchedule.fromJson(jsonDecode(jsonString));
  }

  // ====== 수정모드 상세 로딩 ======
  Future<void> _loadJournalDetail(int journalId) async {
    final prefs = await SharedPreferences.getInstance();
    final memberId = prefs.getInt('member_id');
    if (memberId == null) throw Exception('member_id not found');

    final json = await repo.getJournalDetail(journalId: journalId, memberId: memberId);
    final data = json['data']['jourDetail'];

    // 서버 필드명 그대로 반영(너 코드 기준)
    currentDate = DateTime.tryParse(data['gameDate'] ?? '') ?? DateTime.now();
    ourScore = (data['ourScore'] ?? '').toString();
    opponentScore = (data['theirScore'] ?? '').toString();
    selectedEmotionIndex = _getEmotionIndex(data['emotion'] ?? '');
    reviewText = (data['review_text'] ?? '').toString();
    reviewLength = reviewText.length;

    initialMediaUrl = data['media_url'];
    final seatViewId = json['data']['seatViewId'];
    hasSeatView = seatViewId != null && seatViewId != 0;

    todaySchedule = MyTeamSchedule(
      gameId: json['gameId'],
      myTeam: data['supportTeamSC'] ?? '',
      opponentTeam: data['opponentTeamSC'] ?? '',
      gameDateTime: data['gameDate'] ?? '',
      stadium: data['stadiumSC'] ?? '',
    );

    notifyListeners();
  }

  // ====== 입력 핸들러 ======
  void setOurScore(String v) {
    ourScore = v;
    notifyListeners();
  }

  void setOpponentScore(String v) {
    opponentScore = v;
    notifyListeners();
  }

  void setEmotionIndex(int idx) {
    selectedEmotionIndex = idx;
    notifyListeners();
  }

  void setReviewText(String v) {
    reviewText = v;
    reviewLength = v.length;
    notifyListeners();
  }

  void setPickedImage(File file, Uint8List bytes) {
    pickedImageFile = file;
    pickedImageBytes = bytes;
    notifyListeners();
  }

  // ====== gameId + 경기 정보 조회 ======
  Future<GameInfoResponse?> getGameInfo({
    required DateTime date,
    required String myTeam,
    required String opponentTeam,
  }) async {
    final formattedDate = DateFormat('yyyyMMdd').format(date);
    final gameId1 = '${formattedDate}${opponentTeam}${myTeam}0';
    final gameId2 = '${formattedDate}${myTeam}${opponentTeam}0';

    final prefs = await SharedPreferences.getInstance();
    final memberId = prefs.getInt('member_id');
    if (memberId == null) return null;

    for (final gameId in [gameId1, gameId2]) {
      final data = await repo.getJournalContents(gameId: gameId, memberId: memberId);
      if (data != null) return GameInfoResponse.fromJson(data);
    }
    return null;
  }

  // ====== 저장(작성 완료 / 좌석후기 이동 버튼에서 공통으로 쓰게) ======
  Future<int?> submitJournal({required GameInfoResponse gameInfo}) async {
    isSaving = true;
    notifyListeners();

    try {
      // 1) 이미지 있으면 presigned + 업로드
      String? uploadedFileName;
      if (pickedImageBytes != null) {
        uploadedFileName = 'journal_${DateTime.now().millisecondsSinceEpoch}.jpeg';
        final presignedUrl = await ApiService.getPresignedUrl(
          fileName: uploadedFileName,
          contentType: 'image/jpeg',
        );
        if (presignedUrl == null) return null;

        final ok = await repo.uploadToS3(
          presignedUrl: presignedUrl,
          bytes: pickedImageBytes!,
          contentType: 'image/jpeg',
        );
        if (!ok) return null;
      }

      // 2) 업로드 API (gameId는 API에서 받아온 값 사용)
      final journalId = await ApiService.uploadJournal(
        gameId: gameInfo.gameId,
        stadiumSC: gameInfo.stadiumSC,
        opponentTeamSC: gameInfo.opponentTeamSC,
        gameDateTime: DateTime.parse(gameInfo.gameDate),
        ourScore: int.parse(ourScore),
        theirScore: int.parse(opponentScore),
        fileName: uploadedFileName,
        emotion: selectedEmotionIndex == -1 ? null : getEmotionKor(selectedEmotionIndex),
        reviewText: reviewText.trim().isEmpty ? null : reviewText.trim(),
        isPublic: true,
      );

      return journalId;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  String getEmotionKor(int index) {
    const emotions = ['짜릿함', '감동', '흡족', '답답함', '아쉬움', '분노'];
    if (index < 0 || index >= emotions.length) return '';
    return emotions[index];
  }

  int _getEmotionIndex(String emotion) {
    const emotions = ['짜릿함', '감동', '흡족', '답답함', '아쉬움', '분노'];
    return emotions.indexOf(emotion);
  }
}