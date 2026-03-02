import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inninglog/feature/field/screens/seat_page.dart';
import '../../../shared/amplitude/AmplitudeFlutter.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../main.dart';
import '../../../shared/widgets/common_header.dart';
import 'package:go_router/go_router.dart';
import '../../diary/screens/add_seat_page.dart';
import 'recommend_detail_page.dart';
import '../widgets/jamsil_map.dart';


class FieldSearchPage extends StatefulWidget {
  final String stadiumName;


  const FieldSearchPage({super.key, required this.stadiumName});


  @override
  State<FieldSearchPage> createState() => _FieldSearchPageState();
}

class _FieldSearchPageState extends State<FieldSearchPage> {
  int _selectedIndex = 0;
  String? selectedZone;
  String? get selectedStadiumCode => stadiumNameToCode[widget.stadiumName];

  final TextEditingController sectionController = TextEditingController();
  final TextEditingController rowController = TextEditingController();
  final Map<String, String> selectedTags = {};

  // 각 카테고리 정의
  final Map<String, List<String>> tagCategories = {
    '응원': ['#일어남', '#일어날_사람은_일어남', '#앉아서'],
    '햇빛': ['#강함', '#있다가_그늘짐', '#없음'],
    '지붕': ['#있음', '#없음'],
    '시야 방해': ['#그물', '#아크릴_가림막', '#없음'],
    '좌석 공간': ['#아주_넓음', '#넓음', '#보통', '#좁음'],
  };

  bool get isJamsil => widget.stadiumName.replaceAll(' ', '') == '잠실야구장';


  bool get isDirectSearchValid => sectionController.text.trim().isNotEmpty;


  bool get isHashtagSearchValid {
    return selectedTags.length >= 1;
  }


