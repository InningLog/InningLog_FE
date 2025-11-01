import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inninglog/app_colors.dart';

class CommunitySearchMarket extends StatefulWidget {
  const CommunitySearchMarket({super.key});

  @override
  State<CommunitySearchMarket> createState() => _CommunitySearchMarketState();
}

class _CommunitySearchMarketState extends State<CommunitySearchMarket> {
  static const _prefsKey = 'community_search_history';
  static const _hint = '원하는 상품을 검색해 보세요!';
  static const _maxLength = 17; // 실제 글자 수
  static const _maxHistory = 15;

  final _ctrl = TextEditingController();
  final _focus = FocusNode();

  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focus.requestFocus(); // ✅ 자동 키보드 오픈
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_prefsKey) ?? [];
    setState(() => _history = list);
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _history);
  }

  Future<void> _addTerm(String raw) async {
    var term = raw.trim();
    if (term.isEmpty) return;

    // ✅ 공백 포함 17자까지, 초과 시 '...' 포함 20자 제한
    if (term.length > _maxLength) {
      term = term.substring(0, _maxLength) + '...';
    }

    setState(() {
      _history.removeWhere((e) => e == term);
      _history.insert(0, term);
      if (_history.length > _maxHistory) {
        _history = _history.sublist(0, _maxHistory);
      }
    });
    await _saveHistory();

    _ctrl.clear();

    // TODO: 실제 검색 실행 (검색 결과 페이지 이동)
  }

  Future<void> _removeTerm(String term) async {
    setState(() => _history.remove(term));
    await _saveHistory();
  }

  Future<void> _clearAll() async {
    setState(() => _history.clear());
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary50,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 검색 바
            _SearchAppBar(
              controller: _ctrl,
              focusNode: _focus,
              onSubmit: _addTerm,
              onBack: () => Navigator.pop(context),
              onClear: () => _ctrl.clear(),
            ),

            // 본문
            Expanded(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    // 상단 텍스트 + 전체삭제
                    Row(
                      children: [
                        const Text(
                          '최근 검색어',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF272727),
                            letterSpacing: -0.16,
                          ),
                        ),
                        const Spacer(),
                        if (_history.isNotEmpty)
                          TextButton(
                            onPressed: _clearAll,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              foregroundColor: AppColors.gray700,
                              textStyle: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.15,
                              ),
                            ),
                            child: const Text('전체삭제'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    if (_history.isEmpty)
                      Expanded(
                        child: Center(
                          child: Text(
                            '최근 검색어가 없습니다.',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: AppColors.gray600,
                              letterSpacing: -0.16,
                            ),
                          ),
                        ),
                      )
                    else
                    // ✅ 358×127 영역 (Wrap 안에서 자동 줄바꿈)
                      SizedBox(
                        width: 358,
                        height: 127,
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _history
                                .map(
                                  (t) => _HistoryChip(
                                label: t,
                                onTap: () => _addTerm(t),
                                onDelete: () => _removeTerm(t),
                              ),
                            )
                                .toList(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 상단: 뒤로가기 + 둥근 검색창
class _SearchAppBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String) onSubmit;
  final VoidCallback onBack;
  final VoidCallback onClear;

  const _SearchAppBar({
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
    required this.onBack,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary50,
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            splashRadius: 22,
            icon: SvgPicture.asset(
              'assets/icons/back_but.svg',
              width: 11,
            ),
          ),
          const SizedBox(width: 0),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.gray200,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  const SizedBox(width: 4),
                  SvgPicture.asset(
                    'assets/icons/search_search.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      AppColors.gray600,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      cursorColor: AppColors.primary700,
                      controller: controller,
                      focusNode: focusNode,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      keyboardType: TextInputType.text,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(20),
                      ],
                      decoration: const InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: _CommunitySearchMarketState._hint,
                        hintStyle: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColors.gray600,
                          letterSpacing: -0.16,
                        ),
                      ),
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF272727),
                        letterSpacing: -0.16,
                      ),
                      onSubmitted: onSubmit,
                    ),
                  ),
                  // ValueListenableBuilder<TextEditingValue>(
                  //   valueListenable: controller,
                  //   builder: (_, value, __) {
                  //     if (value.text.isEmpty) return const SizedBox(width: 4);
                  //     return IconButton(
                  //       splashRadius: 18,
                  //       padding: EdgeInsets.zero,
                  //       constraints: const BoxConstraints(),
                  //       onPressed: onClear,
                  //       icon: const Icon(Icons.close, size: 18, color: Color(0xFF9A9A9A)),
                  //     );
                  //   },
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 칩 (검색어)
class _HistoryChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _HistoryChip({
    required this.label,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        padding: const EdgeInsets.only(left: 12, right: 12),
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.primary50,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: AppColors.gray400, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 210),
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF4E4E4E),
                  letterSpacing: -0.14,
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkResponse(
              onTap: onDelete,
              radius: 16,
              child: SvgPicture.asset(
                'assets/icons/search_cancel.svg',
                width: 16,
                height: 16,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF9A9A9A),
                  BlendMode.srcIn,
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
