import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'home_view.dart';
import '../../feature/home/screens/home_detail.dart';
import 'package:intl/intl.dart';


class ApiService {
  static const String baseUrl = 'https://api.inninglog.shop';


  /// 파싱까지 해서 바로 쓰기 좋은 함수
  static Future<HomeData?> fetchHomeData({String? accessToken}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = accessToken ?? prefs.getString('accessToken');
      if (token == null) {
        debugPrint('❌ accessToken 없음');
        return null;
      }

      final url = Uri.parse('$baseUrl/home/view');
      final res = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token', // ✅ 인증은 헤더로
          'Accept': 'application/json',
        },
      );

      debugPrint('GET /home/view → ${res.statusCode}');
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final data = body['data'];
        if (data == null) return null;
        return HomeData.fromJson(data);
      } else {
        debugPrint('응답 바디: ${res.body}');
        return null;
      }
    } catch (e) {
      debugPrint('🚨 fetchHomeData 에러: $e');
      return null;
    }
  }

  /// 디버깅용: 원본 Response가 필요할 때
  static Future<http.Response?> getHomeViewRaw({String? accessToken}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = accessToken ?? prefs.getString('accessToken');
      if (token == null) {
        debugPrint('❌ accessToken 없음');
        return null;
      }

      final url = Uri.parse('$baseUrl/home/view');
      return await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
    } catch (e) {
      debugPrint('🚨 getHomeViewRaw 에러: $e');
      return null;
    }
  }


  /// 직관 리포트 조회 (/report/main)
  /// - 파라미터 없음
  /// - Authorization: Bearer <accessToken>
  static Future<MyReportResponse?> fetchMyReport({String? accessToken}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = accessToken ?? prefs.getString('accessToken');
      if (token == null) {
        debugPrint('❌ accessToken 없음');
        return null;
      }

      final url = Uri.parse('$baseUrl/report/main');
      final res = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      debugPrint('GET /report/main → ${res.statusCode}');
      debugPrint('응답: ${res.body}');

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final data = body['data'];
        if (data == null) return null;
        return MyReportResponse.fromJson(data);
      }

      // ---- 에러 처리 ----
      Map<String, dynamic>? err;
      try {
        err = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {}

      final code = (err?['code'] ?? '').toString().toUpperCase();

      // 직관 기록 없음 (문서/서버 표기가 혼재할 수 있어 둘 다 처리)
      if (res.statusCode == 400 &&
          (code == 'NOVISITEDGAMES' || code == 'NO_VISITED_GAME')) {
        debugPrint('📭 직관 기록 없음');
        final nickname = prefs.getString('nickname') ?? '유저';
        return MyReportResponse(
          nickname: nickname,
          totalVisitedGames: 0,
          winGames: 0,
          loseGames: 0,
          drawGames: 0,
          winningRateHalPoongRi: 0,
          teamWinRate: 0,
          topBatters: const [],
          topPitchers: const [],
          bottomBatters: const [],
          bottomPitchers: const [],
        );
      }

      if (res.statusCode == 404) {
        debugPrint('❌ 존재하지 않는 회원');
        return null;
      }

      debugPrint('❌ 서버/요청 오류: ${res.statusCode} ${err?['message'] ?? ''}');
      return null;
    } catch (e) {
      debugPrint('🚨 fetchMyReport 에러: $e');
      return null;
    }
  }

  // static Future<GameInfoResponse?> fetchGameInfo(String gameId) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('access_token');
  //
  //   final url = Uri.parse('$baseUrl/journals/contents?gameId=$gameId');
  //   final response = await http.get(url, headers: {
  //     'Authorization': 'Bearer $token',
  //   });
  //
  //   if (response.statusCode == 200) {
  //     final jsonData = jsonDecode(response.body);
  //     return GameInfoResponse.fromJson(jsonData['data']);
  //   } else {
  //     print('❌ Game 정보 불러오기 실패: ${response.body}');
  //     return null;
  //   }
  // }

  /// 직관 일지 업로드용 Presigned URL 발급
  /// GET /s3/journal/presigned?fileName=...&contentType=...&memberId=...
  static Future<String?> getPresignedUrl({
    required String fileName,
    required String contentType,
  }) async {
    void log(Object? m) => print('[getPresignedUrl] $m');

    try {
      final prefs = await SharedPreferences.getInstance();
      final memberId = prefs.getInt('memberId') ?? prefs.getInt('member_id');
      if (memberId == null) {
        log('❌ SharedPreferences에 memberId 없음');
        return null;
      }

      final uri = Uri.parse(
        '$baseUrl/s3/journal/presigned'
            '?fileName=$fileName'
            '&contentType=$contentType'
            '&memberId=$memberId',
      );

      log('→ GET $uri');

      final res = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 15));

      log('→ status: ${res.statusCode}');
      log('→ body: ${res.body}');

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final url = body['data'] as String?;
        if (url == null || url.isEmpty) {
          log('⚠️ Presigned URL이 비어있음');
          return null;
        }
        log('✅ Presigned URL 발급 성공');
        return url;
      }

      if (res.statusCode == 400) {
        final msg = (jsonDecode(res.body)['message'] ?? '잘못된 요청').toString();
        throw Exception('잘못된 요청(400): $msg');
      }
      if (res.statusCode == 404) {
        throw Exception('리소스를 찾을 수 없음(404)');
      }
      if (res.statusCode >= 500) {
        throw Exception('서버 오류(${res.statusCode})');
      }

      throw Exception('요청 실패(${res.statusCode})');
    } on TimeoutException {
      throw Exception('요청 시간이 초과되었습니다.');
    } catch (e, st) {
      print('[getPresignedUrl] 🚨 $e\n$st');
      return null;
    }
  }


  /// 좌석 시야 업로드용 Presigned URL 발급
  /// GET /s3/seatView/presigned?fileName=...&contentType=...&memberId=...
  static Future<String?> getPresignedUrlSeat({
    required String fileName,
    required String contentType,
  }) async {
    void log(Object? m) => print('[getPresignedUrlSeat] $m');

    if (fileName
        .trim()
        .isEmpty || contentType
        .trim()
        .isEmpty) {
      log('❌ fileName 또는 contentType이 비어있음');
      return null;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      // memberId 키 혼재 방어
      final memberId = prefs.getInt('memberId') ?? prefs.getInt('member_id');
      if (memberId == null) {
        log('❌ SharedPreferences에 memberId 없음');
        return null;
      }

      final uri = Uri.parse(
        '$baseUrl/s3/seatView/presigned'
            '?fileName=$fileName'
            '&contentType=$contentType'
            '&memberId=$memberId',
      );

      log('→ GET $uri');

      final res = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 15));

      log('→ status: ${res.statusCode}');
      log('→ body: ${res.body}');

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final presignedUrl = body['data'] as String?;
        if (presignedUrl == null || presignedUrl.isEmpty) {
          log('⚠️ 200인데 data 없음');
          return null;
        }
        log('✅ Presigned URL 발급 성공');
        return presignedUrl;
      }

      if (res.statusCode == 400) {
        final msg = (jsonDecode(res.body)['message'] ?? '잘못된 요청').toString();
        throw Exception('잘못된 요청(400): $msg');
      }
      if (res.statusCode == 404) {
        throw Exception('리소스를 찾을 수 없음(404)');
      }
      if (res.statusCode >= 500) {
        throw Exception('서버 오류(${res.statusCode})');
      }

      throw Exception('요청 실패(${res.statusCode})');
    } on TimeoutException {
      throw Exception('요청 시간이 초과되었습니다.');
    } catch (e, st) {
      print('[getPresignedUrlSeat] 🚨 $e\n$st');
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


  static Future<int?> uploadJournal({
    required String gameId,
    String? fileName, // ✅ 선택
    required String stadiumShortCode,
    required String opponentTeamShortCode,
    required DateTime gameDateTime, // yyyy-MM-dd HH:mm
    required int ourScore,
    required int theirScore,
    required String emotion, // 감동/짜릿함/답답함/아쉬움/분노/흡족
    required String reviewText,
  }) async {
    void log(Object? m) => print('[uploadJournal] $m');

    // ---- 필수값 & 유효성 ----
    if (gameId
        .trim()
        .isEmpty) {
      log('❌ gameId 없음');
      return null;
    }
    if (stadiumShortCode
        .trim()
        .isEmpty) {
      log('❌ stadiumShortCode 없음');
      return null;
    }
    if (opponentTeamShortCode
        .trim()
        .isEmpty) {
      log('❌ opponentTeamShortCode 없음');
      return null;
    }

    const allowedEmotions = ['감동', '짜릿함', '답답함', '아쉬움', '분노', '흡족'];
    if (!allowedEmotions.contains(emotion)) {
      log('❌ emotion 값이 허용 목록이 아님: $emotion');
      return null;
    }
    if (ourScore < 0 || theirScore < 0) {
      log('❌ 점수는 0 이상이어야 함');
      return null;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final memberId = prefs.getInt('memberId') ?? prefs.getInt('member_id');
      if (memberId == null) {
        log('❌ memberId 없음');
        return null;
      }

      final token = prefs.getString('accessToken')?.trim();

      // 날짜 포맷
      String two(int n) => n.toString().padLeft(2, '0');
      final dt = gameDateTime;
      final gameDateStr = '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(
          dt.hour)}:${two(dt.minute)}';

      // 🔐 키 혼재 방어: SC/ShortCode 둘 다 보냄
      final bodyData = <String, dynamic>{
        'gameId': gameId,
        'gameDate': gameDateStr, // 호환용
        'gameDateTime': gameDateStr, // 요구 스펙
        'stadiumSC': stadiumShortCode, // 예시 키
        'stadiumShortCode': stadiumShortCode, // 문서 키
        'opponentTeamSC': opponentTeamShortCode, // 예시 키
        'opponentTeamShortCode': opponentTeamShortCode, // 문서 키
        'ourScore': ourScore,
        'theirScore': theirScore,
        'emotion': emotion,
        'review_text': reviewText,
      };

      // ✅ fileName은 선택: 값이 있을 때만 포함
      final cleanedFileName = fileName?.trim();
      if (cleanedFileName != null && cleanedFileName.isNotEmpty) {
        bodyData['fileName'] = cleanedFileName;
      }

      log('📤 body: ${jsonEncode(bodyData)}');

      final uri = Uri.parse('$baseUrl/journals/contents?memberId=$memberId');
      log('→ POST $uri');

      final headers = <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final res = await http
          .post(uri, headers: headers, body: jsonEncode(bodyData))
          .timeout(const Duration(seconds: 20));

      log('📡 status: ${res.statusCode}');
      log('📦 body: ${res.body}');

      // ✅ 성공 코드는 201
      if (res.statusCode == 201) {
        final decoded = jsonDecode(res.body) as Map<String, dynamic>;
        final journalId = decoded['data']?['journalId'];
        if (journalId is int) return journalId;
        if (journalId is String) return int.tryParse(journalId);
        return null;
      }

      Map<String, dynamic>? err;
      try {
        err = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {}

      if (res.statusCode == 400) {
        throw Exception('잘못된 요청(400): ${err?['message'] ?? '요청값이 올바르지 않습니다.'}');
      }
      if (res.statusCode == 404) {
        throw Exception(
            '리소스를 찾을 수 없음(404): ${err?['message'] ?? '존재하지 않는 회원입니다.'}');
      }
      if (res.statusCode >= 500) {
        throw Exception('서버 오류(${res.statusCode}).');
      }
      throw Exception(
          '요청 실패(${res.statusCode}): ${err?['message'] ?? '알 수 없는 오류'}');
    } catch (e, st) {
      print('[uploadJournal] 🚨 $e\n$st');
      return null;
    }
  }


  /// 본인 직관 일지 캘린더 조회
  /// GET /journals/calendar
  /// - 인증: Authorization: Bearer <accessToken>
  /// - 필터: resultScore (허용: '승' | '패' | '무승부' | 'WIN' | 'LOSE' | 'DRAW')
  static Future<List<Journal>> fetchJournalCalendar(
      {String? resultScore}) async {
    void log(Object? m) => print('[fetchJournalCalendar] $m');

    // resultScore 정규화: 한/영 입력 모두 허용 → 서버는 한글 값 사용
    String? _normalizeResultScore(String? v) {
      if (v == null) return null;
      final s = v.trim().toUpperCase();
      switch (s) {
        case '승':
        case 'WIN':
          return '승';
        case '패':
        case 'LOSE':
          return '패';
        case '무승부':
        case 'DRAW':
          return '무승부';
        default:
          return null; // 허용값 아니면 전송 안 함
      }
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken')?.trim();
      if (token == null || token.isEmpty) {
        throw Exception('로그인 토큰이 없습니다. 다시 로그인 해주세요.');
      }

      final normalized = _normalizeResultScore(resultScore);

      final query = <String, String>{
        if (normalized != null) 'resultScore': normalized,
      };

      final uri = Uri.https('api.inninglog.shop', '/journals/calendar', query);
      log('→ GET $uri');

      final res = await http
          .get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      )
          .timeout(const Duration(seconds: 15));

      log('→ status: ${res.statusCode}');
      log('→ body: ${res.body}');

      Map<String, dynamic>? body;
      try {
        final decoded = jsonDecode(res.body);
        body = decoded is Map<String, dynamic> ? decoded : null;
      } catch (_) {
        body = null;
      }

      if (res.statusCode == 200) {
        final data = body?['data'];
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map((e) => Journal.fromJson(e))
              .toList();
        }
        // data가 비정상이면 빈 리스트 반환(앱은 죽지 않게)
        log('⚠️ 200이지만 data 형식이 리스트가 아님 → 빈 리스트');
        return <Journal>[];
      }

      if (res.statusCode == 400) {
        final msg = (body?['message'] ?? '요청값이 올바르지 않습니다.').toString();
        throw Exception('잘못된 요청(400): $msg');
      }

      if (res.statusCode == 404) {
        final msg = (body?['message'] ?? '존재하지 않는 회원입니다.').toString();
        throw Exception('리소스를 찾을 수 없음(404): $msg');
      }

      if (res.statusCode >= 500) {
        throw Exception('서버 오류(${res.statusCode}).');
      }

      throw Exception(
          '요청 실패(${res.statusCode}): ${body?['message'] ?? '알 수 없는 오류'}');
    } on TimeoutException {
      throw Exception('요청 시간이 초과되었습니다. 네트워크 상태를 확인해주세요.');
    }
  }


  /// 본인 직관 일지 목록 - 모아보기(무한 스크롤)
  /// GET /journals/summary
  /// - 인증: Authorization: Bearer <accessToken>
  /// - 필터: resultScore = WIN | LOSE | DRAW (한글 입력도 허용 → 영문으로 변환)
  /// - 페이징: page, size
  static Future<List<Journal>> fetchJournalSummary({
    String? resultScore,
    int page = 0,
    int size = 10,
  }) async {
    void log(Object? m) => print('[fetchJournalSummary] $m');

    String? _normalizeResultScoreToEn(String? v) {
      if (v == null) return null;
      final s = v.trim().toUpperCase();
      switch (s) {
        case 'WIN':
        case '승':
          return 'WIN';
        case 'LOSE':
        case '패':
          return 'LOSE';
        case 'DRAW':
        case '무승부':
          return 'DRAW';
        default:
          return null; // 허용값 아니면 전송하지 않음
      }
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken')?.trim();
      if (token == null || token.isEmpty) {
        throw Exception('로그인 토큰이 없습니다. 다시 로그인 해주세요.');
      }

      final normalized = _normalizeResultScoreToEn(resultScore);

      final query = <String, String>{
        'page': '$page',
        'size': '$size',
        if (normalized != null) 'resultScore': normalized,
      };

      final uri = Uri.https('api.inninglog.shop', '/journals/summary', query);
      log('→ GET $uri');

      final res = await http
          .get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      )
          .timeout(const Duration(seconds: 15));

      log('→ status: ${res.statusCode}');
      log('→ body: ${res.body}');

      Map<String, dynamic>? body;
      try {
        final decoded = jsonDecode(res.body);
        body = decoded is Map<String, dynamic> ? decoded : null;
      } catch (_) {
        body = null;
      }

      if (res.statusCode == 200) {
        final data = body?['data'];
        if (data is Map<String, dynamic>) {
          final content = data['content'];
          if (content is List) {
            // NOTE: 서버 응답 키에 media_url(스네이크) 등이 있을 수 있으니
            // Journal.fromJson에서 스네이크/카멜 둘 다 처리되도록 해두면 안전.
            return content
                .whereType<Map<String, dynamic>>()
                .map((e) => Journal.fromJson(e))
                .toList();
          }
        }
        log('⚠️ 200이지만 data.content 없음/형식 불일치 → 빈 리스트');
        return <Journal>[];
      }

      if (res.statusCode == 400) {
        final msg = (body?['message'] ?? '요청값이 올바르지 않습니다.').toString();
        throw Exception('잘못된 요청(400): $msg');
      }

      if (res.statusCode == 404) {
        final msg = (body?['message'] ?? '존재하지 않는 회원입니다.').toString();
        throw Exception('리소스를 찾을 수 없음(404): $msg');
      }

      if (res.statusCode >= 500) {
        throw Exception('서버 오류(${res.statusCode}).');
      }

      throw Exception(
          '요청 실패(${res.statusCode}): ${body?['message'] ?? '알 수 없는 오류'}');
    } on TimeoutException {
      throw Exception('요청 시간이 초과되었습니다. 네트워크 상태를 확인해주세요.');
    }
  }


