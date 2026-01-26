import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/amplitude/AmplitudeFlutter.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../main.dart';
import '../../../shared/service/home_view.dart';
import '../../../shared/service/api_service.dart';
import '../../../shared/widgets/common_header.dart';
import '../data/selected_hashtagcodes.dart';
import '../widget/jamsil_map.dart';
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
  bool _isDirectSheetOpen = false;
  String? _openPill; // 'section' or 'row'
  bool _isSheetOpen = false;



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

    final stadiumCode = stadiumNameToCode[widget.stadiumName];
    final zoneShortCode = selectedZone;

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
            letterSpacing: -0.12,
            height: 1.5,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.primary800 : AppColors.gray700,
          ),
        ),
      ),

    );
  }

  void _showDirectSearchBottomSheet() async {

    setState(() => _isDirectSheetOpen = true);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      barrierColor: Colors.transparent,
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
                top: 0,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    const SizedBox(height: 16),

                    Container(
                      width: 36,
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 0),
                      decoration: BoxDecoration(
                        color: AppColors.gray700,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),


                    const SizedBox(height: 12),

                    if (widget.stadiumName.replaceAll(' ', '') == '잠실야구장') ...[
                      Center(
                        child: Text(
                          '원하는 구역을 선택해서\n 좌석 시야를 확인하세요.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                            letterSpacing: -0.16,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
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


                                // ✅ 바텀시트 입력값 반영
                                sectionController.text = section;
                                setModalState(() {}); // ✅ 바텀시트 UI 갱신

                                // ✅ (원하면) 누르면 바로 결과로 이동
                                Navigator.pop(context);

                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (!context.mounted) return;
                                  context.pushNamed(
                                    'field_result',
                                    extra: {
                                      'index': 0,
                                      'stadiumName': widget.stadiumName,
                                      'section': section,
                                    },
                                  );
                                });
                              },
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],




                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (!mounted) return;
    setState(() => _isDirectSheetOpen = false); // ✅ 닫히면 원복

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
                  Expanded(child: _buildTabButton(index: 0, label: '검색')),
                  Expanded(child: _buildTabButton(index: 1, label: '추천')),
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
                          label: widget.section?.isNotEmpty == true
                              ? '${widget.section}구역'
                              : '구역',
                          isSelected: widget.section?.isNotEmpty == true,
                          isOpen: _isDirectSheetOpen,
                          onTap: () {
                            AmplitudeFlutter.getInstance().logEvent(
                              'change_stadium_direct_search_tab',
                              eventProperties: {
                                'event_type': 'Custom',
                                'component': 'btn_click',
                                'field_changed': 'section',
                                'importance': 'High',
                              },
                            );
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

                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Stack(
                        children: [
                          (_selectedIndex == 0 ? isLoading : isLoadingHashtag)
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
                          // ✅ 바텀시트 떠 있을 때만 아래 영역을 어둡게
                          if (_isDirectSheetOpen)
                            Positioned.fill(
                              child: Container(color: Colors.black.withOpacity(0.35)),
                            ),
                    ],
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
  bool isOpen = false,
}) {
  // ✅ 열려있을 때만 연두색
  final color = isOpen ? AppColors.primary700 : const Color(0xFF272727);
  final iconColor = isOpen ? AppColors.primary700 : const Color(0xFF272727);

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
              isOpen
                  ? 'assets/icons/up_button.svg'
                  : 'assets/icons/filter_down_blackk.svg',
              width: 10,
              height: 10,
              color: iconColor,
            ),
          ],
        ),
      ),
    ),
  );
}



String displaySection(String raw) {
  final t = raw.trim();
  if (t.isEmpty) return t;
  if (t.contains('구역')) return t;

  // 숫자만이면 "구역" 붙이기
  if (RegExp(r'^\d+$').hasMatch(t)) {
    return '${t}구역';
  }
  return t;
}

String apiSection(String input) {
  // "418구역" -> "418"
  return input.replaceAll('구역', '').trim();
}
