import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../app_colors.dart';
import '../main.dart';
import '../widgets/common_header.dart';
import 'package:go_router/go_router.dart';


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

  bool get isJamsil => widget.stadiumName == '잠실 야구장';

  bool get isDirectSearchValid {
    final hasZone = selectedZone?.isNotEmpty ?? false;
    final hasSection = sectionController.text.trim().isNotEmpty;

    // 존 또는 구역 중 하나라도 입력했으면 활성화
    return hasZone || hasSection;
  }

  bool get isHashtagSearchValid {
    return selectedTags.length >= 1;
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
                  IconButton(
                    padding: EdgeInsets.zero,
                    icon: SvgPicture.asset(
                      'assets/icons/back_but.svg',
                      width: 10,
                      height: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 0),
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
                  Expanded(child: _buildTabButton(index: 0, label: '직접 검색')),
                  Expanded(child: _buildTabButton(index: 1, label: '해시태그 검색')),
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
                        const SizedBox(height: 22),
                        const Text(
                          '좌석 검색',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 존 선택 드롭다운
                        SizedBox(
                          width: double.infinity,
                          child:DropdownButtonFormField<String>(
                            dropdownColor: Colors.white,
                            decoration: InputDecoration(
                              hintText: '존을 선택하세요.',
                              hintStyle: const TextStyle(
                                color: AppColors.gray700,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Pretendard',
                              ),
                              filled: true,
                              fillColor: AppColors.gray100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.gray300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.gray300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFF94C32C)),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            ),
                            value: selectedZone,
                            items: buildZoneItems(selectedStadiumCode),
                            onChanged: (value) {
                              setState(() {
                                selectedZone = value;
                              });
                            },
                          ),
                        ),


                        const SizedBox(height: 12),

                        // 구역/열 입력 필드
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: sectionController,
                                onChanged: (_) => setState(() {}),
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  hintText: 'ex) 314',
                                  hintStyle: const TextStyle(
                                    color: AppColors.gray700,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Pretendard',
                                  ),
                                  filled: true,
                                  fillColor: AppColors.gray100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: AppColors.gray300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: AppColors.gray300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFFF94C32C)),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '구역',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: rowController,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  hintText: 'ex) 3',
                                  hintStyle: const TextStyle(
                                    color: AppColors.gray700,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Pretendard',
                                  ),
                                  filled: true,
                                  fillColor: AppColors.gray100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: AppColors.gray300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: AppColors.gray300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFFF94C32C)),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '열',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 46),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(


                            onPressed: isDirectSearchValid

                                ? () {
                              analytics.logEvent('enter_stadium_direct_search', properties: {
                                'event_type': 'Custom',
                                'component': 'form_submit',
                                'zone_name': stadiumZones[selectedStadiumCode]?[selectedZone] ?? selectedZone ?? '',
                                'section': sectionController.text,
                                'row': int.tryParse(rowController.text) ?? 0,
                                'importance': 'High',
                              });
                              analytics.logEvent('execute_stadium_search', properties: {
                                'event_type': 'Custom',
                                'component': 'btn_click',
                                'search_type': 'direct',
                              });
                              context.pushNamed(
                                'field_result',
                                extra: {
                                  'index': 0,
                                  'stadiumName': widget.stadiumName,
                                  'zone': selectedZone,
                                  'section': sectionController.text,
                                  'row': rowController.text,
                                },
                              );
                            }
                                : null,


                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDirectSearchValid? AppColors.primary700 : AppColors.gray200,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(36),
                                side: BorderSide(
                                  color: isDirectSearchValid ? AppColors.primary700 : Colors.transparent,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Text(
                              '작성 완료',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDirectSearchValid ? Colors.white : AppColors.gray700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),



                    //해시태그 검색 화면
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 22),
                            const Text(
                              '좌석에 관한 해시태그로 검색해보세요!',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 0),
                            const Text(
                              '최대 5개까지 고를 수 있어요.',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: Color(0xFFA9A9A9),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // 해시태그 Wrap
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: tagCategories.entries.map((entry) {
                                final category = entry.key;
                                final tags = entry.value;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(category,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,)),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 12,
                                      runSpacing: 12,
                                      children: tags.map((tag) {
                                        final selected = selectedTags[category] == tag;
                                        return ChoiceChip(
                                          showCheckmark: false, // ✅ 체크 아이콘 제거
                                          label: Text(tag),
                                          selected: selected,
                                          onSelected: (_) {
                                            setState(() {
                                              if (selected) {
                                                // ✅ 이미 선택된 경우 → 해제
                                                selectedTags.remove(category);
                                              } else {
                                                // ✅ 선택되지 않은 경우 → 해당 카테고리에 tag 할당
                                                selectedTags[category] = tag;
                                              }
                                            });
                                          },
                                          selectedColor: AppColors.primary100,
                                          backgroundColor: Colors.white,
                                          labelStyle: TextStyle(
                                            color: selected ?  Color(0xFF272727) : AppColors.gray700,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            side: BorderSide(
                                              color: selected ? AppColors.primary700 : AppColors.gray300,
                                              width: 1,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                );
                              }).toList(),
                            ),


                            const SizedBox(height: 22),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: () {

                                  final List<String> selectedHashtagList = selectedTags.entries
                                      .map((entry) => "${entry.key}:${entry.value}")
                                      .toList();

                                  analytics.logEvent('select_stadium_hashtag', properties: {
                                    'event_type': 'Custom',
                                    'component': 'btn_click',
                                    'hashtags': selectedHashtagList,
                                    'hashtag_count': selectedHashtagList.length,
                                    'importance': 'High',
                                  });
                                  analytics.logEvent('execute_stadium_search', properties: {
                                    'event_type': 'Custom',
                                    'component': 'btn_click',
                                    'search_type': 'hashtag',
                                  });

                                  context.pushNamed(
                                    'field_result',
                                    extra: {
                                      'index': 1,
                                      'stadiumName': widget.stadiumName,
                                      'selectedTags': selectedTags,
                                      'tagCategories': tagCategories,
                                    },
                                  );

                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: (_selectedIndex == 0 && isDirectSearchValid) ||
                                      (_selectedIndex == 1 && isHashtagSearchValid)
                                      ? AppColors.primary700
                                      : AppColors.gray200,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(36),
                                    side: BorderSide(
                                      color: (_selectedIndex == 0 && isDirectSearchValid) ||
                                          (_selectedIndex == 1 && isHashtagSearchValid)
                                          ? AppColors.primary700
                                          : Colors.transparent,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  '검색하기',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: (_selectedIndex == 0 && isDirectSearchValid) ||
                                        (_selectedIndex == 1 && isHashtagSearchValid)
                                        ? Colors.white
                                        : AppColors.gray700,
                                  ),
                                ),
                              ),

                            ),
                          ],

                        ),


                      ),
                    )




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
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        width: 195,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 0),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary200 : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary700 : const Color(0xFFFAFAFA),
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
            letterSpacing: -0.26,
            height: 1.5,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.primary800 : AppColors.gray700,
          ),
        ),
      ),
    );
  }
}
final Map<String, String> stadiumNameToCode = {
  '잠실 야구장': 'JAM',
  '고척 스카이돔': 'GOC',
  '랜더스 필드': 'ICN',
  '위즈 파크': 'SUW',
  '한화생명 볼파크': 'DJN',
  '라이온즈 파크': 'DAE',
  '사직 야구장': 'BUS',
  'NC 파크장': 'CHW',
  '챔피언스 월드': 'GWJ',
};



