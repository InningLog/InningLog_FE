import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:inninglog/feature/community/model/community_post.dart';
import 'package:inninglog/feature/community/model/dto/post_dtos.dart';
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
    try {
      final res = await http.put(
        Uri.parse(target.presignedUrl),
        headers: {'Content-Type': contentType},
      );

      if (res.statusCode >= 400) {
        // 최대 N바이트만 잘라서 남기면 길어지지 않음
        final body = res.body;
        throw Exception(
          'Failed to upload image '
          '(status: ${res.statusCode}, reason: ${res.reasonPhrase}, '
          'headers: ${res.headers}, body: ${body.length > 500 ? body.substring(0, 500) : body})',
        );
      }
    } catch (e, st) {
      // 전역 로거/크래시리틱스가 있다면 여기서 함께 기록
      debugPrint('uploadToS3 error: $e\n$st');
      rethrow;
    }
  }

  Future<PostListResponse> getPostList({
    required String teamCode,
    required int page,
    required int size,
  }) async {
    final res = await _dio.get(
      '/community/posts/team/$teamCode',
      queryParameters: {'page': page, 'size': size},
    );

    final json = res.data;
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Unexpected post list response');
    }
    return PostListResponse.fromJson(json);
  }

  /// 게시글 상세 조회
  /// 응답 스펙: { code: string, message: string, data: { ... } }
  Future<CommunityPostItem> getPostDetail({required int postId}) async {
    final res = await _dio.get('/community/posts/$postId');

    final json = res.data;
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Unexpected post detail response');
    }

    return CommunityPostItem.fromJson(json);
  }

  /// 게시글 좋아요
  Future<void> likePost({required int postId}) async {
    final res = await _dio.post('/community/posts/$postId/likes');
    if (res.data is! Map<String, dynamic>) {
      throw const FormatException('Unexpected like response');
    }
  }

  /// 게시글 좋아요 취소
  Future<void> unlikePost({required int postId}) async {
    final res = await _dio.delete('/community/posts/$postId/likes');
    if (res.data is! Map<String, dynamic>) {
      throw const FormatException('Unexpected unlike response');
    }
  }

  /// 게시글 스크랩
  Future<void> scrapPost({required int postId}) async {
    final res = await _dio.post('/community/posts/$postId/scraps');
    if (res.data is! Map<String, dynamic>) {
      throw const FormatException('Unexpected scrap response');
    }
  }

  /// 게시글 스크랩 취소
  Future<void> unscrapPost({required int postId}) async {
    final res = await _dio.delete('/community/posts/$postId/scraps');
    if (res.data is! Map<String, dynamic>) {
      throw const FormatException('Unexpected unscrap response');
    }
  }
}