  Widget _buildRecommendTab() {
    final categories = [
      {
        'thumb': 'assets/images/seat_reco_cheer.png',
        'banner': 'assets/images/cheer_long.png',
        'title': '열정 가득! 응원 명당',
      },
      {
        'thumb': 'assets/images/seat_reco_sun.png',
        'banner': 'assets/images/sun_long.png',
        'title': '햇빛 피해 즐기는 직관',
      },
      {
        'thumb': 'assets/images/seat_reco_rain.png',
        'banner': 'assets/images/rain_long.png',
        'title': '비 와도 끝까지 쾌적하게',
      },
      {
        'thumb': 'assets/images/seat_reco_view.png',
        'banner': 'assets/images/view_long.png',
        'title': '시야 방해 없이!',
      },
      {
        'thumb': 'assets/images/seat_reco_wide.png',
        'banner': 'assets/images/wide_long.png',
        'title': '두 다리 쭉! 넓은 좌석',
      },
    ];

    // ⚠️ 반드시 실제 존재하는 에셋으로 바꿔줘야 런타임 에러 안 남!
    final dummySeatImages = List.generate(
      6,
          (_) => 'assets/images/sample_seat.jpg',
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // ✅ 위에 글씨(너가 말한 "위에 글씨도 있어야해" 부분)
          const Text(
            '내 취향에 맞는 좌석을 추천받아보세요!',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              fontFamily: 'Pretendard',
              letterSpacing: -0.16,
              height: 1,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: 20),

          // =========================
          // 카테고리 별 BEST
          // =========================
          const Text(
            '카테고리 별 BEST',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              fontFamily: 'Pretendard',
              letterSpacing: -0.18,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 178,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = categories[index];

                return _ImageCard(
                  assetPath: item['thumb']!,
                  width: 130,
                  height: 178,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RecommendDetailPage(
                          stadiumName: widget.stadiumName,
                          bannerAsset: item['banner']!,
                          title: item['title']!, // ✅ 추가
                          seatImages: dummySeatImages,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 60),

          // =========================
          // 꿀팁 이닝 (✅ 너가 붙여둔 그대로 유지)
          // =========================
          Row(
            children: [
              const Text(
                '꿀팁 이닝',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  fontFamily: 'Pretendard',
                  letterSpacing: -0.18,
                  color: AppColors.gray900,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  // TODO: 더보기 이동
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    '더보기 >',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Pretendard',
                      color: AppColors.gray500,
                      letterSpacing: -0.12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 6, // 임시 카드 개수
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return _PlaceholderCard(
                  width: 150,
                  height: 200,
                  borderRadius: 12,
                );
              },
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final bool isJamsil = widget.stadiumName == '잠실 야구장';


    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 72,
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  const SizedBox(width: 15),
                  Text(
                    widget.stadiumName,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.26,
                      color: Color(0xFF272727),
                      fontFamily: 'MBC1961GulimOTF',
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    icon: SvgPicture.asset(
                      'assets/icons/month_move.svg',
                      width: 24,
                    ),
                    onPressed: () async {
                      final selectedStadiumName = await showModalBottomSheet<String>(
                        useRootNavigator: true,
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => StadiumBottomSheet(
                          currentStadiumName: widget.stadiumName,
                        ),
                      );

                      if (selectedStadiumName == null) return;

                      // ✅ 여기서 이동 (바텀시트 완전히 닫힌 뒤라 안전)
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FieldSearchPage(stadiumName: selectedStadiumName),
                        ),
                      );

                      // go_router를 쓰고 싶으면 이걸로:
                      // context.goNamed('field_search', extra: {'stadiumName': selectedStadiumName});
                    },






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


            // 상단 탭바
            Container(
              height: 42,
              child: Row(
                children: [
                  Expanded(child: _buildTabButton(index: 0, label: '검색')),
                  Expanded(child: _buildTabButton(index: 1, label: '추천')),
                ],
              ),
            ),

            if (!isJamsil)
              Expanded(
                child: Center(
                  child: Image.asset( 'assets/images/developing_image.jpg',),
                ),
              )
            else



            // 본문 영역
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: IndexedStack(
                  index: _selectedIndex,
                  children: [
                    // 직접 검색 탭
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        const Text(
                          '원하는 구역을 선택해서 시야를 확인해보세요!',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            fontFamily: 'Pretendard',
                            height : 1,
                            letterSpacing: -0.16,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // SizedBox(
                        //   width: 360,
                        //   height: 360,
                        //   child: InteractiveViewer(
                        //     minScale: 1.0,
                        //     maxScale: 4.0,
                        //     boundaryMargin: const EdgeInsets.all(40),
                        //     child: JamsilMap(),
                        //   ),
                        // )

                        ///자연스러운 버전
                        SizedBox(
                          width: 360,
                          height: 360,
                          child: ClipRect(
                            child: InteractiveViewer(
                              panEnabled: true,
                              scaleEnabled: true,
                              minScale: 1,
                              maxScale: 5,
                              boundaryMargin: EdgeInsets.zero,
                              child: JamsilMap(
                                onSectionSelected: (section) {

                                  setState(() {
                                    _selectedIndex = 0;
                                    sectionController.text = section;
                                  });

                                  final stadiumName = widget.stadiumName;
                                  final sectionTrim = sectionController.text.trim();


                                  // ✅ 탭 이벤트/프레임 충돌 방지: 다음 프레임에 이동
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    if (!context.mounted) return;
                                    context.pushNamed(
                                      'field_result',
                                      extra: {
                                        'stadiumName': stadiumName,
                                        'section': sectionTrim,
                                      },
                                    );
                                  });
                                },
                              ),


                            ),
                          ),
                        ),


                        const SizedBox(height: 25),

                        const Text(
                          '내가 최근에 검색한 좌석',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            fontFamily: 'Pretendard',
                            height : 1,
                            letterSpacing: -0.16,
                          ),
                        ),

                        const SizedBox(height: 32.75),
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 19),

                        child:  Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [

                        Image.asset(
                          'assets/images/bori_sleepy.jpg',
                          width: 72.6,
                          height: 60.5,
                        ),
                        const SizedBox(width: 13),

                        // 📝 "경기가 없습니다" 텍스트 (오른쪽)
                        const Text(
                          '최근에 검색한 좌석이 없어요',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'omyu pretty',
                            height: 1.37,
                            letterSpacing: -0.16,
                          ),
                        ),
                          ],
                        ),
                        ),

                      ],
                    ),


                    _buildRecommendTab(),


                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 탭바 버튼
  Widget _buildTabButton({required int index, required String label}) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        AmplitudeFlutter.getInstance().logEvent(
          'change_stadium_search_tab',
          eventProperties: {
            'component': 'btn_click',
            'tab_type': index == 0 ? 'direct' : 'hashtag',
            'importance': 'High',
          },
        );

        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        width: 195,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 0),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary200 : const Color(0xFFFAFAFA), // ✅ 선택 안 됐을 때 배경색
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary700 : const Color(0xFFAFB1B6), // ✅ 선택 안 됐을 때 밑줄 색
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          borderRadius: BorderRadius.circular(0),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 12,
            letterSpacing: -0.12,
            height: 1.5,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.primary800 : AppColors.gray700,
          ),
        ),
      ),

    );
  }
}

