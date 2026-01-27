import '../model/dto/seatview_gallery_response_dto.dart';
import '../service/field_api.dart';

class SeatViewRepository {
  Future<SeatViewGalleryResponseDto> fetchNormalGallery({
    required String stadiumShortCode,
    String? zoneShortCode,
    String? section,
    String? seatRow,
    int page = 0,
    int size = 10,
  }) async {
    // ✅ 서버 룰: 열 단독 불가(최소 존 필요)
    if ((seatRow?.trim().isNotEmpty ?? false) &&
        (zoneShortCode?.trim().isNotEmpty != true)) {
      throw ArgumentError('열 정보만으로는 검색할 수 없습니다. 최소 존 정보가 필요합니다.');
    }

    final json = await FieldApi.getJson(
      '/seatViews/normal/gallery',
      query: {
        'stadiumShortCode': stadiumShortCode,
        if (zoneShortCode?.trim().isNotEmpty ?? false) 'zoneShortCode': zoneShortCode!.trim(),
        if (section?.trim().isNotEmpty ?? false) 'section': section!.trim(),
        if (seatRow?.trim().isNotEmpty ?? false) 'seatRow': seatRow!.trim(),
        'page': page,
        'size': size,
      },
    );

    return SeatViewGalleryResponseDto.fromJson(json);
  }
}
