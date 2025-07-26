import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../app_colors.dart';
import '../main.dart';
import '../models/home_view.dart';
import '../service/api_service.dart';
import '../widgets/common_header.dart';
import 'FieldSearchPage.dart';

class FieldHashtagSearchResultPage extends StatefulWidget {
  final int index; // 0이면 직접검색, 1이면 해시태그검색
  final String stadiumName;
  final String? zone, section, row;
  final Map<String, String>? selectedTags;
  final Map<String, List<String>>? tagCategories;


  const FieldHashtagSearchResultPage({
    super.key,
    required this.index,
    required this.stadiumName,
    this.zone,
    this.section,
    this.row,
    this.selectedTags,
    this.tagCategories,
  });





  @override
  State<FieldHashtagSearchResultPage> createState() => _FieldHashtagSearchResultPageState();
}

class _FieldHashtagSearchResultPageState extends State<FieldHashtagSearchResultPage> {
  late Map<String, String> selectedTags;
  int _selectedIndex = 0; // 기본은 직접 검색

  String? selectedTag;
  String? selectedZone;
  final TextEditingController sectionController = TextEditingController();
  final TextEditingController rowController = TextEditingController();

  String? get selectedStadiumCode => stadiumNameToCode[widget.stadiumName];

  bool get isDirectSearchValid {
    final hasZone = selectedZone?.isNotEmpty ?? false;
    final hasSection = sectionController.text.trim().isNotEmpty;

    // 존 또는 구역 중 하나라도 입력했으면 활성화
    return hasZone || hasSection;
  }




  String? getZoneNameFromCode(String stadiumName, String? zoneCode) {
    if (zoneCode == null) return null;
    final code = stadiumNameToCode[stadiumName];
    return stadiumZones[code]?[zoneCode] ?? zoneCode;
  }


// 예시 데이터 구조에 맞게 수정 필요
  List<SeatViewDetail> seatViews = [];



  @override
  void initState() {
    super.initState();
    print('✅ SeatViewDetailPage initState 진입');
    _selectedIndex = widget.index;
    selectedTags = Map<String, String>.from(widget.selectedTags ?? {});

    sectionController.addListener(() => setState(() {}));
    rowController.addListener(() => setState(() {}));
  }

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

  void _showDirectSearchBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // ✅ 바텀시트 열기 전에 현재 선택 상태 반영
        selectedZone ??= widget.zone;
        if (sectionController.text.isEmpty && widget.section != null) {
          sectionController.text = widget.section!;
        }
        if (rowController.text.isEmpty && widget.row != null) {
          rowController.text = widget.row!;
        }

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 24,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '좌석 검색',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
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
                        analytics.logEvent('change_stadium_direct_dropdown', properties: {
                          'event_type': 'Custom',
                          'component': 'btn_click',
                          'changed_field': 'zone_name',
                          'changed_value': value,
                          'importance': 'High',
                        });
                        analytics.logEvent('change_stadium_direct_dropdown', properties: {
                          'event_type': 'Custom',
                          'component': 'btn_click',
                          'changed_field': 'section',
                          'changed_value': sectionController.text,
                          'importance': 'High',
                        });

