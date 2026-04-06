import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:inninglog/feature/field/screens/seat_detail_page.dart';
import '../../../shared/amplitude/AmplitudeFlutter.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../main.dart';
import '../../../shared/service/home_view.dart';
import '../../../shared/service/api_service.dart';
import '../../../shared/widgets/common_header.dart';
import '../../diary/screens/add_seat_page.dart';
import '../data/selected_hashtagcodes.dart';
import '../widgets/jamsil_map.dart';
import '../widgets/dropdown_pill.dart';
import '../widgets/empty_seat_state.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'FieldSearchPage.dart';

class FieldHashtagSearchResultPage extends StatefulWidget {
  final String stadiumName;
  final String? zone, section, row;
  final Map<String, String>? selectedTags;
  final Map<String, List<String>>? tagCategories;



  const FieldHashtagSearchResultPage({
    super.key,
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

  OverlayEntry? _rowDropdownEntry;
  final LayerLink _rowLayerLink = LayerLink();
  final GlobalKey _rowPillKey = GlobalKey();





  String? selectedTag;
  String? selectedZone;
  final TextEditingController sectionController = TextEditingController();
  final TextEditingController rowController = TextEditingController();

  bool get rowSelected => rowController.text.trim().isNotEmpty;

  String _normalizeStadiumName(String s) => s.replaceAll(' ', '').trim();
  String? get selectedStadiumCode =>
      stadiumNameToCode[widget.stadiumName.trim()];



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

  void _toggleRowDropdown() {
    if (_rowDropdownEntry != null) {
      _closeRowDropdown();
    } else {
      _openRowDropdown();
    }
  }

  void _closeRowDropdown() {
    _rowDropdownEntry?.remove();
    _rowDropdownEntry = null;

    if (!mounted) return;
    setState(() {
      _openPill = null;
      _isDirectSheetOpen = false; // 너는 이걸 “오버레이 열림”에도 쓰고 있으니 유지
    });
  }

  void _openRowDropdown() {
    setState(() {
      _openPill = 'row';
      _isDirectSheetOpen = true;
    });

    final rows = List.generate(53, (i) => '${i + 1}열');
    final scrollController = ScrollController();

    _rowDropdownEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // 바깥 클릭하면 닫힘
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _closeRowDropdown,
                child: const SizedBox.expand(),
              ),
            ),

            // pill 아래에 붙는 드랍다운
            CompositedTransformFollower(
              link: _rowLayerLink,
              showWhenUnlinked: false,
              offset: const Offset(0, 44), // pill 높이(대충) + 아래 여백
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 235,
                  height: 266,
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 8),
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                  child: ClipRect(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8), // ✅ 스크롤바를 왼쪽으로 8px "인셋"
                      child: RawScrollbar(
                        controller: scrollController,
                        thumbVisibility: true,
                        thickness: 6,
                        radius: const Radius.circular(999),
                        thumbColor: AppColors.primary300,
                        minThumbLength: 102,
                        child: Transform.translate(
                          offset: const Offset(8, 0),
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: rows.length,
                            itemBuilder: (context, index) {
                              final item = rows[index];
                              return InkWell(
                                onTap: () async {
                                  setState(() => rowController.text = item);
                                  _closeRowDropdown();
                                  await fetchDirectSearchResults();
                                },

                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.gray850,
                                      fontFamily: 'Pretendard',
                                      letterSpacing: -0.14,
                                    ),
                                  ),
                                ),

                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),


                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_rowDropdownEntry!);
  }




  List<SeatView> directSeatViews = [];
  bool isLoading = false;



  @override
  void initState() {
    super.initState();
    selectedTags = Map<String, String>.from(widget.selectedTags ?? {});
    selectedZone = widget.zone;

    selectedZone = widget.zone;
    sectionController.text = widget.section ?? '';
    rowController.text = widget.row ?? '';

      fetchDirectSearchResults(); // ✅ 직접 검색

  }




  Future<void> fetchDirectSearchResults() async {


    final stadiumCode =
    stadiumNameToCode[widget.stadiumName.trim()];

    debugPrint('stadiumName="${widget.stadiumName}" -> stadiumCode=$stadiumCode');

    if (stadiumCode == null) {
      debugPrint('❌ stadiumCode is null. stadiumNameToCode 매핑 확인 필요');
      return;
    }



    if (stadiumCode == null) return;

    final zoneShortCode = selectedZone;

    final hasZone = (selectedZone?.trim().isNotEmpty ?? false);
    final hasSection = sectionController.text.trim().isNotEmpty;

    // ✅ 존/구역 둘 다 없으면 검색 안 함
    if (!hasZone && !hasSection) return;

    // ✅ section / row 값 정리 (서버는 숫자만 기대)
    final String? section =
    sectionController.text.trim().isEmpty ? null : apiSection(sectionController.text);

    final String? row = rowController.text.trim().isEmpty
        ? null
        : rowController.text.trim().replaceAll('열', '').trim();

    setState(() => isLoading = true);

    try {
      final results = await ApiService.fetchSeatViews(
        stadiumShortCode: stadiumCode,
        zoneShortCode: zoneShortCode,
        section: section,
        seatRow: row,
      );



      if (!mounted) return;

      if (!hasZone && !hasSection) {
        debugPrint('⛔️ return: hasZone=false & hasSection=false');
        return;
      }

      if (!mounted) return;
      setState(() => directSeatViews = results.cast<SeatView>());


    } catch (e) {
      debugPrint('❌ 직접 검색 결과 에러: $e');
    } finally {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }



  void _showDirectSearchBottomSheet() async {

    setState(() {
      _isDirectSheetOpen = true;
      _openPill = 'section'; // ✅ 추가
    });

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
    setState(() {
      _isDirectSheetOpen = false;
      _openPill = null; // ✅ 닫히면 정리
    });

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



            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [

              Column(
              children: [
                  SingleChildScrollView(
                    padding: const EdgeInsetsDirectional.only(start: 16, top: 0, bottom: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [


                        DropdownPill(
                          label: widget.section?.isNotEmpty == true ? '${widget.section}구역' : '구역',
                          isSelected: widget.section?.isNotEmpty == true,
                          isOpen: _isDirectSheetOpen && _openPill == 'section',
                          onTap: () {
                            _showDirectSearchBottomSheet();
                          },
                        ),




                        const SizedBox(width: 8),

                        CompositedTransformTarget(
                          link: _rowLayerLink,
                          child: DropdownPill(
                            label: rowSelected ? rowController.text.trim() : '열 선택하기',
                            isSelected: rowSelected,
                            isOpen: _openPill == 'row',
                            onTap: () {
                              _toggleRowDropdown();
                            },
                          ),

                        ),

                      ],
                    ),
                  ),
                Expanded(
                  child: Stack(
                    children: [
                      // ✅ 로딩/빈상태/그리드
                      Builder(
                        builder: (context) {
                          final bool loading =
                          _selectedIndex == 0 ? isLoading : isLoadingHashtag;

                          final bool isEmpty =
                          _selectedIndex == 0 ? directSeatViews.isEmpty : hashtagSeatViews.isEmpty;


                          if (loading) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (isEmpty) {
                            return EmptySeatState(
                              onCreateReview: () {
                                final section = sectionController.text.trim().isNotEmpty
                                    ? apiSection(sectionController.text.trim())
                                    : null;

                                final row = rowController.text.trim().isNotEmpty
                                    ? rowController.text.trim().replaceAll('열', '').trim()
                                    : null;

                                debugPrint('🔍 stadiumName="${widget.stadiumName}" → selectedStadiumCode=$selectedStadiumCode');
                                context.pushNamed(
                                  'add_seat',
                                  extra: {
                                    'stadium': selectedStadiumCode,

                                    'initialSection': sectionController.text.trim().isNotEmpty
                                        ? apiSection(sectionController.text.trim())
                                        : null,
                                    'initialRow': rowController.text.trim().isNotEmpty
                                        ? rowController.text.trim().replaceAll('열', '').trim()
                                        : null,

                                    'showGameTime': false,
                                  },
                                );

                              },
                            );
                          }



                          return GridView.builder(
                            padding: const EdgeInsets.all(12),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 22,
                              crossAxisSpacing: 24,
                              childAspectRatio: 0.75,
                            ),
                            itemCount:
                            _selectedIndex == 0 ? directSeatViews.length : hashtagSeatViews.length,
                            itemBuilder: (context, index) {
                              final SeatView item = _selectedIndex == 0
                                  ? directSeatViews[index]
                                  : hashtagSeatViews[index];

                              final imageUrl = item.viewMediaUrl;
                              final seatViewId = item.seatViewId;

                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SeatDetailPage(
                                        seatViewId: seatViewId,
                                        imageUrl: imageUrl,
                                        stadiumName: widget.stadiumName,
                                      ),
                                    ),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image),
                                  ),
                                ),
                              );

                            },
                          );
                        },
                      ),

                      // ✅ 드랍다운 열렸을 때만 dim (한 번만!)
                      if (_isDirectSheetOpen)
                        Positioned.fill(
                          child: Container(color: Colors.black.withOpacity(0.5)),
                        ),
                    ],
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
