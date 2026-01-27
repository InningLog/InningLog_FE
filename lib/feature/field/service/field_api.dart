import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FieldApi {
  static const String baseUrl = 'https://api.inninglog.shop';

  /// GET JSON(Map) 공용
  static Future<Map<String, dynamic>> getJson(
      String path, {
        Map<String, dynamic>? query,
        Map<String, String>? headers,
        Duration timeout = const Duration(seconds: 15),
      }) async {
    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: query?.map((k, v) => MapEntry(k, v.toString())),
    );

    final res = await http
        .get(
      uri,
      headers: {
        'Accept': 'application/json',
        if (headers != null) ...headers,
      },
    )
        .timeout(timeout);

    Map<String, dynamic>? body;
    try {
      final decoded = jsonDecode(res.body);
      body = decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      body = null;
    }

    if (res.statusCode == 200) {
      if (body == null) throw Exception('응답 JSON 파싱 실패');
      return body;
    }

    final msg = (body?['message'] ?? res.body).toString();
    throw Exception('GET $path 실패(${res.statusCode}): $msg');
  }
}
