import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inninglog/app_colors.dart';
import 'market_upload_step3.dart';
import 'package:flutter/services.dart';

class MarketUploadStep2 extends StatefulWidget {
  final String teamCode;
  const MarketUploadStep2({super.key, required this.teamCode});

  @override
  State<MarketUploadStep2> createState() => _MarketUploadStep2State();
}

class _MarketUploadStep2State extends State<MarketUploadStep2> {
  final _priceCtrl = TextEditingController();
  bool _isNegotiable = false;
  String? _selectedCondition;


  // ✅ 여기에 추가
  final List<String> _images = [];

  bool get _isFilled =>
      _priceCtrl.text.isNotEmpty && _selectedCondition != null;

  // ✅ 📸 이 부분에 바로 추가!
  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final remain = 4 - _images.length;
    if (remain <= 0) return;

    final picked = await picker.pickMultiImage(
      limit: remain,
      imageQuality: 85,
      maxWidth: 2000,
    );
    if (picked.isEmpty) return;

    setState(() {
      _images.addAll(picked.map((x) => x.path));
    });
  }






  final conditions = const [
    ['미사용 상품', '한 번도 사용하지 않았어요'],
    ['사용감 조금', '사용한 흔적이 조금 있어요'],
    ['사용감 보통', '사용한 흔적이 꽤 있어요'],
    ['사용감 많음', '사용한 흔적이 많거나 일부 손상된 부분이 있어요.'],
  ];



  void _next() {
    context.push('/market/${widget.teamCode}/upload/step3');
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary50,
      body: SafeArea(
        child: Column(
          children: [
            // ── 헤더: 뒤로가기 + 진행 점(2/3)
            Container(
              height: 56,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).pop(),
                    child: SvgPicture.asset(
                      'assets/icons/back_but.svg',
                      height: 18,
                      colorFilter: const ColorFilter.mode(Color(0xFF9A9A9A), BlendMode.srcIn),
                    ),
                  ),
                ],
              ),
            ),

            const _ProgressDots(activeIndex: 1, total: 3),
            const SizedBox(height: 24),

            // ── 본문
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 타이틀
                    const Text(
                      '상품 가격과 상태를 입력해 주세요.',
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

                    // 판매 가격 + 가격 조정 가능
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const _FieldLabel('판매 가격'),
                        const Spacer(),
                        Row(
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: Transform.scale(
                                scale: 0.9, // 내부 체크 표시 비율 보정 (0.9~0.92 추천)
                                child: Checkbox(
                                  value: _isNegotiable,
                                  onChanged: (v) => setState(() => _isNegotiable = v ?? false),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.5)),
                                  side: const BorderSide(color: AppColors.primary500, width: 1.4),
                                  activeColor: AppColors.primary700,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact, // 클릭 영역 여백 줄이기
                                ),
                              ),
                            ),

                            const SizedBox(width: 7),
                            const Text(
                              '가격 조정 가능',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.gray700,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Pretendard',
                                letterSpacing: -0.14
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

// ── 입력칸 (라벨/체크 아래에 단독으로)
                    _FigmaInput(
                      controller: _priceCtrl,
                      hintText: '희망 판매 가격을 입력하세요.',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly, // ✅ 숫자만 허용
                      ],
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 20),

                    // 상품 상태
                    const _FieldLabel('상품 상태'),
                    const SizedBox(height: 12),
                    Column(
                      children: List.generate(conditions.length, (i) {
                        final title = conditions[i][0];
                        final desc = conditions[i][1];
                        final selected = _selectedCondition == title;
                        return _ConditionTile(
                          title: title,
                          desc: desc,
                          selected: selected,
                          onTap: () => setState(() => _selectedCondition = title),
                        );
                      }),
                    ),

                    const SizedBox(height: 8),

                    // 상품 사진
                    const _FieldLabel('상품 사진'),
                    const SizedBox(height: 12),
                    _PhotoRow(
                      images: _images,
                      onAdd: _pickImages,
                      onRemove: (i) => setState(() => _images.removeAt(i)),
                    ),

                    const SizedBox(height: 17),
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
                    backgroundColor: _isFilled ? AppColors.primary700 : AppColors.gray400,
                    disabledBackgroundColor: AppColors.gray300,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(36)),
                    elevation: 0,
                  ),
                  child: const Text(
                    '다음',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Pretendard',
                      color: Colors.white,
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

/// 진행 점(스텝 표시) — Step1과 동일 스타일 사용 가능
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
    this.activeWidth = 36,
    this.dotSize = 15,
    this.spacing = 12,
    this.activeColor = AppColors.primary700,
    this.inactiveColor = AppColors.primary300,
    this.margin = const EdgeInsets.only(left: 15, top: 5),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Row(
        children: List.generate(total, (i) {
          final active = i == activeIndex;
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

/// 라벨 텍스트
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

/// 피그마식 입력창
class _FigmaInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const _FigmaInput({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.onChanged, required List<TextInputFormatter> inputFormatters,
  });

  List<TextInputFormatter>? get inputFormatters => null;

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: color, width: 0),
  );

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType ?? const TextInputType.numberWithOptions(
          decimal: false, signed: false),
      cursorColor: AppColors.primary700,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: _border(AppColors.gray200),
        enabledBorder: _border(AppColors.gray200),
        focusedBorder: _border(AppColors.gray200),
      ),
    );
  }
}

/// 상태 카드
class _ConditionTile extends StatelessWidget {
  final String title;
  final String desc;
  final bool selected;
  final VoidCallback onTap;

  const _ConditionTile({
    super.key,
    required this.title,
    required this.desc,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final border = selected ? AppColors.primary700 : AppColors.gray600;
    final bg = selected ? AppColors.primary100 : AppColors.gray50;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border, width: 0.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.gray850,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.gray800,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w300,
                      letterSpacing: -0.12,
                      height: 1.16667
                    ),
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

/// 사진 0/4 UI
class _PhotoRow extends StatelessWidget {
  final List<String> images;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;

  const _PhotoRow({
    super.key,
    required this.images,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    // 1) 추가 버튼 (4장 미만일 때만 노출)
    if (images.length < 4) {
      children.add(
        GestureDetector(
          onTap: onAdd,
          child: _thumbBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/camera_icon.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF9A9A9A),
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '(${images.length}/4)',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.gray600,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.12,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 2) 선택된 썸네일들
    for (int i = 0; i < images.length; i++) {
      children.add(
        Stack(
          clipBehavior: Clip.none,
          children: [
            _thumbBox(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(images[i]),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            Positioned(
              right: 5,
              top: 5,
              child: GestureDetector(
                onTap: () => onRemove(i),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color (0xFF6C6C6C),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.close, size: 12, color: AppColors.gray400),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            children[i],
          ],
        ],
      ),
    );
  }

  Widget _thumbBox({Widget? child}) {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        color: AppColors.gray200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: child == null ? const SizedBox.shrink() : child,
    );
  }
}


