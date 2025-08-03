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
    _seatDetailFuture = ApiService.fetchSeatViewDetail(widget.seatViewId);
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

            // 해시태그 이름이 겹치는 카테고리는 접미사 붙이기
            String getFormattedTag(String category, String tagName) {
              if (category == '지붕' && tagName == '없음') return '#없음_지붕';
              if (category == '시야 방해' && tagName == '없음') return '#없음_시야방해';
              return '#$tagName';
            }


            final Map<String, List<String>> selectedTags = {};

            for (var tag in detail.emotionTags ?? []) {
              final parts = tag.label.split(' - ');
              if (parts.length != 2) continue;
              final category = parts[0];
              final rawTagName = parts[1];
              final tagName = getFormattedTag(category, rawTagName);

              selectedTags.putIfAbsent(category, () => []).add(tagName);
            }



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

                Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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

                      // ✅ 해시태그 영역 (스크롤 가능 영역이 아니고, 전체 스크롤에 포함됨)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCategory("응원", ["#일어남", "#일어날_사람은_일어남", "#앉아서"], selectedTags: selectedTags["응원"]),
                            _buildCategory("햇빛", ["#강함", "#있다가_그늘짐", "#없음"], selectedTags: selectedTags["햇빛"]),
                            _buildCategory("지붕", ["#있음", "#없음"], selectedTags: selectedTags["지붕"]),
                            _buildCategory("시야 방해", ["#그물", "#아크릴_가림막", "#없음"], selectedTags: selectedTags["시야 방해"]),
                            _buildCategory("좌석 공간", ["#아주_넓음", "#넓음", "#보통", "#좁음"], selectedTags: selectedTags["좌석 공간"]),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ],
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

  Widget _buildCategory(String title, List<String> tags, {List<String>? selectedTags}) {
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
              final isSelected = selectedTags?.contains(tag) ?? false;
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


  final Map<String, String> tagCodeMap = {
    '#일어남': 'CHEERING_STANDING',
    '#일어날_사람은_일어남': 'CHEERING_MOSTLY_STANDING',
    '#앉아서': 'CHEERING_SEATED',
    '#강함': 'SUN_STRONG',
    '#있다가_그늘짐': 'SUN_MOVES_TO_SHADE',
    '#없음': 'SUN_NONE', // 햇빛 - 없음
    '#있음': 'ROOF_EXISTS', // 지붕 - 있음
    '#없음_지붕': 'ROOF_NONE', // 구분 위해 이름 바꿈
    '#그물': 'VIEW_OBSTRUCT_NET',
    '#아크릴_가림막': 'VIEW_OBSTRUCT_ACRYLIC',
    '#없음_시야방해': 'VIEW_NO_OBSTRUCTION', // 구분 위해 이름 바꿈
    '#아주_넓음': 'SEAT_SPACE_VERY_WIDE',
    '#넓음': 'SEAT_SPACE_WIDE',
    '#보통': 'SEAT_SPACE_NORMAL',
    '#좁음': 'SEAT_SPACE_NARROW',
  };
}

String _getTagCategory(String tagLabel) {
  if (['일어남', '일어날_사람은_일어남', '앉아서'].contains(tagLabel)) return '응원';
  if (['강함', '있다가_그늘짐', '없음'].contains(tagLabel)) return '햇빛';
  if (['있음', '없음'].contains(tagLabel)) return '지붕';
  if (['그물', '아크릴_가림막', '없음'].contains(tagLabel)) return '시야 방해';
  if (['아주_넓음', '넓음', '보통', '좁음'].contains(tagLabel)) return '좌석 공간';
  return '기타';
}
