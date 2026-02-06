import 'package:dio/dio.dart';
import 'package:inninglog/feature/community/model/dto/diary_dtos.dart';
import 'package:inninglog/shared/network/api_envelope.dart';

class DiaryRepository {
  final Dio _dio;
  DiaryRepository(this._dio);

  Future<DiaryFeedResponse> getDiaryFeed({
    required String teamCode,
    required int page,
    required int size,
  }) async {
    final res = await _dio.get(
      '/journals/feed',
      queryParameters: {'teamShortCode': teamCode, 'page': page, 'size': size},
    );

    final json = res.data;
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Unexpected feed response shape');
    }

    final envelope = ApiEnvelope.fromJson(json);
    final data = envelope.data;
    if (data is Map<String, dynamic>) {
      return DiaryFeedResponse.fromJson(data);
    }

    return DiaryFeedResponse.fromJson(json);
  }

  Future<void> scrapJournal({required String journalId}) async {
    final res = await _dio.post('/journals/$journalId/scraps');
    if (res.data is! Map<String, dynamic>) {
      throw const FormatException('Unexpected scrap response');
    }
  }

  Future<void> unscrapJournal({required String journalId}) async {
    final res = await _dio.delete('/journals/$journalId/scraps');
    if (res.data is! Map<String, dynamic>) {
      throw const FormatException('Unexpected unscrap response');
    }
  }

  Future<void> likeJournal({required String journalId}) async {
    final res = await _dio.post('/journals/$journalId/likes');
    if (res.data is! Map<String, dynamic>) {
      throw const FormatException('Unexpected like response');
    }
  }

  Future<void> unlikeJournal({required String journalId}) async {
    final res = await _dio.delete('/journals/$journalId/likes');
    if (res.data is! Map<String, dynamic>) {
      throw const FormatException('Unexpected unlike response');
    }
  }
}
