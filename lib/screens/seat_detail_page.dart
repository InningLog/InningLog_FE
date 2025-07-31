import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../app_colors.dart';
import '../models/home_view.dart';
import '../service/api_service.dart';

class SeatDetailPage extends StatefulWidget {
  final int seatViewId;
  final String imageUrl;

  const SeatDetailPage({
    super.key,
    required this.seatViewId,
    required this.imageUrl,
  });

  @override
  State<SeatDetailPage> createState() => _SeatDetailPageState();
}

class _SeatDetailPageState extends State<SeatDetailPage> {
  late Future<SeatViewDetail> _seatDetailFuture;


  @override
  void initState() {
    super.initState();
    _seatDetailFuture = fetchSeatViewDetail(widget.seatViewId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<SeatViewDetail>(
          future: _seatDetailFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('오류: ${snapshot.error}'));
            }

            final detail = snapshot.data!;
            final info = detail.seatInfo;
            final selectedTags = {
              for (var tag in detail.emotionTags ?? [])
                _getTagCategory(tag.label): '#${tag.label}'
            };

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ 상단 헤더
                Container(
                  height: 72,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        icon: SvgPicture.asset(
                          'assets/icons/back_but.svg',
                          width: 10,
                          height: 20,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 0),
                      const Text(
                        '해시태그 검색',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.26,
                          color: Color(0xFF272727),
                          fontFamily: 'MBC1961GulimOTF',
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        padding: EdgeInsets.zero,
                        icon: SvgPicture.asset(
                          'assets/icons/Alarm.svg',
                          width: 18.05,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // ✅ 대표 이미지
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 58.5),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: AspectRatio(
                      aspectRatio: 273 / 364,
                      child: Image.network(
                        widget.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ✅ 좌석 정보 텍스트
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Align(
                      alignment: Alignment.center,
                      child: Text(
                    info != null
                        ? '${info.zoneName ?? ""} ${info.section ?? ""}구역 ${info.seatRow ?? ""}열'
                        : '좌석 정보 없음',
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Pretendard',
                    ),
                  ),
            ),
                ),
                const SizedBox(height: 16),

                // ✅ 해시태그 영역
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCategory("응원", ["#일어남", "#일어날_사람은_일어남", "#앉아서"], selectedTag: selectedTags["응원"]),
                          _buildCategory("햇빛", ["#강함", "#있다가_그늘짐", "#없음"], selectedTag: selectedTags["햇빛"]),
                          _buildCategory("지붕", ["#있음", "#없음"], selectedTag: selectedTags["지붕"]),
                          _buildCategory("시야 방해", ["#그물", "#아크릴_가림막", "#없음"], selectedTag: selectedTags["시야 방해"]),
                          _buildCategory("좌석 공간", ["#아주_넓음", "#넓음", "#보통", "#좁음"], selectedTag: selectedTags["좌석 공간"]),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategory(String title, List<String> tags, {String? selectedTag}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: tags.map((tag) {
              final isSelected = tag == selectedTag;
              return ChoiceChip(
                label: Text(tag),
                selected: isSelected,
                onSelected: (_) {},
                selectedColor: AppColors.primary100,
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? const Color(0xFF272727) : AppColors.gray700,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary700 : AppColors.gray300,
                    width: 1,
                  ),
                ),
                showCheckmark: false,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 감정 태그 label에서 카테고리를 추정하는 함수
  String _getTagCategory(String label) {
    if (label.contains("일어남") || label.contains("앉아서")) return "응원";
    if (label.contains("햇빛") || label.contains("강함") || label.contains("그늘")) return "햇빛";
    if (label.contains("지붕")) return "지붕";
    if (label.contains("그물") || label.contains("가림막")) return "시야 방해";
    if (label.contains("넓음") || label.contains("좁음") || label.contains("공간")) return "좌석 공간";
    return "기타";
  }
}

