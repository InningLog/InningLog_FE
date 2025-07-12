import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/home_view.dart';

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
        'Authorization': 'Bearer $token', // ✅ 하드코딩 말고 이걸 써야 해!
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


}

