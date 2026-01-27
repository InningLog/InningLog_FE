import '../seat_view_item.dart';
import '../dto/seatview_gallery_response_dto.dart';

extension SeatViewMapper on SeatViewGalleryContentDto {
  SeatViewItem toModel() => SeatViewItem(
    seatViewId: seatViewId,
    viewMediaUrl: viewMediaUrl,
  );
}
