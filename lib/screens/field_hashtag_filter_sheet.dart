import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../app_colors.dart';
import '../widgets/common_header.dart';

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
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    selectedTags = Map<String, String>.from(widget.selectedTags ?? {});
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
          initialChildSize: 0.85,
          minChildSize: 0.3,
          maxChildSize: 0.95,
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
                                            } else {
                                              selectedTags[category] = tag;
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
            CommonHeader(title: widget.stadiumName),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 36,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: const Color(0xFFD3D3D3)),
                              color: Colors.white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  '존',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFD3D3D3),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFD3D3D3), size: 20),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 36,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: const Color(0xFFD3D3D3)),
                              color: Colors.white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  '구역',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFD3D3D3),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFD3D3D3), size: 20),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 36,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: const Color(0xFFD3D3D3)),
                              color: Colors.white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  '월',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFD3D3D3),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFD3D3D3), size: 20),
                              ],
                            ),
                          ),
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
                                onTap: () => _showCategoryBottomSheet(category, (widget.tagCategories ?? {})[category]!),
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
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/images/KakaoTalk_20250611_184301449.jpg',
                                fit: BoxFit.cover,
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


