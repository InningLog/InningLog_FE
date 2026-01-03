import 'package:dio/dio.dart';
import '../../../shared/network/api_envelope.dart';

class UserRepository {
  final Dio _dio;
  UserRepository(this._dio);

  /// 커뮤니티 글 작성
  /// 응답 스펙: { code: string, message: string, data: {} }
  Future<ApiEnvelope> getTeam() async {
    final res = await _dio.get('/member/team');

    final json = res.data;
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Unexpected response shape');
    }
    return ApiEnvelope.fromJson(json);
  }
}
