import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

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

  Future<String> getPresignedUrl({
    required String fileName,
    required String contentType,
    required int memberId,
  }) async {
    final res = await http.get(Uri.parse(
      '$baseUrl/s3/journal/presigned?fileName=$fileName&contentType=$contentType&memberId=$memberId',
    ));

    if (res.statusCode != 200) {
      throw Exception('presigned failed: ${res.statusCode} ${res.body}');
    }
    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    return decoded['data'] as String;
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