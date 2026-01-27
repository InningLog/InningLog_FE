class SeatViewGalleryResponseDto {
  final String code;
  final String message;
  final SeatViewGalleryDataDto data;

  SeatViewGalleryResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory SeatViewGalleryResponseDto.fromJson(Map<String, dynamic> json) {
    return SeatViewGalleryResponseDto(
      code: json['code'] as String,
      message: json['message'] as String,
      data: SeatViewGalleryDataDto.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class SeatViewGalleryDataDto {
  final List<SeatViewGalleryContentDto> content;
  final int pageNumber;
  final int pageSize;
  final int totalElements;
  final int totalPages;
  final bool last;

  SeatViewGalleryDataDto({
    required this.content,
    required this.pageNumber,
    required this.pageSize,
    required this.totalElements,
    required this.totalPages,
    required this.last,
  });

  factory SeatViewGalleryDataDto.fromJson(Map<String, dynamic> json) {
    return SeatViewGalleryDataDto(
      content: (json['content'] as List<dynamic>)
          .map((e) => SeatViewGalleryContentDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      pageNumber: (json['pageNumber'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      totalElements: (json['totalElements'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      last: json['last'] as bool,
    );
  }
}

class SeatViewGalleryContentDto {
  final int seatViewId;
  final String viewMediaUrl;

  SeatViewGalleryContentDto({
    required this.seatViewId,
    required this.viewMediaUrl,
  });

  factory SeatViewGalleryContentDto.fromJson(Map<String, dynamic> json) {
    return SeatViewGalleryContentDto(
      seatViewId: (json['seatViewId'] as num).toInt(),
      viewMediaUrl: json['viewMediaUrl'] as String,
    );
  }
}