// Future<GameInfo?> fetchGameInfo(String gameId) async {
//   final prefs = await SharedPreferences.getInstance();
//   final token = prefs.getString('access_token');
//
//   final url = Uri.parse('https://api.inninglog.shop/journals/contents?gameId=$gameId');
//   final response = await http.get(
//     url,
//     headers: {
//       'Authorization': 'Bearer $token',
//     },
//   );
//
//   print('📡 [GameInfo] 응답 코드: ${response.statusCode}');
//   print('📦 [GameInfo] 응답 바디: ${response.body}');
//
//   if (response.statusCode == 200) {
//     final jsonBody = jsonDecode(response.body);
//     final data = jsonBody['data'];
//     return GameInfo.fromJson(data);
//   } else {
//     print('❌ GameInfo API 실패: ${response.body}');
//     return null;
//   }
// }

  Future<GameInfo?> fetchGameInfoByGameId(String gameId) async {
    void log(Object? m) => print('[fetchGameInfoByGameId] $m');

    final gid = gameId.trim();
    if (gid.isEmpty) {
      log('❌ gameId 비어있음');
      return null;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken')?.trim();

      if (token == null || token.isEmpty) {
        log('❌ accessToken 없음 (로그인 필요)');
        return null;
      }

      final uri = Uri.https('api.inninglog.shop', '/journals/contents', {
        'gameId': gid,
      });

      log('→ GET $uri');

      final res = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      log('→ status: ${res.statusCode}');
      log('→ body: ${res.body}');

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final data = body['data'];
        if (data == null) return null;
        return GameInfo.fromJournalContentJson(data);
      }

      if (res.statusCode == 400) {
        log('❌ 잘못된 요청(400): ${res.body}');
        return null;
      }
      if (res.statusCode == 404) {
        log('❌ 존재하지 않는 회원(404)');
        return null;
      }

      log('❌ 요청 실패: ${res.statusCode}');
      return null;
    } catch (e, st) {
      print('[fetchGameInfoByGameId] 🚨 $e\n$st');
      return null;
    }
  }


  Future<bool> uploadToS3(String presignedUrl, File file) async {
    final bytes = await file.readAsBytes();
    final res = await http.put(
      Uri.parse(presignedUrl),
      headers: {'Content-Type': 'image/jpeg'},
      body: bytes,
    );
    return res.statusCode == 200;
  }


  /// 좌석 시야 업로드
  /// POST /seatViews/contents
  /// - JWT 인증 필요 (Authorization 헤더)
  /// - 성공: 201, data.seatViewId 반환
  static Future<int?> uploadSeatView({
    required int journalId,
    required String stadiumShortCode,
    required String zoneShortCode,
    required String section,
    required String seatRow,
    required List<String> emotionTagCodes,
    required String fileName,
  }) async {
    void log(Object? m) => print('[uploadSeatView] $m');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken')?.trim();
      if (token == null || token.isEmpty) {
        log('❌ accessToken 없음');
        return null;
      }

      final uri = Uri.parse('$baseUrl/seatViews/contents');

      final body = {
        "journalId": journalId,
        "stadiumShortCode": stadiumShortCode,
        "zoneShortCode": zoneShortCode,
        "section": section,
        "seatRow": seatRow,
        "emotionTagCodes": emotionTagCodes,
        "fileName": fileName, // Presigned URL에서 사용한 파일명만!
      };

      log('📤 좌석 시야 업로드 요청');
      log('URL: $uri');
      log('BODY: ${jsonEncode(body)}');

      final res = await http
          .post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      )
          .timeout(const Duration(seconds: 20));

      log('📡 status: ${res.statusCode}');
      log('📦 body: ${res.body}');

      if (res.statusCode == 201) {
        final decoded = jsonDecode(res.body) as Map<String, dynamic>;
        final seatViewId = decoded['data']?['seatViewId'];
        if (seatViewId is int) return seatViewId;
        if (seatViewId is String) return int.tryParse(seatViewId);
        return null;
      }

      // 에러 처리
      Map<String, dynamic>? err;
      try {
        err = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {}

      if (res.statusCode == 400) {
        throw Exception('잘못된 요청(400): ${err?['message'] ?? '요청값이 올바르지 않습니다.'}');
      }
      if (res.statusCode == 404) {
        throw Exception(
            '리소스를 찾을 수 없음(404): ${err?['message'] ?? '존재하지 않는 회원입니다.'}');
      }
      if (res.statusCode >= 500) {
        throw Exception('서버 오류(${res.statusCode}).');
      }

      throw Exception(
          '요청 실패(${res.statusCode}): ${err?['message'] ?? '알 수 없는 오류'}');
    } on TimeoutException {
      throw Exception('요청 시간이 초과되었습니다.');
    } catch (e, st) {
      print('[uploadSeatView] 🚨 $e\n$st');
      return null;
    }
  }


  /// 특정 날짜의 내 응원팀 경기 일정 조회 (팝업)
  /// GET /journals/schedule?gameDate=YYYY-MM-DD
  /// - 인증: Authorization: Bearer <accessToken>
  /// - 반환: data(Map) 또는 경기 없으면 null
  static Future<Map<String, dynamic>?> fetchScheduleForDate(
      DateTime date) async {
    void log(Object? m) => print('[fetchScheduleForDate] $m');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken')?.trim();
      if (token == null || token.isEmpty) {
        log('❌ accessToken 없음');
        return null;
      }

      final gameDate = DateFormat('yyyy-MM-dd').format(date);

      final uri = Uri.https(
        'api.inninglog.shop',
        '/journals/schedule',
        {'gameDate': gameDate},
      );

      log('→ GET $uri');

      final res = await http
          .get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      )
          .timeout(const Duration(seconds: 15));

      log('→ status: ${res.statusCode}');
      log('→ body: ${res.body}');

      // 파싱
      Map<String, dynamic>? body;
      try {
        final decoded = jsonDecode(res.body);
        body = decoded is Map<String, dynamic> ? decoded : null;
      } catch (_) {
        body = null;
      }

      if (res.statusCode == 200) {
        // 경기 없으면 data가 null일 수 있음
        final data = body?['data'];
        if (data == null) return null;

        // 키 혼재 방어(opponentSC / opponentTeamSC 등)
        final map = Map<String, dynamic>.from(data as Map);
        if (map['opponentTeamSC'] == null && map['opponentSC'] != null) {
          map['opponentTeamSC'] = map['opponentSC'];
        }
        if (map['gameDateTime'] == null && map['gameDate'] != null) {
          map['gameDateTime'] = map['gameDate']; // UI에서 일관 키로 쓰려면 편의상 추가
        }
        return map;
      }

      if (res.statusCode == 400) {
        throw Exception(
            '잘못된 요청(400): ${(body?['message'] ?? '요청값이 올바르지 않습니다.')}');
      }
      if (res.statusCode == 404) {
        throw Exception(
            '리소스를 찾을 수 없음(404): ${(body?['message'] ?? '존재하지 않는 회원입니다.')}');
      }
      if (res.statusCode >= 500) {
        throw Exception('서버 오류(${res.statusCode})');
      }

      throw Exception(
          '요청 실패(${res.statusCode}): ${body?['message'] ?? '알 수 없는 오류'}');
    } on TimeoutException {
      throw Exception('요청 시간이 초과되었습니다. 네트워크 상태를 확인해주세요.');
    } catch (e, st) {
      print('[fetchScheduleForDate] 🚨 $e\n$st');
      return null;
    }
  }


  Future<JournalDetail?> fetchJournalDetail(int journalId) async {
    final response = await http.get(
      Uri.parse('https://api.inninglog.shop/journals/detail/$journalId'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data']['jourDetail'];
      return JournalDetail.fromJson(data);
    } else {
      print('❌ 상세 조회 실패: ${response.statusCode}');
      return null;
    }
  }


  /// 좌석 시야 갤러리 조회 (최신순)
  static Future<List<SeatView>> fetchSeatViews({
    required String stadiumShortCode,
    String? zoneShortCode,
    String? section,
    String? seatRow,
    int page = 0,
    int size = 10,
  }) async {
    void log(Object? m) => print('[fetchSeatViews] $m');

    // 파라미터 정리
    final cleanedStadium = stadiumShortCode.trim();
    final cleanedZone =
    (zoneShortCode
        ?.trim()
        .isNotEmpty ?? false) ? zoneShortCode!.trim() : null;
    final cleanedSection =
    (section
        ?.trim()
        .isNotEmpty ?? false) ? section!.trim() : null;
    final cleanedRow =
    (seatRow
        ?.trim()
        .isNotEmpty ?? false) ? seatRow!.trim() : null;

    if (cleanedStadium.isEmpty) {
      throw ArgumentError('stadiumShortCode는 필수입니다.');
    }
    final hasZone = cleanedZone != null;
    final hasSection = cleanedSection != null;

    if (cleanedRow != null && !hasZone && !hasSection) {
      throw ArgumentError('seatRow는 단독 사용 불가입니다. 최소 zoneShortCode 또는 section을 함께 전달하세요.');
    }


    final query = <String, String>{
      'stadiumShortCode': cleanedStadium,
      if (cleanedZone != null) 'zoneShortCode': cleanedZone,
      if (cleanedSection != null) 'section': cleanedSection,
      if (cleanedRow != null) 'seatRow': cleanedRow,
      'page': '$page',
      'size': '$size',
    };

    // ✅ uri 먼저 만들기
    final uri = Uri.https(
        'api.inninglog.shop', '/seatViews/normal/gallery', query);
    log('→ GET $uri');

    // ✅ 토큰 붙이기
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken')?.trim();

    try {
      final res = await http
          .get(
        uri,
        headers: {
          'Accept': 'application/json',
          if (token != null &&
              token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      )
          .timeout(const Duration(seconds: 15));

      log('→ status: ${res.statusCode}');
      log('→ body: ${res.body}');

      // JSON 파싱
      Map<String, dynamic>? body;
      try {
        final decoded = jsonDecode(res.body);
        body = decoded is Map<String, dynamic> ? decoded : null;
      } catch (_) {
        body = null;
      }

      if (res.statusCode == 200) {
        final data = body?['data'];
        if (data is Map<String, dynamic>) {
          final content = data['content'];
          if (content is List) {
            return content
                .whereType<Map<String, dynamic>>()
                .map((e) => SeatView.fromJson(e))
                .toList();
          }
        }
        log('⚠️ 200이지만 content 없음/형식 불일치 → 빈 리스트 반환');
        return <SeatView>[];
      }

      if (res.statusCode == 401) {
        throw Exception('인증이 필요합니다(401). accessToken 확인/로그인 필요');
      }

      if (res.statusCode == 400) {
        final code = (body?['code'] ?? '').toString().toUpperCase();
        final msg = (body?['message'] ?? '').toString();
        if (code == 'BAD_REQUEST' && msg.contains('열 정보만으로는')) {
          throw ArgumentError('seatRow 단독 검색 불가: zoneShortCode를 함께 전달하세요.');
        }
        throw Exception('잘못된 요청(400): ${msg.isEmpty ? code : msg}');
      }

      if (res.statusCode >= 500) {
        throw Exception('서버 오류(${res.statusCode})');
      }

      throw Exception(
          '요청 실패(${res.statusCode}): ${body?['message'] ?? '알 수 없는 오류'}');
    } on TimeoutException {
      throw Exception('요청 시간이 초과되었습니다. 네트워크 상태를 확인해주세요.');
    }
  }


  // /// 해시태그 기반 좌석 시야 갤러리 조회 (최신순)
  //
  // static Future<List<SeatView>> fetchSeatViewsByHashtag({
  //   required String stadiumShortCode,
  //   required List<String> hashtagCodes,
  //   int page = 0,
  //   int size = 10,
  // }) async {
  //   void log(Object? m) => print('[fetchSeatViewsByHashtag] $m');
  //
  //   // 파라미터 정리/검증
  //   final cleanedStadium = stadiumShortCode.trim();
  //   final cleanedTags = hashtagCodes
  //       .map((e) => e.trim())
  //       .where((e) => e.isNotEmpty)
  //       .toList(growable: false);
  //
  //   if (cleanedStadium.isEmpty) {
  //     throw ArgumentError('stadiumShortCode는 필수입니다.');
  //   }
  //   if (cleanedTags.isEmpty || cleanedTags.length > 5) {
  //     throw ArgumentError('해시태그는 최소 1개, 최대 5개까지 선택해야 합니다.');
  //   }
  //
  //   // Dart의 Uri.https는 queryParameters에 List를 넣으면 같은 키로 반복 쿼리 생성됨
  //   // 예: ...?hashtagCodes=TAG1&hashtagCodes=TAG2
  //   final query = <String, dynamic>{
  //     'stadiumShortCode': cleanedStadium,
  //     'hashtagCodes': cleanedTags, // ← 반복 파라미터
  //     'page': '$page',
  //     'size': '$size',
  //   };
  //
  //   final uri = Uri.https(
  //       'api.inninglog.shop', '/seatViews/hashtag/gallery', query);
  //
  //   log('→ GET $uri');
  //
  //   try {
  //     final res = await http
  //         .get(uri, headers: {'Accept': 'application/json'})
  //         .timeout(const Duration(seconds: 15));
  //
  //     log('→ status: ${res.statusCode}');
  //     log('→ body: ${res.body}');
  //
  //     Map<String, dynamic>? body;
  //     try {
  //       final decoded = jsonDecode(res.body);
  //       body = decoded is Map<String, dynamic> ? decoded : null;
  //     } catch (_) {
  //       body = null;
  //     }
  //
  //     if (res.statusCode == 200) {
  //       final data = body?['data'];
  //       if (data is Map<String, dynamic>) {
  //         final content = data['content'];
  //         if (content is List) {
  //           return content
  //               .whereType<Map<String, dynamic>>()
  //               .map((e) => SeatView.fromJson(e))
  //               .toList();
  //         }
  //       }
  //       log('⚠️ 200이지만 content 없음/형식 불일치 → 빈 리스트 반환');
  //       return <SeatView>[];
  //     }
  //
  //     if (res.statusCode == 400) {
  //       final msg = (body?['message'] ?? '').toString();
  //       final code = (body?['code'] ?? '').toString().toUpperCase();
  //       if (code == 'BAD_REQUEST' && msg.contains('해시태그')) {
  //         throw ArgumentError('해시태그 개수 제한 위반: $msg');
  //       }
  //       throw Exception('잘못된 요청(400): ${msg.isEmpty ? code : msg}');
  //     }
  //
  //     if (res.statusCode == 404) {
  //       throw Exception('리소스를 찾을 수 없습니다 (404).');
  //     }
  //
  //     if (res.statusCode >= 500) {
  //       throw Exception('서버 오류(${res.statusCode}).');
  //     }
  //
  //     throw Exception(
  //         '요청 실패(${res.statusCode}): ${body?['message'] ?? '알 수 없는 오류'}');
  //   } on TimeoutException {
  //     throw Exception('요청 시간이 초과되었습니다. 네트워크 상태를 확인해주세요.');
  //   }
  // }


  /// 특정 좌석 시야 상세 조회
  static Future<SeatViewDetail> fetchSeatViewDetail(int seatViewId) async {
    void log(Object? m) => print('[fetchSeatViewDetail] $m');

    final uri = Uri.https('api.inninglog.shop', '/seatViews/$seatViewId');
    log('→ GET $uri');

    // ✅ 토큰 붙이기 (갤러리 조회랑 동일)
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken')?.trim();

    try {
      final res = await http
          .get(
        uri,
        headers: {
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      )
          .timeout(const Duration(seconds: 15));

      log('→ status: ${res.statusCode}');
      log('→ body: ${res.body}');

      Map<String, dynamic>? body;
      try {
        final decoded = jsonDecode(res.body);
        body = decoded is Map<String, dynamic> ? decoded : null;
      } catch (_) {
        body = null;
      }

      // ✅ 200 파싱 (스웨거: body.data 안에 payload)
      if (res.statusCode == 200) {
        final data = body?['data'];
        if (data is Map<String, dynamic>) {
          return SeatViewDetail.fromJson(data);
        }
        throw Exception('조회 성공(200)이지만 data 형식이 올바르지 않습니다.');
      }

      // ✅ 스웨거에는 없지만 실제 서버에서 내려오는 케이스(너 로그)
      if (res.statusCode == 401) {
        throw Exception('인증이 필요합니다(401). accessToken 확인/로그인 필요');
      }

      if (res.statusCode == 400) {
        final msg = (body?['message'] ?? '').toString();
        throw Exception(
            '잘못된 요청(400): ${msg.isEmpty ? '요청값이 올바르지 않습니다.' : msg}');
      }

      if (res.statusCode == 404) {
        final msg = (body?['message'] ?? '').toString();
        throw Exception(
            '리소스를 찾을 수 없습니다(404): ${msg.isEmpty ? '존재하지 않는 데이터' : msg}');
      }

      if (res.statusCode >= 500) {
        final msg = (body?['message'] ?? '').toString();
        throw Exception('서버 오류(${res.statusCode}): ${msg.isEmpty
            ? '서버에 문제가 발생했습니다.'
            : msg}');
      }

      final msg = (body?['message'] ?? '').toString();
      throw Exception(
          '요청 실패(${res.statusCode}): ${msg.isEmpty ? '알 수 없는 오류' : msg}');
    } on TimeoutException {
      throw Exception('요청 시간이 초과되었습니다. 네트워크 상태를 확인해주세요.');
    }
  }
}