import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddDiaryRepository {
  final String baseUrl;
  AddDiaryRepository({this.baseUrl = 'https://api.inninglog.shop'});

  Future<Map<String, dynamic>> getJournalDetail({
    required int journalId,
    required int memberId,
  }) async {
    final res = await http.get(
      Uri.parse('$baseUrl/journals/detail/$journalId?memberId=$memberId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (res.statusCode != 200) {
      throw Exception('getJournalDetail failed: ${res.statusCode} ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>?> getJournalContents({
    required String gameId,
    required int memberId,
  }) async {
    final res = await http.get(
      Uri.parse('$baseUrl/journals/contents?gameId=$gameId&memberId=$memberId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (res.statusCode != 200) return null;
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return body['data'] as Map<String, dynamic>?;
  }

  /// POST /images/upload/journal → { presignedUrl, key } 반환
  Future<({String presignedUrl, String key})> requestJournalImagePresignedUrl({
    required String fileName,
    required String contentType,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = (prefs.getString('accessToken') ?? prefs.getString('access_token'))?.trim();

    final res = await http.post(
      Uri.parse('$baseUrl/images/upload/journal'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'imageUploadReqDto': [
          {'sequence': 1, 'fileName': fileName, 'contentType': contentType},
        ],
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('[1단계 presigned 실패] status=${res.statusCode} body=${res.body}');
    }
    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    final dto = ((decoded['data']?['imageUploadResDtos'] as List?)?.first) as Map<String, dynamic>;
    return (presignedUrl: dto['presignedUrl'] as String, key: dto['key'] as String);
  }

  Future<bool> uploadToS3({
    required String presignedUrl,
    required Uint8List bytes,
    required String contentType,
  }) async {
    final res = await http.put(
      Uri.parse(presignedUrl),
      headers: {'Content-Type': contentType},
      body: bytes,
    );
    return res.statusCode == 200;
  }
}