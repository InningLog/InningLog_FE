import 'package:dio/dio.dart';
import 'package:inninglog/feature/community/model/dto/diary_dtos.dart';
import 'package:inninglog/shared/network/api_envelope.dart';

class DiaryRepository {
  final Dio _dio;
  DiaryRepository(this._dio);

  Future<DiaryFeedResponse> _getDiaryPaged({
    required String path,
    Map<String, dynamic>? queryParameters,
  }) async {
    final res = await _dio.get(path, queryParameters: queryParameters);

    final json = res.data;
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Unexpected diary response shape');
    }

    final envelope = ApiEnvelope.fromJson(json);
    final data = envelope.data;
    if (data is Map<String, dynamic>) {
      return DiaryFeedResponse.fromJson(data);
    }

    return DiaryFeedResponse.fromJson(json);
  }

  Future<DiaryFeedResponse> getDiaryFeed({
    required String teamCode,
    required int page,
    required int size,
  }) async {
    return _getDiaryPaged(
      path: '/journals/feed',
      queryParameters: {'teamShortCode': teamCode, 'page': page, 'size': size},
    );
  }

  Future<DiaryFeedResponse> getMyJournals({
    required int page,
    required int size,
  }) {
    return _getDiaryPaged(
      path: '/journals/my',
      queryParameters: {'page': page, 'size': size},
    );
  }

  Future<DiaryFeedResponse> getMyCommentedJournals({
    required int page,
    required int size,
  }) {
    return _getDiaryPaged(
      path: '/journals/my/commented',
      queryParameters: {'page': page, 'size': size},
    );
  }

  Future<DiaryFeedResponse> getMyScrappedJournals({
    required int page,
    required int size,
  }) {
    return _getDiaryPaged(
      path: '/journals/my/scrapped',
      queryParameters: {'page': page, 'size': size},
    );
  }

  Future<DiaryFeedResponse> getPopularJournals({
    required int page,
    required int size,
  }) {
    return _getDiaryPaged(
      path: '/journals/popular',
      queryParameters: {'page': page, 'size': size},
    );
  }

  Future<DiaryFeedResponse> searchJournals({
    required String teamShortCode,
    required String keyword,
    required int page,
    required int size,
  }) async {
    return _getDiaryPaged(
      path: '/journals/search',
      queryParameters: {
        'teamShortCode': teamShortCode,
        'keyword': keyword,
        'page': page,
        'size': size,
      },
    );
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
