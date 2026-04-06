import 'package:flutter/foundation.dart';
import '../model/seat_view_item.dart';
import '../model/mapper/seat_view_mapper.dart';
import '../repositories/seat_view_repository.dart';

class SeatViewGalleryVM extends ChangeNotifier {
  final SeatViewRepository repo;

  SeatViewGalleryVM(this.repo);

  bool isLoading = false;
  bool isLoadingMore = false;
  bool last = false;
  int page = 0;

  String? errorMessage;
  final List<SeatViewItem> items = [];

  Future<void> loadFirst({
    required String stadiumShortCode,
    String? section,
    String? seatRow,
    int size = 10,
  }) async {
    // 열 단독 금지(최소 구역 필요)
    if ((seatRow?.isNotEmpty ?? false) && (section?.isNotEmpty != true)) {
      errorMessage = '열 정보만으로는 검색할 수 없습니다. 구역 정보가 필요합니다.';
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    page = 0;
    last = false;
    items.clear();
    notifyListeners();

    try {
      final dto = await repo.fetchNormalGallery(
        stadiumShortCode: stadiumShortCode,
        section: section,
        seatRow: seatRow,
        page: 0,
        size: size,
      );

      items.addAll(dto.data.content.map((e) => e.toModel()));
      last = dto.data.last;
      page = dto.data.pageNumber;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore({
    required String stadiumShortCode,
    String? section,
    String? seatRow,
    int size = 10,
  }) async {
    if (isLoading || isLoadingMore || last) return;

    isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = page + 1;
      final dto = await repo.fetchNormalGallery(
        stadiumShortCode: stadiumShortCode,
        section: section,
        seatRow: seatRow,
        page: nextPage,
        size: size,
      );

      items.addAll(dto.data.content.map((e) => e.toModel()));
      last = dto.data.last;
      page = dto.data.pageNumber;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }
}
