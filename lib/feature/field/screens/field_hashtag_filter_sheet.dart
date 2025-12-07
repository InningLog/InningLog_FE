import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/amplitude/AmplitudeFlutter.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../main.dart';
import '../../../shared/service/home_view.dart';
import '../../../shared/service/api_service.dart';
import '../../../shared/widgets/common_header.dart';
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
  bool isLoadingHashtag = false;
  List<SeatView> hashtagSeatViews = [];

  String? selectedTag;
  String? selectedZone;
  final TextEditingController sectionController = TextEditingController();
  final TextEditingController rowController = TextEditingController();

  String? get selectedStadiumCode => stadiumNameToCode[widget.stadiumName];

  bool get isDirectSearchValid {
    final hasZone = selectedZone?.isNotEmpty ?? false;
    final hasSection = sectionController.text.trim().isNotEmpty;

    return hasZone || hasSection; // ✅ 존 or 구역 중 하나만 있어도 OK
  }



  String? getZoneNameFromCode(String stadiumName, String? zoneCode) {
    if (zoneCode == null) return null;
    final code = stadiumNameToCode[stadiumName];
    return stadiumZones[code]?[zoneCode] ?? zoneCode;
  }

  String? getZoneShortCode(String stadiumCode, String? zoneName) {
    if (zoneName == null) return null;
    final zones = stadiumZones[stadiumCode];
    if (zones == null) return null;

    try {
      return zones.entries
          .firstWhere((entry) => entry.value == zoneName)
          .key;
    } catch (_) {
      return null;
    }
  }



  List<String> seatImages = [];
  bool isLoading = false;



  @override
  void initState() {
    super.initState();
    selectedTags = Map<String, String>.from(widget.selectedTags ?? {});
    _selectedIndex = widget.index; // ✅ index 반영!
    selectedZone = widget.zone;

    selectedZone = widget.zone;
    sectionController.text = widget.section ?? '';
    rowController.text = widget.row ?? '';

    if (_selectedIndex == 0) {
      fetchDirectSearchResults(); // ✅ 직접 검색
    } else {
      fetchHashtagSearchResults(); // ✅ 해시태그 검색도 반영
    }
  }


  Future<void> fetchHashtagSearchResults() async {
    print('🚀 fetchHashtagSearchResults 실행됨'); // ✅ 이게 안 찍히면 호출 안 된 것
    final stadiumCode = stadiumNameToCode[widget.stadiumName];
    if (stadiumCode == null) return;


    final hashtagCodes = getSelectedHashtagCodes(selectedTags);
    print('🎯 해시태그 코드 목록: $hashtagCodes');
    if (hashtagCodes.isEmpty) return;



    setState(() => isLoadingHashtag = true);

    try {
      final results = await ApiService.fetchSeatViewsByHashtag(
        stadiumShortCode: stadiumCode,
        hashtagCodes: hashtagCodes,
      );
      print('📸 가져온 이미지 수: ${results.length}');

      setState(() {
        hashtagSeatViews = results;
      });

    } catch (e) {
      print('❌ 해시태그 검색 에러: $e');
    } finally {
      setState(() => isLoadingHashtag = false);
    }
  }


  Future<void> fetchDirectSearchResults() async {
    print('🚀 fetchDirectSearchResults 실행됨');
    final stadiumCode = stadiumNameToCode[widget.stadiumName];
    final zoneShortCode = selectedZone;

    print('🧭 최종 selectedZone: $selectedZone');
    print('🧭 최종 section: $sectionController');
    if (stadiumCode == null) return;

    if ((widget.zone == null || widget.zone!.isEmpty) &&
        (widget.section == null || widget.section!.isEmpty)) {
      return;
    }


    setState(() => isLoading = true);

    try {
      final results = await ApiService.fetchSeatViews(
        stadiumShortCode: stadiumCode,
        zoneShortCode: zoneShortCode,
        section: widget.section?.isEmpty == true ? null : widget.section,
        seatRow: widget.row?.isEmpty == true ? null : widget.row,
      );
      print('📮 직접 검색 파라미터 → stadium: $stadiumCode, zone: ${widget.zone}, section: ${widget.section}, row: ${widget.row}');

      setState(() {
        seatImages = results;
      });
    } catch (e) {
      print('❌ 직접 검색 결과 에러: $e');
      print('📮 직접 검색 파라미터 → stadium: $stadiumCode, zone: ${widget.zone}, section: ${widget.section}, row: ${widget.row}');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildTabButton({required int index, required String label}) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });

        if (index == 0) {
          fetchDirectSearchResults();
        } else {
          fetchHashtagSearchResults();
        }
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
        selectedZone ??= widget.zone;
        if (sectionController.text.isEmpty && widget.section != null) {
          sectionController.text = widget.section!;
        }
        if (rowController.text.isEmpty && widget.row != null) {
          rowController.text = widget.row!;
        }

        return StatefulBuilder(
          builder: (context, setModalState) {
            bool isDirectSearchValid() {
              return (selectedZone?.isNotEmpty ?? false) || sectionController.text.trim().isNotEmpty;
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 24,
              ),
              child: SingleChildScrollView(
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

                    // ✅ 존 선택
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
                        setState(() {
                          selectedZone = value;
                        });
                        setModalState(() {}); // ✅ 상태 즉시 반영
                      },
                    ),

                    const SizedBox(height: 12),

                    // ✅ 구역 & 열 입력
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: sectionController,
                            textAlign: TextAlign.center,
                            onChanged: (_) => setModalState(() {}),
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
                            onChanged: (_) => setModalState(() {}),
                            decoration: _seatInputDecoration('ex) 3'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('열',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ],
                    ),

                    const SizedBox(height: 46),

                    // ✅ 작성 완료 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: isDirectSearchValid()
                            ? () {
                          Navigator.pop(context);
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
                          backgroundColor: isDirectSearchValid() ? AppColors.primary700 : AppColors.gray200,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(36),
                            side: BorderSide(
                              color: isDirectSearchValid() ? AppColors.primary700 : Colors.transparent,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Text(
                          '작성 완료',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDirectSearchValid() ? Colors.white : AppColors.gray700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
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
                              fetchHashtagSearchResults();
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
                                  const SizedBox(height: 6),
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
                              fetchHashtagSearchResults();

                              final List<String> selectedHashtagList = selectedTags.entries
                                  .map((entry) => "${entry.key}:${entry.value}")
                                  .toList();

                              // ✅ Amplitude 이벤트 로깅
                              AmplitudeFlutter.getInstance().logEvent('change_stadium_hashtag_dropdown',eventProperties: {
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FieldSearchPage(
                            stadiumName: widget.stadiumName, // 여기서 widget. 붙여야 함
                          ),
                        ),
                      );
                    },

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
              Column(
              children: [
                  SingleChildScrollView(
                    padding: const EdgeInsetsDirectional.only(start: 12, top: 18, bottom: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildDropdownPill(
                          label: (widget.zone != null && widget.zone!.isNotEmpty)
                              ? getZoneNameFromCode(widget.stadiumName, widget.zone) ?? '존'
                              : '존',
                          isSelected: widget.zone?.isNotEmpty == true,
                          onTap: () {
                            AmplitudeFlutter.getInstance().logEvent('change_stadium_direct_search_tab', eventProperties: {
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
                            AmplitudeFlutter.getInstance().logEvent('change_stadium_direct_search_tab', eventProperties: {
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
                            AmplitudeFlutter.getInstance().logEvent('change_stadium_direct_search_tab', eventProperties: {
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
                  Expanded(
                    child: (_selectedIndex == 0 ? isLoading : isLoadingHashtag)
                        ? const Center(child: CircularProgressIndicator())
                        : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 22,
                        crossAxisSpacing: 24,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: _selectedIndex == 0 ? seatImages.length : seatImages.length,
                      itemBuilder: (context, index) {
                        final imageUrl = _selectedIndex == 0 ? seatImages[index] :  seatImages[index];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),




                  // 탭 1: 해시태그 검색
                  Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                        child: Row(
                          children: (widget.tagCategories ?? {}).keys.map((category) {
                            final isSelected = selectedTags.containsKey(category);
                            return Padding(
                              padding: const EdgeInsets.only(right: 4.8),
                              child: InkWell(
                                onTap: () {
                                  // Amplitude 이벤트 추가
                                  AmplitudeFlutter.getInstance().logEvent(
                                      'change_stadium_hashtag_tab',
                                      eventProperties: {
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
                      ),Expanded(
                        child: (_selectedIndex == 0 ? isLoading : isLoadingHashtag)
                            ? const Center(child: CircularProgressIndicator())
                            : GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 22,
                            crossAxisSpacing: 24,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: _selectedIndex == 0 ? seatImages.length : hashtagSeatViews.length,
                          itemBuilder: (context, index) {
                            final imageUrl = _selectedIndex == 0
                                ? seatImages[index]
                                : hashtagSeatViews[index].viewMediaUrl;

                            return GestureDetector(
                              onTap: () {
                                if (_selectedIndex == 1) {
                                  final seatViewId = hashtagSeatViews[index].seatViewId;
                                  context.pushNamed(
                                    'seat_detail',
                                    extra: {
                                      'seatViewId': hashtagSeatViews[index].seatViewId,
                                      'imageUrl': hashtagSeatViews[index].viewMediaUrl,
                                    },
                                  );
                                }
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                                ),
                              ),
                            );
                          },

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
List<String> getSelectedHashtagCodes(Map<String, String> selectedTags) {
  return selectedTags.values
      .map((tag) => tagCodeMap[tag] ?? '')
      .where((code) => code.isNotEmpty)
      .toList();
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
  '챔피언스 필드': 'GWJ',
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