import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../shared/network/api_envelope.dart';
import '../model/dto/create_post_dtos.dart';

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

  /// 게시글 이미지 Presigned URL 목록 발급
  Future<List<ImageUploadResDto>> requestImagePresignedUrls({
    required List<ImageUploadReqDto> images,
  }) async {
    if (images.isEmpty) return const [];

    final res = await _dio.post(
      '/images/upload/post',
      data: {
        'imageUploadReqDto': images.map((e) => e.toRequestJson()).toList(),
      },
    );

    final json = res.data;
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Unexpected presigned response shape');
    }

    final envelope = ApiEnvelope.fromJson(json);
    final data = envelope.data;

    List<dynamic>? items;
    if (data is List) {
      items = data;
    } else if (data is Map<String, dynamic>) {
      final nested = data['imageUploadResDtos'];
      if (nested is List) items = nested;
    }

    if (items == null) {
      throw const FormatException('Presigned URL list not found in response');
    }

    return items
        .whereType<Map<String, dynamic>>()
        .map(ImageUploadResDto.fromJson)
        .toList();
  }

  /// Presigned URL로 S3 업로드
  Future<void> uploadToS3({
    required ImageUploadResDto target,

    required String contentType,
  }) async {
    final res = await http.put(
      Uri.parse(target.presignedUrl),
      headers: {'Content-Type': contentType},
    );

    final status = res.statusCode;
    if (status >= 400) {
      throw Exception('Failed to upload image (status: $status)');
    }
  }
}
