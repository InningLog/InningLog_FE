import 'package:flutter/material.dart';
import '../app_colors.dart';
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


  bool get isDirectSearchValid {
    return selectedZone != null;
  }

  bool get isHashtagSearchValid {
    return selectedTags.length >= 1;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            CommonHeader(title: widget.stadiumName),

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
                          items: ['1루', '3루', '중앙', '외야'].map((zone) {
                            return DropdownMenuItem(value: zone, child: Text(zone));
                          }).toList(),
                          onChanged: (value) {
                            setState(() => selectedZone = value);
                          },
                        ),

                        const SizedBox(height: 12),

                        // 구역/열 입력 필드
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: sectionController,
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
                              context.pushNamed(
                                'field_result',
                                extra: {
                                  'index': 1,
                                  'stadiumName': widget.stadiumName,
                                  'selectedTags': selectedTags,
                                  'tagCategories': tagCategories,
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
