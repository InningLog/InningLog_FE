import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:inninglog/shared/theme/app_colors.dart';

// =====================================================
// 진입점: 회원 탈퇴 버튼에서 호출
// 사용법: WithdrawalFlow.start(context)
// =====================================================
class WithdrawalFlow {
  static void start(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => const _WithdrawalStep1Page()),
    );
  }
}

// =====================================================
// 공통 AppBar
// =====================================================
AppBar _buildAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    automaticallyImplyLeading: false,
    title: const Text(
      '회원 탈퇴',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.gray900,
        fontFamily: 'Pretendard',
        letterSpacing: -0.2,
      ),
    ),
    centerTitle: true,
    actions: [
      IconButton(
        icon: SvgPicture.asset('assets/images/cancel_but.svg', width: 45, height: 37),
        onPressed: () => Navigator.of(context).pop(),
      ),
    ],
    systemOverlayStyle: SystemUiOverlayStyle.dark,
  );
}

// =====================================================
// 공통 하단 버튼
// =====================================================
class _BottomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  const _BottomButton({
    required this.label,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          18, 12, 18, MediaQuery.of(context).padding.bottom + 16),
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 52,
          decoration: BoxDecoration(
            color: enabled ? AppColors.primary700 : AppColors.gray200,
            borderRadius: BorderRadius.circular(36),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontFamily: 'Pretendard',
              letterSpacing: -0.16,
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================
// STEP 1: 탈퇴 재확인 (전체 화면)
// =====================================================
class _WithdrawalStep1Page extends StatelessWidget {
  const _WithdrawalStep1Page();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/bori_withdrawal.png',
                  width: 116,
                ),
                const SizedBox(height: 45),
                const Text(
                  '정말 떠나시겠어요?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontFamily: 'Pretendard',
                    letterSpacing: -0.22,
                  ),
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 44),
                  child: Text(
                    '탈퇴 시 지금까지 기록한 직관 기록과 데이터가\n모두 삭제되며, 다시 되돌릴 수 없어요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                      height: 1.25,
                      fontFamily: 'Pretendard',
                      letterSpacing: -0.16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _BottomButton(
            label: '이닝로그 탈퇴하기',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const _WithdrawalStep2Page()),
              );
            },
          ),
        ],
      ),
    );
  }
}

// =====================================================
// STEP 2: 탈퇴 사유 선택 (전체 화면, 다중 선택)
// =====================================================
class _WithdrawalStep2Page extends StatefulWidget {
  const _WithdrawalStep2Page();

  @override
  State<_WithdrawalStep2Page> createState() => _WithdrawalStep2PageState();
}

class _WithdrawalStep2PageState extends State<_WithdrawalStep2Page> {
  static const List<String> _reasons = [
    '기능이 복잡하거나 사용하기 어려워요.',
    '오류가 있거나 앱이 불안정해요.',
    '내가 응원하는 팀 관련 콘텐츠가 부족해요.',
    '직관 기록 관련 정보가 기대보다 부족해요.',
    '자주 사용하지 않게 됐어요.',
    '광고가 많거나 거슬려요.',
    '기타(직접 입력)',
  ];

  final Set<int> _selectedIndexes = {};
  final TextEditingController _etcController = TextEditingController();
  final FocusNode _etcFocus = FocusNode();

  bool get _isEtcSelected => _selectedIndexes.contains(_reasons.length - 1);

  bool get _canProceed {
    if (_selectedIndexes.isEmpty) return false;
    if (_isEtcSelected && _etcController.text.trim().length < 2) return false;
    return true;
  }

  @override
  void dispose() {
    _etcController.dispose();
    _etcFocus.dispose();
    super.dispose();
  }

  void _toggleReason(int idx) {
    setState(() {
      if (_selectedIndexes.contains(idx)) {
        _selectedIndexes.remove(idx);
      } else {
        _selectedIndexes.add(idx);
      }
    });
    if (idx == _reasons.length - 1 && _selectedIndexes.contains(idx)) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _etcFocus.requestFocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 24, 18, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '떠나게 된 이유를 알려주세요 😔',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      fontFamily: 'Pretendard',
                      letterSpacing: -0.18,
                    ),
                  ),
                  const SizedBox(height: 9),
                  const Text(
                    '여러 이유를 선택할 수 있어요.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontFamily: 'Pretendard',
                      letterSpacing: -0.13,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ..._reasons.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final label = entry.value;
                    final isSelected = _selectedIndexes.contains(idx);
                    final isEtc = idx == _reasons.length - 1;
                    return Column(
                      children: [
                        _ReasonTile(
                          label: label,
                          isSelected: isSelected,
                          onTap: () => _toggleReason(idx),
                          etcController: isEtc ? _etcController : null,
                          etcFocusNode: isEtc ? _etcFocus : null,
                          onEtcChanged: isEtc ? (_) => setState(() {}) : null,
                        ),
                        const SizedBox(height: 19),
                      ],
                    );
                  }),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _etcController,
            builder: (_, __) => _BottomButton(
              label: '이닝로그 탈퇴하기',
              enabled: _canProceed,
              onTap: _canProceed
                  ? () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const _WithdrawalStep3Page()),
                      );
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReasonTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final TextEditingController? etcController;
  final FocusNode? etcFocusNode;
  final ValueChanged<String>? onEtcChanged;

  const _ReasonTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.etcController,
    this.etcFocusNode,
    this.onEtcChanged,
  });

  bool get _isEtc => etcController != null;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primary50,
          border: Border.all(
            color: isSelected ? AppColors.primary700 : AppColors.gray400,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray800,
                  fontFamily: 'Pretendard',
                  letterSpacing: -0.14,
                ),
              ),
            ),
            if (_isEtc && isSelected) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: SizedBox(
                  height: 114,
                  child: TextField(
                  controller: etcController,
                  focusNode: etcFocusNode,
                  maxLength: 150,
                  maxLines: null,
                  onChanged: onEtcChanged,
                  inputFormatters: [LengthLimitingTextInputFormatter(150)],
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.gray800,
                    fontFamily: 'Pretendard',
                    letterSpacing: -0.14,
                  ),
                  decoration: const InputDecoration(
                    hintText: '사유를 입력해주세요.',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: AppColors.gray500,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      height: 1.28571,
                    ),
                    counterText: '',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


// =====================================================
// STEP 3: 탈퇴 완료 (전체 화면)
// =====================================================
class _WithdrawalStep3Page extends StatelessWidget {
  const _WithdrawalStep3Page();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/bori_withdrawal_bye.png',
                  width: 116,
                ),
                const SizedBox(height: 45),
                const Text(
                  '탈퇴가 완료되었어요',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontFamily: 'Pretendard',
                    letterSpacing: -0.22,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '그동안 함께해주셔서 감사합니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    height: 1.25,
                    fontFamily: 'Pretendard',
                    letterSpacing: -0.16,
                  ),
                ),
              ],
            ),
          ),
          _BottomButton(
            label: '확인',
            onTap: () {
              context.go('/splash');
            },
          ),
        ],
      ),
    );
  }
}