final Map<String, Map<String, String>> stadiumZones = {
  'JAM': {
    'JAM_PREMIUM': '중앙석 (프리미엄석)',
    'JAM_TABLE': '테이블석',
    'JAM_EXCITING': '익사이팅존',
    'JAM_BLUE': '블루석',
    'JAM_ORANGE': '오렌지석',
    'JAM_RED': '레드석',
    'JAM_NAVY': '네이비석',
    'JAM_GREEN': '그린석 (좌석)',
  },
  'GOC': {
    'GOC_SKYBOX': '스카이박스',
    'GOC_RDDUB': 'R.d-dub',
    'GOC_LEXUS1': 'LEXUS 1층 테이블석',
    'GOC_LEXUS2': 'LEXUS 2층 테이블석',
    'GOC_NAVER': 'NAVER 2층 테이블석',
    'GOC_INFIELD_COUPLE': '내야커플석',
    'GOC_OUTFIELD_COUPLE': '외야커플석',
    'GOC_DARK_BURGUNDY': '다크버건디석',
    'GOC_BURGUNDY': '버건디석',
    'GOC_3F': '3층 지정석',
    'GOC_4F': '4층 지정석',
    'GOC_WHEELCHAIR': '휠체어석',
    'GOC_OUTFIELD': '외야 지정석',
    'GOC_OUTFIELD_FAMILY': '외야 패밀리석',
    'GOC_OUTFIELD_BABY': '외야 유아동반석',
  },
  'ICN': {
    'ICN_SKY_VIEW': '4층 SKY뷰석',
    'ICN_INFIELD_FIELD': '내야 필드석',
    'ICN_OUTFIELD_FIELD': '외야 필드석',
    'ICN_SKY_TABLE': 'SKY탁자석',
    'ICN_MINI_SKYBOX': '미니스카이박스',
    'ICN_OUTFIELD_FAMILY': '외야패밀리존',
    'ICN_EMART_FRIENDLY': '이마트 프렌들리존',
    'ICN_LANDERS_LIVE': '랜더스 라이브존',
    'ICN_PEACOCK_1F': '피코크 테이블석(1층)',
    'ICN_NOBRAND_2F': '노브랜드 테이블석(2층)',
    'ICN_DUGOUT_UPPER': '덕아웃 상단석',
    'ICN_MOLLIS_GREEN': '몰리스 그린존',
    'ICN_EUSSEUK': '으쓱이존',
    'ICN_AWAY': '원정응원석',
    'ICN_HOMERUN_COUPLE': '홈런커플존',
    'ICN_SKYBOX': '스카이박스',
    'ICN_OPEN_BBQ': '오픈 바비큐존',
    'ICN_EMART_BBQ': '이마트바비큐존',
    'ICN_YOGIYO_FAMILY': '요기요 내야패밀리존',
    'ICN_CHOGA': '초가정자',
    'ICN_ROCKET_PARTY': '로케트배터리 외야파티덱',
  },
  'SUW': {
    'SUW_CATCHER_TABLE': '포수 뒤 테이블석',
    'SUW_CENTER_TABLE': '중앙 테이블석',
    'SUW_BASE_TABLE': '1루/3루 테이블석',
    'SUW_HIGH_FIVE': '하이파이브존',
    'SUW_EXCITING': '익사이팅석',
    'SUW_CENTER': '중앙 지정석',
    'SUW_CHEER': '응원 지정석',
    'SUW_INFIELD': '내야 지정석',
    'SUW_SKY': '스카이존',
    'SUW_OUTFIELD_TABLE': '외야 테이블석',
    'SUW_OUTFIELD_GRASS': '외야 잔디자유석',
  },

  'DJN': {
    'DJN_CATCHER_BACK': '포수 후면석',
    'DJN_CENTER': '중앙 지정석',
    'DJN_CENTER_TABLE': '중앙 탁자석',
    'DJN_INFIELD_A': '내야 지정석A',
    'DJN_INFIELD_B': '내야 지정석B',
    'DJN_INFIELD_BOX': '내야 박스석',
    'DJN_INFIELD_COUPLE': '내야 커플석',
    'DJN_INFIELD_TABLE_4F': '내야 탁자석(4층)',
    'DJN_CASS_CHEER': '카스존(응원단석)',
    'DJN_INNINGS_VIP': '이닝스 VIP바 & 룸/테라스',
    'DJN_SKYBOX': '스카이박스',
    'DJN_OUTFIELD': '외야지정석',
    'DJN_BAMBKEL_GRASS': '밤켈존(잔디석)',
    'DJN_OUTFIELD_TABLE': '외야탁자석',
  },

  'DAE': {
    'DAE_SKY_YOGIBO': 'SKY 요기보 패밀리존',
    'DAE_SKY_LOWER': 'SKY 하단 지정석',
    'DAE_3B_SKY_UPPER': '3루 SKY 상단 지정석',
    'DAE_CENTER_SKY_UPPER': '중앙 SKY 상단 지정석',
    'DAE_1B_SKY_UPPER': '1루 SKY 상단 지정석',
    'DAE_SWEET_BOX': '스윗박스',
    'DAE_PARTY_LIVE': '파티플로어 라이브석',
    'DAE_VIP': 'VIP석',
    'DAE_EUTEUM_CENTER': '으뜸병원 중앙 테이블석',
    'DAE_ISU_3B': '이수그룹 3루 테이블석',
    'DAE_ISU_PETASYS_1B': '이수페타시스 1루 테이블석',
    'DAE_3B_EXCITING': '3루 익사이팅석',
    'DAE_1B_EXCITING': '1루 익사이팅석',
    'DAE_BLUE': '블루존',
    'DAE_AWAY': '원정 응원석',
    'DAE_1B_INFIELD': '1루 내야지정석',
    'DAE_WHEELCHAIR': '휠체어 장애인석',
    'DAE_OUTFIELD_FAMILY': '외야 패밀리석',
    'DAE_OUTFIELD_TABLE': '외야 테이블석',
    'DAE_OUTFIELD': '외야 지정석',
    'DAE_OUTFIELD_COUPLE': '외야 커플 테이블석',
    'DAE_ROOFTOP': '루프탑 테이블석',
  },
  'BUS': {
    'BUS_GROUND': '그라운드석',
    'BUS_CENTER_TABLE': '중앙탁자석',
    'BUS_WIDE_TABLE': '와이드탁자석',
    'BUS_CHEER_TABLE': '응원탁자석',
    'BUS_INFIELD_TABLE': '내야탁자석',
    'BUS_3B_GROUP': '3루 단체석',
    'BUS_INFIELD_FIELD': '내야필드석',
    'BUS_INFIELD_UPPER': '내야상단석',
    'BUS_ROCKET_BATTERY': '로케트 배터리존',
    'BUS_OUTFIELD': '외야석',
    'BUS_CENTER_UPPER': '중앙상단석',
    'BUS_WHEELCHAIR': '휠체어석',
  },

  'GWJ': {
    'GWJ_CHAMPION': '챔피언석',
    'GWJ_CENTER_TABLE': '중앙테이블석',
    'GWJ_DISABLED': '장애인지정석',
    'GWJ_K9': 'K9',
    'GWJ_K8': 'K8',
    'GWJ_K5': 'K5',
    'GWJ_SURPRISE': '서프라이즈석',
    'GWJ_TIGERS_FAMILY': '타이거즈가족석',
    'GWJ_WHEELCHAIR': '휠체어석',
    'GWJ_4F_PARTY': '4층파티석',
    'GWJ_SKYBOX': '스카이박스',
    'GWJ_SKY_PICNIC': '스카이피크닉석',
    'GWJ_EV': 'EV',
    'GWJ_5F_TABLE': '5층 테이블석',
    'GWJ_OUTFIELD': '외야석',
    'GWJ_OUTFIELD_TABLE': '외야테이블석',
  },

  'CHW': {
    'CHW_INFIELD': '내야석',
    'CHW_TABLE': '테이블석',
    'CHW_ROUND_TABLE': '라운드 테이블석',
    'CHW_OUTFIELD_GRASS': '외야잔디석',
    'CHW_OUTFIELD': '외야석',
    'CHW_3_4F_INFIELD': '3·4층 내야석',
    'CHW_WHEELCHAIR': '휠체어석',
    'CHW_MINI_TABLE': '미니테이블석',
    'CHW_FAMILY': '가족석',
    'CHW_SKYBOX': '스카이박스',
    'CHW_BULLPEN_FAMILY': '불펜 가족석',
    'CHW_BULLPEN': '불펜석',
    'CHW_COUNTER': '카운터석',
    'CHW_ABL_PREMIUM': 'ABL생명 프리미엄석',
    'CHW_ABL_PREMIUM_TABLE': 'ABL생명 프리미엄 테이블석',
    'CHW_BBQ': '바베큐석',
    'CHW_PICNIC_TABLE': '피크닉테이블석',
    'CHW_NORTH_PEAK_CAMPING': '노스피크캠핑석',
  },

};

List<DropdownMenuItem<String>> buildZoneItems(String? stadiumCode) {
  final zones = stadiumZones[stadiumCode] ?? {};
  return zones.entries.map((entry) {
    return DropdownMenuItem<String>(
      value: entry.key,
      child: Text(entry.value),
    );
  }).toList();
}