                        analytics.logEvent('change_stadium_direct_dropdown', properties: {
                          'event_type': 'Custom',
                          'component': 'btn_click',
                          'changed_field': 'row',
                          'changed_value': rowController.text,
                          'importance': 'High',
                        });
                        setState(() {
                          selectedZone = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: sectionController,
                            textAlign: TextAlign.center,
                            decoration: _seatInputDecoration('ex) 314'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('구역',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: rowController,
                            textAlign: TextAlign.center,
                            decoration: _seatInputDecoration('ex) 3'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('열',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 46),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: isDirectSearchValid
                            ? () {
                          Navigator.pop(context); // 닫고 이동
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
                          backgroundColor: isDirectSearchValid ? AppColors.primary700 : AppColors.gray200,
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
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  InputDecoration _seatInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
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
    );
  }



  void _showCategoryBottomSheet(String category, List<String> tags) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.68,
          minChildSize:0.68,
          maxChildSize: 0.68,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                '좌석에 관한 해시태그로 검색해보세요!',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Pretendard',
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '최대 5개까지 고를 수 있어요.',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: SvgPicture.asset(
                              'assets/icons/cancel_button.svg',
                              width: 22,
                              height: 22,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: (widget.tagCategories ?? {}).entries.map((entry) {
                              final category = entry.key;
                              final tags = entry.value;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: tags.map((tag) {
                                      final selected = selectedTags[category] == tag;
                                      return ChoiceChip(
                                        showCheckmark: false,
                                        label: Text(tag),
                                        selected: selected,
                                        onSelected: (_) {
                                          setState(() {
                                            if (selected) {
                                              selectedTags.remove(category);
                                              selectedTag = null;
                                            } else {
                                              selectedTags[category] = tag;
                                              selectedTag = tag;
                                            }
                                          });
                                          setModalState(() {});
                                        },
                                        selectedColor: AppColors.primary100,
                                        backgroundColor: Colors.white,
                                        labelStyle: TextStyle(
                                          color: selected ? const Color(0xFF272727) : AppColors.gray700,
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
                                  const SizedBox(height: 15),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      SafeArea(
                        top: false,
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {

                              final List<String> selectedHashtagList = selectedTags.entries
                                  .map((entry) => "${entry.key}:${entry.value}")
                                  .toList();

                              // ✅ Amplitude 이벤트 로깅
                              analytics.logEvent('change_stadium_hashtag_dropdown', properties: {
                                'event_type': 'Custom',
                                'component': 'btn_click',
                                'changed_category': selectedHashtagList,
                                'changed_value': selectedHashtagList.length,
                                'importance': 'High',
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary700,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(36),
                              ),
                            ),
                            child: const Text(
                              '확인',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
            Container(
              height: 42,
              child: Row(
                children: [
                  Expanded(child: _buildTabButton(index: 0, label: '직접 검색')),
                  Expanded(child: _buildTabButton(index: 1, label: '해시태그 검색')),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  // 탭 0: 직접 검색 (임시 화면)
                  // 직접 검색 탭 (index == 0)

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        _buildDropdownPill(
                          label: (widget.zone != null && widget.zone!.isNotEmpty)
                              ? getZoneNameFromCode(widget.stadiumName, widget.zone) ?? '존'
                              : '존',
                          isSelected: widget.zone?.isNotEmpty == true,
                          onTap: () {
                            analytics.logEvent('change_stadium_direct_search_tab', properties: {
                              'event_type': 'Custom',
                              'component': 'btn_click',
                              'field_changed': 'zone_name',
                              'importance': 'High',
                            });
                            _showDirectSearchBottomSheet();
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildDropdownPill(
                          label: widget.section?.isNotEmpty == true ? widget.section! : '구역',
                          isSelected: widget.section?.isNotEmpty == true,
                          onTap: () {
                            analytics.logEvent('change_stadium_direct_search_tab', properties: {
                              'event_type': 'Custom',
                              'component': 'btn_click',
                              'field_changed': 'section',
                              'importance': 'High',
                            });
                            _showDirectSearchBottomSheet();
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildDropdownPill(
                          label: widget.row?.isNotEmpty == true ? widget.row! : '열',
                          isSelected: widget.row?.isNotEmpty == true,
                          onTap: () {
                            analytics.logEvent('change_stadium_direct_search_tab', properties: {
                              'event_type': 'Custom',
                              'component': 'btn_click',
                              'field_changed': 'row',
                              'importance': 'High',
                            });
                            _showDirectSearchBottomSheet();
                          },
                        ),
                      ],
                    ),
                  ),



                  // 탭 1: 해시태그 검색
                  Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(
                          children: (widget.tagCategories ?? {}).keys.map((category) {
                            final isSelected = selectedTags.containsKey(category);
                            return Padding(
                              padding: const EdgeInsets.only(right: 4.8),
                              child: InkWell(
                                onTap: () {
                                  // Amplitude 이벤트 추가
                                  analytics.logEvent(
                                      'change_stadium_hashtag_tab',
                                      properties: {
                                        'event_type': 'Custom',
                                        'component': 'btn_click',
                                        'selected_category': category,
                                        'importance': 'High',
                                      });
                                  _showCategoryBottomSheet(category,
                                      (widget.tagCategories ?? {})[category]!);
                                },
                                borderRadius: BorderRadius.circular(50),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFF272727) : const Color(0xFFD3D3D3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        category,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                          color: isSelected ? const Color(0xFF272727) : const Color(0xFFD3D3D3),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      SvgPicture.asset(
                                        'assets/icons/filter_down_blackk.svg',
                                        width: 5,
                                        height: 10,
                                        color: isSelected ? const Color(0xFF272727) : const Color(0xFFD3D3D3),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 22,
                            crossAxisSpacing: 24,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: 8,
                            itemBuilder: (context, index) {
                              final seatViewId = seatViews[index].seatViewId;

                              return GestureDetector(
                                onTap: () async {
                                  print('🟡 카드 클릭됨, seatViewId: $seatViewId'); // ← 이거 꼭 찍히는지 확인!
                                  final detail = await fetchSeatViewDetail(seatViewId);
                                  if (detail != null && context.mounted) {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: Text(detail.stadiumName),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Image.network(detail.viewMediaUrl),
                                            Text('존: ${detail.zoneName}'),
                                            Text('구역: ${detail.section}'),
                                            Text('열: ${detail.seatRow}'),
                                            ...detail.emotionTags.map((e) => Text('#$e')),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    'assets/images/KakaoTalk_20250611_184301449.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            }

                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}

Widget _buildDropdownPill({
  required String label,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  final color = isSelected ? const Color(0xFF272727) : const Color(0xFFD3D3D3);

  return IntrinsicWidth(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
            SvgPicture.asset(
              'assets/icons/filter_down_blackk.svg',
              width: 5,
              height: 10,
              color: isSelected ? const Color(0xFF272727) : const Color(0xFFD3D3D3),
            ),
          ],
        ),
      ),
    ),
  );
}



