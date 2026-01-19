import 'package:dio/dio.dart';

class CommentLikeRepository {
  final Dio _dio;

  CommentLikeRepository(this._dio);

  Future<void> likeComment({required int commentId}) async {
    final res = await _dio.post('/community/comments/$commentId/likes');
    if (res.data is! Map<String, dynamic>) {
      throw const FormatException('Unexpected comment like response');
    }
  }

  Future<void> unlikeComment({required int commentId}) async {
    final res = await _dio.delete('/community/comments/$commentId/likes');
    if (res.data is! Map<String, dynamic>) {
      throw const FormatException('Unexpected comment unlike response');
    }
  }
}
