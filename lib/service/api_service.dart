import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/home_view.dart';

class ApiService {
  static const String baseUrl = 'https://api.inninglog.shop';

  static Future<http.Response> getHomeView() async {
    final url = Uri.parse('$baseUrl/home/view');
    return await http.get(url);
  }

  static Future<HomeData?> fetchHomeData() async {
    final url = Uri.parse('$baseUrl/home/view');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      return HomeData.fromJson(jsonBody['data']);
    } else {
      print('API 호출 실패: ${response.statusCode}');
      return null;
    }
  }
}

