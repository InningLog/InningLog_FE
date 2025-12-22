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

class CreatePostRequest {
  final String title;
  final String content;
  final List<ImageCreateReqDto> imageCreateReqDto;

  const CreatePostRequest({
    required this.title,
    required this.content,
    this.imageCreateReqDto = const [],
  });

  factory CreatePostRequest.fromJson(Map<String, dynamic> json) {
    return CreatePostRequest(
      title: json['title'] as String,
      content: json['content'] as String,
      imageCreateReqDto:
          (json['imageCreateReqDto'] as List<dynamic>? ?? const [])
              .whereType<Map<String, dynamic>>()
              .map(ImageCreateReqDto.fromJson)
              .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'content': content,
    'imageCreateReqDto': imageCreateReqDto.map((e) => e.toJson()).toList(),
  };

  /// 이미지 없이 쓰기 편한 헬퍼(선택)
  CreatePostRequest copyWith({
    String? title,
    String? content,
    List<ImageCreateReqDto>? imageCreateReqDto,
  }) {
    return CreatePostRequest(
      title: title ?? this.title,
      content: content ?? this.content,
      imageCreateReqDto: imageCreateReqDto ?? this.imageCreateReqDto,
    );
  }
}