class StadiumBottomSheet extends StatelessWidget {
  final String currentStadiumName; // ✅ 추가

  const StadiumBottomSheet({
    super.key,
    required this.currentStadiumName,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ 현재 구장 제외한 리스트(8개)
    final filteredStadiums = teamStadiums
        .where((s) => s.stadiumName != currentStadiumName)
        .toList();

    return SafeArea(
      bottom: false,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.45,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray700,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              '타구장 이동',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'Pretendard',
                letterSpacing: -0.16,
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: GridView.builder(
                itemCount: filteredStadiums.length, // ✅ 8개
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 60/ 90,
                ),
                itemBuilder: (context, index) {
                  final stadium = filteredStadiums[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).pop(stadium.stadiumName);
                    },

                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          stadium.assetPath,
                          width: 80,
                          height: 90,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          stadium.teamName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Pretendard',
                            letterSpacing: -0.12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/// ✅ 이미지(텍스트 포함된 png)를 그대로 카드로 보여주는 위젯
class _ImageCard extends StatelessWidget {
  final String assetPath;
  final double width;
  final double height;
  final VoidCallback? onTap;

  const _ImageCard({
    required this.assetPath,
    required this.width,
    required this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: width,
          height: height,
          child: Image.asset(
            assetPath,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

/// ✅ 아직 이미지 없는 카드 자리(placeholder)
class _PlaceholderCard extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const _PlaceholderCard({
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(1, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.27, 1.0],
              colors: [
                Colors.transparent,
                Colors.black,
              ],
            ),
          ),
        ),
      ),
    );
  }
}




List<DropdownMenuItem<String>> buildZoneItems(String? stadiumCode) {
  final zones = stadiumZones[stadiumCode] ?? {};
  return zones.entries.map((entry) {
    return DropdownMenuItem<String>(
      value: entry.key,
      child: Text(entry.value),
    );
  }).toList();
}

final categories = [
  {'thumb': 'assets/images/seat_reco_cheer.png', 'banner': 'assets/images/cheer_long.png', 'title': '열정 가득! 응원 명당'},
  {'thumb': 'assets/images/seat_reco_sun.png',   'banner': 'assets/images/sun_long.png',   'title': '햇빛 피해 즐기는 직관'},
  {'thumb': 'assets/images/seat_reco_rain.png',  'banner': 'assets/images/rain_long.png',  'title': '비 와도 끝까지 쾌적하게'},
  {'thumb': 'assets/images/seat_reco_view.png',  'banner': 'assets/images/view_long.png',  'title': '시야 방해 없이!'},
  {'thumb': 'assets/images/seat_reco_wide.png',  'banner': 'assets/images/wide_long.png',  'title': '두 다리 쭉! 넓은 좌석'},
];