import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/home_view.dart';
import '../screens/home_detail.dart';
import 'package:intl/intl.dart';


class ApiService {
  static const String baseUrl = 'https://api.inninglog.shop';


  static Future<http.Response?> getHomeView() async {
    final prefs = await SharedPreferences.getInstance();
    final memberId = prefs.getInt('member_id');

    if (memberId == null) {
      print('❌ memberId 없음');
      return null;
    }

    final url = Uri.parse('$baseUrl/home/view?memberId=$memberId');

    return await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );
  }


  static Future<HomeData?> fetchHomeData() async {
    final prefs = await SharedPreferences.getInstance();
    final memberId = prefs.getInt('member_id'); // 🔑 SharedPreferences에 저장된 memberId 사용

    if (memberId == null) {
      print('❌ memberId 없음');
      return null;
    }

    final url = Uri.parse(
        '$baseUrl/home/view?memberId=$memberId'); // 🧭 쿼리 파라미터로 전달

    final response = await http.get(url); // 🔓 Authorization 헤더 제거

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      return HomeData.fromJson(jsonBody['data']);
    } else if (response.statusCode == 404) {
      print('❌ 존재하지 않는 회원입니다');
      return null;
    } else {
      print('❌ API 오류: ${response.statusCode} - ${response.body}');
      return null;
    }
  }


  static Future<MyReportResponse?> fetchMyReport() async {
    final prefs = await SharedPreferences.getInstance();
    final memberId = prefs.getInt('member_id');

    if (memberId == null) {
      print('❌ memberId 없음');
      return null;
    }

    final url = Uri.parse('$baseUrl/report/main?memberId=$memberId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return MyReportResponse.fromJson(json['data']);
    } else {
      final errorJson = jsonDecode(response.body);
      if (errorJson['code'] == 'NO_VISITED_GAME') {
        print('📭 직관 기록 없음');
        return MyReportResponse(
          totalVisitedGames: 0,
          winGames: 0,
          loseGames: 0,
          drawGames: 0,
          winningRateHalPoongRi: 0,
          teamWinRate: 0,
          topBatters: [],
          topPitchers: [],
          bottomBatters: [],
          bottomPitchers: [],
          nickname: '유저',
        );
      }
      print('❌ API 오류: ${errorJson['message']}');
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


  static Future<String?> getPresignedUrl(String fileName,
      String contentType) async {
    final url = Uri.parse(
        '$baseUrl/s3/journal/presigned?fileName=$fileName&contentType=$contentType');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'];
    } else {
      print('❌ Presigned URL 발급 실패: ${response.body}');
      return null;
    }
  }

  static Future<String?> getPresignedUrlSeat({
    required String fileName,
    required String contentType,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final memberId = prefs.getInt('member_id');

    if (memberId == null) {
      print('❌ SharedPreferences에 member_id 없음');
      return null;
    }

    final url = Uri.parse(
      '$baseUrl/s3/seatView/presigned'
          '?fileName=$fileName'
          '&contentType=$contentType'
          '&memberId=$memberId',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final presignedUrl = body['data'];
      print('📦 Presigned URL 발급 성공: $presignedUrl');
      return presignedUrl;
    } else {
      print('❌ Presigned URL 발급 실패: ${response.statusCode}');
      print('❌ 응답 내용: ${response.body}');
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
    String? fileName,
    required String stadiumShortCode,
    required String opponentTeamShortCode,
    required DateTime gameDateTime,
    required int ourScore,
    required int theirScore,
    required String emotion,
    required String reviewText,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final memberId = prefs.getInt('member_id');

    if (memberId == null) {
      print('❌ memberId 없음');
      return null;
    }

    final bodyData = {
      "gameId": gameId,
      "gameDate": DateFormat('yyyy-MM-dd HH:mm').format(gameDateTime),
      "stadiumSC": stadiumShortCode,
      "opponentTeamSC": opponentTeamShortCode,
      "ourScore": ourScore,
      "theirScore": theirScore,
      "emotion": emotion,
      "review_text": reviewText,
      if (fileName != null && fileName.isNotEmpty) "fileName": fileName,
    };

    print('📤 보낼 바디: ${jsonEncode(bodyData)}');

    final uri = Uri.parse('$baseUrl/journals/contents?memberId=$memberId');

    final response = await http.post(
      uri,
      headers: { 'Content-Type': 'application/json' },
      body: jsonEncode(bodyData),
    );


    print('📡 응답 코드: ${response.statusCode}');
    print('📦 응답 바디: ${response.body}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'];
      final journalId = data['journalId'];
      return journalId;
    } else {
      print('❌ 일지 업로드 실패: ${response.body}');
      return null;
    }
  }


  static Future<List<Journal>> fetchJournalCalendar(
      {String? resultScore}) async {
    final prefs = await SharedPreferences.getInstance();
    final memberId = prefs.getInt('member_id');

    if (memberId == null) throw Exception('No memberId found');

    // 📌 쿼리 파라미터 구성
    final queryParams = {
      'memberId': memberId.toString(),
      if (resultScore != null) 'resultScore': resultScore,
    };

    final uri = Uri.https(
      'api.inninglog.shop',
      '/journals/calendar',
      queryParams,
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body)['data'] as List;
      return jsonData.map((e) => Journal.fromJson(e)).toList();
    } else {
      print('❌ 응답 실패: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to fetch calendar');
    }
  }


  static Future<List<Journal>> fetchJournalSummary({
    String? resultScore,
    int page = 0,
    int size = 10,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final memberId = prefs.getInt('member_id');

    if (memberId == null) {
      throw Exception('No memberId found');
    }

    final queryParams = {
      'memberId': memberId.toString(), // ✅ memberId 추가
      'page': '$page',
      'size': '$size',
      if (resultScore != null) 'resultScore': resultScore,
    };

    final uri = Uri.https(
        'api.inninglog.shop', '/journals/summary', queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      print('[🐛 응답 JSON] ${response.body}');
      final jsonData = jsonDecode(response.body);
      final List content = jsonData['data']['content'];

      return content.map((j) => Journal.fromJson(j)).toList();
    } else {
      throw Exception('요청 실패: ${response.statusCode}');
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
    final prefs = await SharedPreferences.getInstance();
    final memberId = prefs.getString('member_id');

    if (memberId == null) {
      print('❌ memberId 없음');
      return null;
    }

    final url = Uri.parse(
        'https://api.inninglog.shop/journals/contents?gameId=$gameId&memberId=$memberId');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'];
      return GameInfo.fromJournalContentJson(data);
    } else {
      print('❌ 경기 정보 조회 실패: ${response.body}');
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


  static Future<void> uploadSeatView({
    required int journalId,
    required String stadiumShortCode,
    required String zoneShortCode,
    required String section,
    required String seatRow,
    required List<String> emotionTagCodes,
    required String fileName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final memberId = prefs.getInt('member_id');

    if (memberId == null) {
      print('❌ SharedPreferences에서 member_id를 찾을 수 없습니다.');
      return;
    }

    final url = Uri.parse(
      'https://api.inninglog.shop/seatViews/contents?memberId=$memberId',
    );

    final body = {
      "journalId": journalId,
      "stadiumShortCode": stadiumShortCode,
      "zoneShortCode": zoneShortCode,
      "section": section,
      "seatRow": seatRow,
      "emotionTagCodes": emotionTagCodes,
      "fileName": fileName,
    };

    print('📤 좌석 시야 업로드 요청');
    print('URL: $url');
    print('BODY: ${jsonEncode(body)}');


    final res = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode == 200) {
      print('✅ 좌석 시야 업로드 성공!');
    } else {
      print('❌ 좌석 시야 업로드 실패: ${res.statusCode}');
      print('❌ 응답 내용: ${res.body}');
    }
  }



  static Future<Map<String, dynamic>?> fetchScheduleForDate(
      DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final memberId = prefs.getInt('member_id');
    if (memberId == null) return null;

    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final url = Uri.parse(
      'https://api.inninglog.shop/journals/schedule?memberId=$memberId&gameDate=$formattedDate',
    );

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print('✅ 경기 일정 조회 성공: ${response.statusCode} ${response.body}');
      final body = jsonDecode(response.body);
      return body['data'];
    } else {
      print('❌ 경기 일정 조회 실패: ${response.statusCode} ${response.body}');
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


  static Future<List<String>> fetchSeatViews({
    required String stadiumShortCode,
    String? zoneShortCode,
    String? section,
    String? seatRow,
    int page = 0,
    int size = 10,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final memberId = prefs.getInt('member_id');
    if (memberId == null) throw Exception('memberId가 존재하지 않습니다.');

    final cleanedZone = zoneShortCode?.trim().isNotEmpty == true ? zoneShortCode!.trim() : null;
    final cleanedSection = section?.trim().isNotEmpty == true ? section!.trim() : null;
    final cleanedRow = seatRow?.trim().isNotEmpty == true ? seatRow!.trim() : null;

    final uri = Uri.https('api.inninglog.shop', '/seatViews/normal/gallery', {
      'memberId': '$memberId', // ✅ 필수 파라미터 추가
      'stadiumShortCode': stadiumShortCode,
      if (cleanedZone != null) 'zoneShortCode': cleanedZone,
      if (cleanedSection != null) 'section': cleanedSection,
      if (cleanedRow != null) 'seatRow': cleanedRow,
      'page': '$page',
      'size': '$size',
    });

    print('🧩 전달된 zoneShortCode: "$zoneShortCode"');
    print('🧩 전달된 section: "$section"');
    print('📦 최종 요청 URI: $uri');


    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      final List<dynamic> contents = json['data']['content'];
      return contents.map<String>((item) => item['viewMediaUrl'] as String).toList();
    } else {
      throw Exception('좌석 시야 조회 실패: ${res.body}');
    }
  }



  static Future<List<SeatView>> fetchSeatViewsByHashtag({
    required String stadiumShortCode,
    required List<String> hashtagCodes,
    int page = 0,
    int size = 10,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final memberId = prefs.getInt('member_id');
    if (memberId == null) throw Exception('❌ memberId가 존재하지 않습니다.');

    final uri = Uri.https('api.inninglog.shop', '/seatViews/hashtag/gallery', {
      'memberId': '$memberId', // ✅ 필수 파라미터 추가
      'stadiumShortCode': stadiumShortCode,
      'hashtagCodes': hashtagCodes.join(','), // ✅ List → String 변환
      'page': '$page',
      'size': '$size',
    });

    print('📡 해시태그 요청 URI: $uri');

    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      final List<dynamic> contents = json['data']['content'];
      return contents.map((item) => SeatView.fromJson(item)).toList();
    } else {
      throw Exception('❌ 해시태그 좌석 조회 실패: ${res.body}');
    }
  }



  static Future<SeatViewDetail> fetchSeatViewDetail(int seatViewId) async {
    final prefs = await SharedPreferences.getInstance();
    final memberId = prefs.getInt('member_id');
    if (memberId == null) throw Exception('❌ memberId가 존재하지 않습니다.');

    final uri = Uri.https(
      'api.inninglog.shop',
      '/seatViews/$seatViewId',
      {
        'memberId': '$memberId', // ✅ 쿼리 파라미터에 추가
      },
    );

    print('🔍 시야 상세 요청 URI: $uri');

    final res = await http.get(uri); // 여전히 Authorization은 필요 없음

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      final data = json['data'];
      return SeatViewDetail.fromJson(data);
    } else {
      throw Exception('좌석 시야 상세 조회 실패: ${res.body}');
    }
  }


}