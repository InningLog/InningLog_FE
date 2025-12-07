import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:inninglog/shared/theme/app_colors.dart';

class MarketUploadStep3 extends StatefulWidget {
  final String teamCode;
  const MarketUploadStep3({super.key, required this.teamCode});

  @override
  State<MarketUploadStep3> createState() => _MarketUploadStep3State();
}

class _MarketUploadStep3State extends State<MarketUploadStep3> {
  bool _allAgree = false;
  final List<bool> _checked = List<bool>.filled(5, false);

  bool get _isAllChecked => _checked.every((e) => e);

  void _toggleAll(bool? v) {
    final val = v ?? false;
    setState(() {
      _allAgree = val;
      for (var i = 0; i < _checked.length; i++) {
        _checked[i] = val;
      }
    });
  }

  void _toggleOne(int i, bool? v) {
    setState(() {
      _checked[i] = v ?? false;
      _allAgree = _isAllChecked;
    });
  }

  void _submit() {
    // TODO: API 연동
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('상품 등록이 완료되었습니다.')),
    );
    // ✅ 기존 화면들 다 닫고 이닝장터 홈으로 이동
    context.go('/boards/${widget.teamCode}?tab=2'); // ✅ 장터 탭으로 복귀

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary50,
      body: SafeArea(
        child: Column(
          children: [
            // ── 헤더: 뒤로가기 + 진행점(3/3)
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
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF9A9A9A), BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const _ProgressDots(activeIndex: 2, total: 3),
            const SizedBox(height: 24),

            // ── 본문
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '아래 내용에 동의해요.',
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

                    // 전체 동의
                    _AgreeItem(
                      title: '전체 동의',
                      bold: true,
                      value: _allAgree,
                      onChanged: _toggleAll,
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 0.8, color: AppColors.gray600),
                    const SizedBox(height: 12),

                    // 개별 필수 항목
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child:_AgreeItem(
                      value: _checked[0],
                      onChanged: (v) => _toggleOne(0, v),
                      title:
                      '(필수) 이닝장터는 팬 간 개인 거래를 위한 커뮤니티 게시판으로, 거래 과정에서 발생하는 물품 상태·금전적 손실·분쟁에 대해 이닝로그는 어떠한 법적 책임도 지지 않습니다.',
                    ),
                ),
                    const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child:_AgreeItem(
                      value: _checked[1],
                      onChanged: (v) => _toggleOne(1, v),
                      title:
                      '(필수) 판매자는 등록한 상품의 정보(사진, 설명, 가격 등)에 대해 모든 책임을 집니다.',
                    ),
                ),
                    const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child:_AgreeItem(
                      value: _checked[2],
                      onChanged: (v) => _toggleOne(2, v),
                      title:
                      '(필수) 실제 판매 목적이 아닌 홍보, 중개, 대리판매 게시글은 삭제될 수 있습니다.',
                    ),
                ),
                    const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: _AgreeItem(
                      value: _checked[3],
                      onChanged: (v) => _toggleOne(3, v),
                      title:
                      '(필수) 허위정보, 중복 등록, 과도한 가격, 불쾌한 표현이 포함된 글은 사전 통보 없이 숨김 또는 삭제될 수 있습니다.',
                    ),
                ),
                    const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child:  _AgreeItem(
                        value: _checked[4],
                        onChanged: (v) => _toggleOne(4, v),
                        title:
                        '(필수) 게시글 또는 댓글에 전화번호, 계좌번호 등 민감한 정보를 직접 기재하지 마세요.',
                    ),
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
                  onPressed: _isAllChecked ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    _isAllChecked ? AppColors.primary700 : AppColors.gray400,
                    disabledBackgroundColor: AppColors.gray400,
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

/// 18×18 커스텀 체크 + 멀티라인 텍스트
class _AgreeItem extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String title;
  final bool bold;

  const _AgreeItem({
    required this.value,
    required this.onChanged,
    required this.title,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final isAll = bold; // 전체동의용 스타일 분리

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 18px 체크박스
        SizedBox(
          width: 18,
          height: 18,
          child: Transform.scale(
            scale: 0.9, // 기본 20→18 보정
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.5)),
              side: const BorderSide(color: AppColors.primary500, width: 1.4),
              activeColor: AppColors.primary700,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // 멀티라인 텍스트
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: isAll ? 16 : 14,
              color: isAll
                  ? const Color(0xFF272727)
                  : const Color(0xFF272727),
              fontFamily: 'Pretendard',
              fontWeight: isAll ? FontWeight.w700 : FontWeight.w400,
              height: isAll ? 1 : 1.42857,
              letterSpacing: isAll ? -0.16 : -0.14,
            ),
          ),
        ),
      ],
    );
  }
}

/// 진행 점(3/3)
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
