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
