import 'package:dio/dio.dart';
import '../../../shared/network/api_envelope.dart';
import '../model/create_post_request.dart';

class CommunityPostRepository {
  final Dio _dio;
  CommunityPostRepository(this._dio);

  /// 커뮤니티 글 작성
  /// 응답 스펙: { code: string, message: string, data: {} }
  Future<ApiEnvelope> createPost({
    required String teamCode,
    required CreatePostRequest request,
  }) async {
    final res = await _dio.post(
      '/community/$teamCode/posts/create',
      data: request.toJson(),
    );

    final json = res.data;
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Unexpected response shape');
    }
    return ApiEnvelope.fromJson(json);
  }
}
