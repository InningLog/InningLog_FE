import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/home_view.dart';
import '../screens/home_detail.dart';
import 'package:intl/intl.dart';


class ApiService {
  static const String baseUrl = 'https://api.inninglog.shop';


  static Future<http.Response> getHomeView() async {
    final url = Uri.parse('$baseUrl/home/view');
    return await http.get(url);
  }


  static Future<HomeData?> fetchHomeData() async {

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    print('🔐 저장된 토큰: $token');


    if (token == null) {
      print('❌ 토큰 없음');
      return null;
    }

    final url = Uri.parse('$baseUrl/home/view');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token', // 하드코딩 말고 이걸 써야 함
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      return HomeData.fromJson(jsonBody['data']);
    } else {
      print('❌ API 오류: ${response.statusCode}');
      return null;
    }
  }

  static Future<MyReportResponse?> fetchMyReport() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      print('❌ 토큰 없음');
      return null;
    }

    final url = Uri.parse('$baseUrl/report/main');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

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
          winningRateHalPoongRi: 0,
          topBatters: [],
          topPitchers: [],
          bottomBatters: [],
          bottomPitchers: [],
        ); // 👈 직관 없는 경우
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


  static Future<String?> getPresignedUrl(String fileName, String contentType) async {
    final url = Uri.parse('$baseUrl/s3/journal/presigned?fileName=$fileName&contentType=$contentType');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'];
    } else {
      print('❌ Presigned URL 발급 실패: ${response.body}');
      return null;
    }
  }

  static Future<bool> uploadImageToS3(String presignedUrl, File file) async {
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

  static Future<void> uploadJournal({
    required String gameId,
    required String fileName,
    required String stadiumShortCode,
    required String opponentTeamShortCode,
    required DateTime gameDateTime,
    required int ourScore,
    required int theirScore,
    required String emotion,
    required String reviewText,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    print('🪪 저장된 토큰: $token');

    final bodyData = {
      "gameId": gameId,
      "gameDate": DateFormat('yyyy-MM-dd HH:mm').format(gameDateTime),
      "stadiumSC": stadiumShortCode,
      "opponentTeamSC": opponentTeamShortCode,
      "ourScore": ourScore,
      "theirScore": theirScore,
      "fileName": fileName,
      "emotion": emotion,
      "review_text": reviewText,
    };

    print('📤 보낼 바디: ${jsonEncode(bodyData)}');

    final response = await http.post(
      Uri.parse('$baseUrl/journals/contents'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(bodyData),
    );

    print('📡 응답 코드: ${response.statusCode}');
    print('📦 응답 바디: ${response.body}');

    if (response.statusCode == 201) {
      print('✅ 일지 업로드 성공!');
    } else {
      print('❌ 일지 업로드 실패: ${response.body}');
    }
  }
}

Future<List<Journal>> fetchJournalCalendar({String? resultScore}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');

  if (token == null) throw Exception('No token found');

  final uri = Uri.parse('https://api.inninglog.shop/journals/calendar${resultScore != null ? '?resultScore=$resultScore' : ''}');
  final response = await http.get(
    uri,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body)['data'] as List;
    return jsonData.map((e) => Journal.fromJson(e)).toList();
  } else {
    print('❌ 응답 실패: ${response.statusCode} - ${response.body}');
    throw Exception('Failed to fetch calendar');
  }
}

Future<List<Journal>> fetchJournalSummary({
  String? resultScore,
  int page = 0,
  int size = 10,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');

  final queryParams = {
    'page': '$page',
    'size': '$size',
    if (resultScore != null) 'resultScore': resultScore,
  };

  final uri = Uri.https('api.inninglog.shop', '/journals/summary', queryParams);

  final response = await http.get(
    uri,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
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
  final token = prefs.getString('access_token');

  final url = Uri.parse('https://api.inninglog.shop/journals/contents?gameId=$gameId');
  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    final data = json['data'];
    return GameInfo.fromJournalContentJson(data);
  } else {
    print('❌ 경기 정보 조회 실패: ${response.body}');
    return null;
  }
}


Future<void> uploadSeatView({
  required int journalId,
  required String stadiumSC,
  required String zoneSC,
  required String section,
  required String row,
  required List<String> tagCodes,
  required String fileName,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');
  final body = jsonEncode({
    "journalId": journalId,
    "stadiumShortCode": stadiumSC,
    "zoneShortCode": zoneSC,
    "section": section,
    "seatRow": row,
    "emotionTagCodes": tagCodes,
    "fileName": fileName,
  });


  await http.post(
  Uri.parse('https://api.inninglog.shop/seatViews/contents'),
  headers: {
  'Authorization': 'Bearer $token',
  'Content-Type': 'application/json',
  },
  body: jsonEncode(body),
  );
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

