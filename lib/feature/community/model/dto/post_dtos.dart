import 'package:inninglog/feature/community/model/community_post.dart';

class PostListResponse {
  final List<CommunityPostItem> content;
  final bool hasNext;
  final int page;
  final int size;

  PostListResponse({
    required this.content,
    required this.hasNext,
    required this.page,
    required this.size,
  });

  factory PostListResponse.fromJson(Map<String, dynamic> json) {
    final body = (json['data'] as Map<String, dynamic>?) ?? json;

    final content =
        (body['content'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map((e) => CommunityPostItemDto.fromJson(e).toModel())
            .toList();
    return PostListResponse(
      content: content,
      hasNext: body['hasNext'] == true,
      page: (body['page'] ?? 0) as int,
      size: (body['size'] ?? content.length) as int,
    );
  }
}

/// API 응답 → CommunityPostItem 변환을 담당하는 DTO.
/// JSON 파싱 복잡도(필드명 이중화, data 언래핑, member 중첩)를 모델에서 분리.
class CommunityPostItemDto {
  factory CommunityPostItemDto.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? json;
    final member = data['member'] as Map<String, dynamic>?;

    int asInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;

    String? asStringOpt(dynamic v) {
      if (v == null) return null;
      final s = v.toString();
      return s.isEmpty ? null : s;
    }

    bool asBool(dynamic v) {
      if (v is bool) return v;
      if (v is num) return v != 0;
      final s = v?.toString().toLowerCase();
      if (s == 'true') return true;
      if (s == 'false') return false;
      return false;
    }

    final images =
        ((data['imageListResDto'] as Map<String, dynamic>?)?['imageResDtos']
            as List<dynamic>?) ??
        const [];

    return CommunityPostItemDto._(
      id: asInt(data['postId']),
      teamCode: asStringOpt(data['teamShortCode'] ?? data['teamCode']) ?? 'ALL',
      title: asStringOpt(data['title']) ?? '',
      content: asStringOpt(data['content']) ?? '',
      nickName: asStringOpt(member?['nickName']),
      profileUrl: asStringOpt(member?['profile_url']),
      writeByMe: asBool(data['writedByMe'] ?? data['writeByMe']),
      likeCount: asInt(data['likeCount']),
      likedByMe: asBool(data['likedByMe']),
      scrapCount: asInt(data['scrapCount']),
      scrapedByMe: asBool(data['scrapedByMe']),
      commentCount: asInt(data['commentCount']),
      createdAt: asStringOpt(data['postAt']),
      isEdit: asBool(data['isEdit']),
      thumbImageUrl: asStringOpt(data['thumbImageUrl']),
      images:
          images
              .whereType<Map<String, dynamic>>()
              .map(ImageItem.fromJson)
              .toList(),
      imageCount: asInt(data['imageCount']),
    );
  }

  const CommunityPostItemDto._({
    required this.id,
    required this.teamCode,
    required this.title,
    required this.content,
    required this.nickName,
    required this.profileUrl,
    required this.writeByMe,
    required this.likeCount,
    required this.likedByMe,
    required this.scrapCount,
    required this.scrapedByMe,
    required this.commentCount,
    required this.createdAt,
    required this.isEdit,
    required this.thumbImageUrl,
    required this.images,
    required this.imageCount,
  });

  final int id;
  final String teamCode;
  final String title;
  final String content;
  final String? nickName;
  final String? profileUrl;
  final bool writeByMe;
  final int likeCount;
  final bool likedByMe;
  final int scrapCount;
  final bool scrapedByMe;
  final int commentCount;
  final String? createdAt;
  final bool isEdit;
  final String? thumbImageUrl;
  final List<ImageItem> images;
  final int imageCount;

  CommunityPostItem toModel() {
    return CommunityPostItem(
      id: id,
      teamCode: teamCode,
      title: title,
      content: content,
      nickName: nickName,
      profileUrl: profileUrl,
      writeByMe: writeByMe,
      likeCount: likeCount,
      likedByMe: likedByMe,
      scrapCount: scrapCount,
      scrapedByMe: scrapedByMe,
      commentCount: commentCount,
      createdAt: createdAt,
      isEdit: isEdit,
      thumbImageUrl: thumbImageUrl,
      images: images,
      imageCount: imageCount,
    );
  }
}

/// API 요청/응답 DTO 모음 (커뮤니티 게시글 작성/업로드 관련)
class ImageCreateReqDto {
  final int sequence;
  final String key;

  const ImageCreateReqDto({required this.sequence, required this.key});

  factory ImageCreateReqDto.fromJson(Map<String, dynamic> json) {
    return ImageCreateReqDto(
      sequence: json['sequence'] as int,
      key: json['key'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'sequence': sequence, 'key': key};
}

/// 게시글 업로드 시 클라이언트가 준비하는 이미지 정보
class ImageUploadReqDto {
  final int sequence;
  final String fileName;
  final String contentType;

  const ImageUploadReqDto({
    required this.sequence,
    required this.fileName,
    required this.contentType,
  });

  Map<String, dynamic> toRequestJson() => {
    'sequence': sequence,
    'fileName': fileName,
    'contentType': contentType,
  };
}

/// Presigned URL 발급 응답 객체
class ImageUploadResDto extends ImageCreateReqDto {
  final String presignedUrl;

  const ImageUploadResDto({
    required super.sequence,
    required super.key,
    required this.presignedUrl,
  });

  factory ImageUploadResDto.fromJson(Map<String, dynamic> json) {
    final seq = json['sequence'];
    final url = json['presignedUrl'] ?? json['url'] ?? json['uploadUrl'] ?? '';
    final key = json['key'] ?? json['s3Key'] ?? json['objectKey'] ?? '';

    return ImageUploadResDto(
      sequence: seq is int ? seq : int.tryParse('$seq') ?? 0,
      key: key.toString(),
      presignedUrl: url.toString(),
    );
  }
}

class CreatePostRequest {
  final String title;
  final String content;
  final List<ImageCreateReqDto> imageCreateReqDto;
  final int imageCount;

  const CreatePostRequest({
    required this.title,
    required this.content,
    this.imageCreateReqDto = const [],
    required this.imageCount,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'content': content,
    'imageCreateReqDto': imageCreateReqDto.map((e) => e.toJson()).toList(),
    'imageCount': imageCount,
  };
}

class RemainImageReqDto {
  final int remainImageId;
  final int sequence;

  const RemainImageReqDto({required this.remainImageId, required this.sequence});

  Map<String, dynamic> toJson() => {
    'remainImageId': remainImageId,
    'sequence': sequence,
  };
}

class NewImageReqDto {
  final int sequence;
  final String key;

  const NewImageReqDto({required this.sequence, required this.key});

  Map<String, dynamic> toJson() => {'sequence': sequence, 'key': key};
}

class UpdatePostRequest {
  final String title;
  final String content;
  final List<RemainImageReqDto> remainImages;
  final List<NewImageReqDto> newImages;
  final int imageCount;

  const UpdatePostRequest({
    required this.title,
    required this.content,
    this.remainImages = const [],
    this.newImages = const [],
    required this.imageCount,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'content': content,
    'remainImages': remainImages.map((e) => e.toJson()).toList(),
    'newImages': newImages.map((e) => e.toJson()).toList(),
    'imageCount': imageCount,
  };
}
