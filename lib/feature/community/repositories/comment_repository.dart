import 'package:dio/dio.dart';
import 'package:inninglog/feature/community/model/dto/comment_dtos.dart';
import 'package:inninglog/shared/network/api_envelope.dart';

class CommentRepository {
  final Dio _dio;

  CommentRepository(this._dio);

  /// 게시글 댓글 조회
  Future<List<CommentResDto>> getPostComments({required int postId}) async {
    final res = await _dio.get('/community/posts/$postId/comments');
    final json = res.data;
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Unexpected comment list response');
    }
    final envelope = ApiEnvelope.fromJson(json);
    final data = envelope.data;
    final body = data is Map<String, dynamic> ? data : json;
    final comments =
        (body['comments'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(CommentResDto.fromJson)
            .toList();
    return comments;
  }

  /// 게시글 댓글 생성
  Future<ApiEnvelope> createPostComment({
    required int postId,
    required CreateCommentRequest request,
  }) async {
    final res = await _dio.post(
      '/community/posts/$postId/comments',
      data: request.toJson(),
    );
    final json = res.data;
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Unexpected create comment response');
    }
    return ApiEnvelope.fromJson(json);
  }

  /// 댓글 좋아요
  Future<void> likeComment({required int commentId}) async {
    final res = await _dio.post('/community/comments/$commentId/likes');
    if (res.data is! Map<String, dynamic>) {
      throw const FormatException('Unexpected comment like response');
    }
  }

  /// 댓글 좋아요 취소
  Future<void> unlikeComment({required int commentId}) async {
    final res = await _dio.delete('/community/comments/$commentId/likes');
    if (res.data is! Map<String, dynamic>) {
      throw const FormatException('Unexpected comment unlike response');
    }
  }

  //댓글 삭제
  Future<void> deleteComment({required int commentId}) async {
    final res = await _dio.delete('/community/comments/$commentId');
    if (res.data is! Map<String, dynamic>) {
      throw const FormatException('Unexpected delete response');
    }
  }
}
