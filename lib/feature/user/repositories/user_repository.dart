import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../shared/network/api_envelope.dart';

class MemberProfileResponse {
  final String nickname;
  final String profileUrl;
  final String teamShortCode;
  final int totalGameCount;
  final int winCount;
  final double winRate;

  MemberProfileResponse({
    required this.nickname,
    required this.profileUrl,
    required this.teamShortCode,
    required this.totalGameCount,
    required this.winCount,
    required this.winRate,
  });

  factory MemberProfileResponse.fromJson(Map<String, dynamic> json) {
    return MemberProfileResponse(
      nickname: json['nickname'] as String? ?? '',
      profileUrl: json['profileUrl'] as String? ?? '',
      teamShortCode: json['teamShortCode'] as String? ?? '',
      totalGameCount: json['totalGameCount'] as int? ?? 0,
      winCount: json['winCount'] as int? ?? 0,
      winRate: (json['winRate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

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

  Future<MemberProfileResponse> getProfile() async {
    final res = await _dio.get('/member/profile');
    final json = res.data;
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Unexpected response shape');
    }
    final data = json['data'] as Map<String, dynamic>;
    return MemberProfileResponse.fromJson(data);
  }

  Future<void> patchNickname(String nickname) async {
    await _dio.patch('/member/nickname', data: {'nickname': nickname});
  }

  /// 프로필 이미지 업로드 (multipart)
  /// 반환값: 서버에서 내려준 새 profileUrl
  Future<String> uploadProfileImage(Uint8List bytes, String filename) async {
    final formData = FormData.fromMap({
      'image': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final res = await _dio.post('/member/profile-image', data: formData);
    final json = res.data as Map<String, dynamic>;
    final data = json['data'] as Map<String, dynamic>;
    return data['profileUrl'] as String;
  }

  Future<void> deleteAccount() async {
    await _dio.delete('/member');
  }
}
