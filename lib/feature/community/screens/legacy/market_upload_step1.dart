import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:inninglog/shared/theme/app_colors.dart';

class MarketUploadStep1 extends StatefulWidget {
  final String teamCode;
  const MarketUploadStep1({super.key, required this.teamCode});

  @override
  State<MarketUploadStep1> createState() => _MarketUploadStep1State();
}

class _MarketUploadStep1State extends State<MarketUploadStep1> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String? _selectedCategory;

  final categories = const ['티켓', '팀 의류', '응원 도구', '잡화', '야구 용품', '기타'];

  bool get _isFilled =>
      _nameCtrl.text.trim().isNotEmpty &&
      _descCtrl.text.trim().isNotEmpty &&
      _selectedCategory != null;

  void _next() {
    context.push('/market/${widget.teamCode}/upload/step2');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary50,
      body: SafeArea(
        child: Column(
          children: [
            // ── 헤더: 뒤로가기 + 진행 점(3개 중 1단계)
            Container(
              height: 56,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  // 🔙 뒤로가기 버튼
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).pop(),
                    child: SvgPicture.asset(
                      'assets/icons/back_but.svg',
                      height: 18,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF9A9A9A), // 회색 화살표
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),

            const _ProgressDots(activeIndex: 0, total: 3),

            const SizedBox(height: 24),
            // ── 본문
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 큰 타이틀
                    const Text(
                      '상품 정보를\n입력해 주세요.',
                      style: TextStyle(
                        fontSize: 24,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Pretendard',
                        color: Color(0xFF272727),
                        letterSpacing: -0.24,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 라벨 + 입력창(상품명)
                    const _FieldLabel('상품명'),
                    const SizedBox(height: 8),
                    _FigmaInput(
                      controller: _nameCtrl,
                      hintText: '상품명을 입력하세요.',
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 24),

                    // 라벨 + 멀티라인 입력창(상품 설명)
                    const _FieldLabel('상품 설명'),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: 84,
                      ), // 예: 104px
                      child: _FigmaInput(
                        controller: _descCtrl,
                        minLines: 3, // 초기 높이(3줄)
                        maxLines: null,
                        hintText:
                            '상품에 대한 설명을 작성해 주세요.\n고장이나 손상된 부분이 있다면 빠짐없이 작성해야\n오해나 분쟁을 미리 예방할 수 있어요.',
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 카테고리
                    const _FieldLabel('카테고리'),
                    const SizedBox(height: 12),
                    _CategoryGrid(
                      items: categories,
                      selected: _selectedCategory,
                      onSelect: (v) => setState(() => _selectedCategory = v),
                    ),

                    const SizedBox(height: 56),
                  ],
                ),
              ),
            ),

            // ── 하단 CTA
            Container(
              color: AppColors.primary50,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: SizedBox(
                height: 54,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isFilled ? _next : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isFilled ? AppColors.primary700 : AppColors.gray400,
                    disabledBackgroundColor: AppColors.gray300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(36),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '다음',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Pretendard',
                      color: Color(0xFFFFFFFF),
                      letterSpacing: -0.16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 진행 점
class _ProgressDots extends StatelessWidget {
  final int activeIndex;
  final int total;
  final double activeWidth;
  final double dotSize;
  final double spacing;
  final Color activeColor;
  final Color inactiveColor;
  final EdgeInsets margin;

  const _ProgressDots({
    super.key,
    required this.activeIndex,
    required this.total,
    this.activeWidth = 36, // 활성된 점 길이
    this.dotSize = 15, // 점 높이 및 비활성 점 크기
    this.spacing = 12, // 점 사이 간격
    this.activeColor = AppColors.primary700, // 활성 색
    this.inactiveColor = AppColors.primary300, // 비활성 색
    this.margin = const EdgeInsets.only(left: 15, top: 5), // 위치 여백
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Row(
        children: List.generate(total, (i) {
          final bool active = i == activeIndex;
          return Container(
            margin: EdgeInsets.only(right: i < total - 1 ? spacing : 0),
            width: active ? activeWidth : dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              color: active ? activeColor : inactiveColor,
              borderRadius: BorderRadius.circular(dotSize / 2),
            ),
          );
        }),
      ),
    );
  }
}

/// 섹션 라벨
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w700,
        fontFamily: 'Pretendard',
        color: AppColors.gray850,
        letterSpacing: -0.19,
      ),
    );
  }
}

/// 피그마식 입력창 (연한 회색 배경 + 라운드 8 + 포커스 보더)
class _FigmaInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int? maxLines; // ← nullable
  final int? minLines; // ← 추가
  final ValueChanged<String>? onChanged;

  const _FigmaInput({
    super.key,
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
    this.minLines,
    this.onChanged,
  });

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: color, width: 0),
  );

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines, // ← 추가
      maxLines: maxLines, // ← nullable 허용
      cursorColor: AppColors.primary700,
      onChanged: onChanged,
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF272727),
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w400,
        letterSpacing: -0.16,
        height: 1.25,
      ),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: AppColors.gray200,
        hintText: hintText,
        hintStyle: const TextStyle(
          fontSize: 16,
          color: AppColors.gray600,
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w400,
          height: 1.25,
          letterSpacing: -0.16,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: _border(AppColors.gray200),
        enabledBorder: _border(AppColors.gray200),
        focusedBorder: _border(AppColors.gray200),
      ),
    );
  }
}

/// 카테고리 2열 그리드 (선택: 연두 배경 + 초록 보더)
class _CategoryGrid extends StatelessWidget {
  final List<String> items;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _CategoryGrid({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 2.86, // 피그마 버튼 비율에 맞춤
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final text = items[i];
        final isSelected = text == selected;
        return _CategoryButton(
          label: text,
          isSelected: isSelected,
          onTap: () => onSelect(text),
        );
      },
    );
  }
}

class _CategoryButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isSelected ? AppColors.primary100 : AppColors.gray50;
    final bd = isSelected ? AppColors.primary700 : AppColors.gray600;
    final txt = isSelected ? AppColors.gray800 : AppColors.gray800;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: bd, width: 0.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w400,
            color: txt,
            letterSpacing: -0.16,
            height: 1.25,
          ),
        ),
      ),
    );
  }
}
