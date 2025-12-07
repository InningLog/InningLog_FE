import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MemberApi {
  static const String baseUrl = 'https://api.inninglog.shop';

  /// 닉네임 설정 (중복 방지 포함)
  static Future<bool> patchNickname(String nickname) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      print('❌ [닉네임] 토큰 없음');
      return false;
    }

    final url = Uri.parse('$baseUrl/member/nickname');

    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'nickname': nickname}),
    );

    print('📡 [닉네임] 응답 상태: ${response.statusCode}');
    print('📦 [닉네임] 응답 바디: ${response.body}');

    if (response.statusCode == 200) {
      print('✅ 닉네임 설정 성공');
      return true;
    } else {
      final body = jsonDecode(response.body);
      final code = body['code'];
      final message = body['message'];

      if (code == 'DUPLICATE_NICKNAME') {
        return Future.error('이미 존재하는 닉네임입니다.');
      }

      return Future.error(message ?? '닉네임 설정에 실패했습니다.');
    }
  }

  /// 응원팀 설정 (이미 설정된 경우 에러 반환)
  static Future<bool> patchTeam(String teamShortCode) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      print('❌ [팀] 토큰 없음');
      return false;
    }

    final url = Uri.parse('$baseUrl/member/setup');

    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer  $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'teamShortCode': teamShortCode}),
    );

    print('📡 [팀] 응답 상태: ${response.statusCode}');
    print('📦 [팀] 응답 바디: ${response.body}');

    if (response.statusCode == 200) {
      print('✅ 응원팀 설정 성공');
      return true;
    } else {
      final body = jsonDecode(response.body);
      final code = body['code'];
      final message = body['message'];

      if (code == 'ALREADY_SET') {
        print('ℹ️ 이미 응원팀 설정됨. 통과 처리');
        return true;  // 실패로 보지 않음
      }


      return Future.error(message ?? '응원팀 설정에 실패했습니다.');
    }
  }
}
