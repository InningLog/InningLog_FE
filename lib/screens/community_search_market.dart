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

    // ✅ 결과 페이지로 이동 (탭 이동 아님)
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchMarketResultPage(keyword: term),
      ),
    );
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
                    child: Shortcuts(
                      shortcuts: <LogicalKeySet, Intent>{
                        LogicalKeySet(LogicalKeyboardKey.enter):
                        const ActivateIntent(),
                        LogicalKeySet(LogicalKeyboardKey.numpadEnter):
                        const ActivateIntent(),
                      },
                      child: Actions(
                        actions: <Type, Action<Intent>>{
                          ActivateIntent: CallbackAction<ActivateIntent>(
                            onInvoke: (_) {
                              onSubmit(controller.text);
                              return null;
                            },
                          ),
                        },
                        child: Focus(
                          autofocus: true,
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
                      ),
                    ),
                  ),
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


// 이닝 장터 전용 커스텀 스위치(네가 만든 것) 가져다 씀
class CustomMarketSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const CustomMarketSwitch({super.key, required this.value, required this.onChanged});
  @override
  State<CustomMarketSwitch> createState() => _CustomMarketSwitchState();
}
class _CustomMarketSwitchState extends State<CustomMarketSwitch> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 35, height: 21,
        padding: const EdgeInsets.symmetric(horizontal: 2.5),
        decoration: BoxDecoration(
          color: widget.value ? const Color(0xFFAFD956) : const Color(0xFF8F8F8F),
          borderRadius: BorderRadius.circular(36.5),
        ),
        alignment: widget.value ? Alignment.centerRight : Alignment.centerLeft,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: 17.8, height: 18.2,
          decoration: BoxDecoration(
            color: AppColors.primary50,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                offset: const Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchMarketResultPage extends StatefulWidget {
  final String keyword;
  const SearchMarketResultPage({super.key, required this.keyword});

  @override
  State<SearchMarketResultPage> createState() => _SearchMarketResultPageState();
}

class _SearchMarketResultPageState extends State<SearchMarketResultPage> {
  late final TextEditingController _ctrl;
  final FocusNode _focus = FocusNode();
  bool showOnSaleOnly = false;

  // 더미 데이터 (API 연동 시 대체)
  final List<Map<String, dynamic>> _posts = const [
    {
      'status': '판매중',
      'title': '제목_공백 포함 최대 40자까지 가능 줄로 따지면 2줄까지 가능합니다',
      'comments': 2, 'bookmarks': 2, 'time': '3분 전', 'onSale': true,
    },
    {
      'status': '판매완료',
      'title': '제목_공백 포함 최대 40자까지 가능 줄로 따지면 2줄까지 가능합니다',
      'comments': 2, 'bookmarks': 2, 'time': '3분 전', 'onSale': false,
    },
    {
      'status': '판매완료',
      'title': '제목_공백 포함 최대 40자까지 가능 줄로 따지면 2줄까지 가능합니다',
      'comments': 2, 'bookmarks': 2, 'time': '3분 전', 'onSale': false,
    },
    {
      'status': '판매중',
      'title': '제목_공백 포함 최대 40자까지 가능 줄로 따지면 2줄까지 가능합니다',
      'comments': 2, 'bookmarks': 2, 'time': '3분 전', 'onSale': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.keyword);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filtered() {
    final q = _ctrl.text.trim();
    final base = _posts.where((p) {
      if (q.isEmpty) return true;
      final title = (p['title'] ?? '').toString();
      return title.contains(q);
    }).toList();
    if (showOnSaleOnly) {
      return base.where((p) => p['onSale'] == true).toList();
    }
    return base;
  }

  @override
  Widget build(BuildContext context) {
    final results = _filtered();

    return Scaffold(
      backgroundColor: AppColors.primary50,
      body: SafeArea(
        child: Column(
          children: [
            // 🔍 상단 검색 바 (좌측 뒤로 + 둥근 검색창)
            Container(
              color: AppColors.primary50,
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    splashRadius: 22,
                    icon: SvgPicture.asset('assets/icons/back_but.svg', width: 11),
                  ),
                  Expanded(
                    child: Container(
                      height: 40,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: AppColors.gray200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 4),
                          SvgPicture.asset(
                            'assets/icons/search_search.svg',
                            width: 24, height: 24,
                            colorFilter: const ColorFilter.mode(AppColors.gray600, BlendMode.srcIn),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _ctrl,
                              focusNode: _focus,
                              cursorColor: AppColors.primary700,
                              textInputAction: TextInputAction.search,
                              onSubmitted: (_) => setState(() {}), // ✅ 재검색
                              decoration: const InputDecoration(
                                isCollapsed: true,
                                border: InputBorder.none,
                                hintText: '원하는 상품을 검색해 보세요!',
                                hintStyle: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 16, fontWeight: FontWeight.w400,
                                  color: AppColors.gray600, letterSpacing: -0.16,
                                ),
                              ),
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 16, fontWeight: FontWeight.w400,
                                color: Color(0xFF272727), letterSpacing: -0.16,
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

            // 🟢 스위치 영역 (판매중만 보기)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Row(
                children: [
                  CustomMarketSwitch(
                    value: showOnSaleOnly,
                    onChanged: (v) => setState(() => showOnSaleOnly = v),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '판매중인 상품만 보기',
                    style: TextStyle(
                      fontSize: 14, color: AppColors.gray800,
                      fontWeight: FontWeight.w400, fontFamily: 'Pretendard', letterSpacing: -0.14,
                    ),
                  ),
                ],
              ),
            ),

            // 리스트
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemBuilder: (_, i) {
                  final p = results[i];
                  return Container(
                    decoration: const BoxDecoration(
                      color: AppColors.primary50,
                      border: Border(
                        bottom: BorderSide(color: AppColors.gray200, width: 1),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Row(
                      children: [
                        // 왼쪽 텍스트
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 상태 배지
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (p['status'] == '판매중')
                                      ? AppColors.primary600
                                      : const Color(0xFFC0C0C0),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  (p['status'] ?? '').toString(),
                                  style: const TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w700,
                                    color: AppColors.primary50, fontFamily: 'Pretendard',
                                    letterSpacing: -0.1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),

                              // 제목
                              Text(
                                (p['title'] ?? '').toString(),
                                maxLines: 2, overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600,
                                  color: AppColors.gray850, fontFamily: 'Pretendard',
                                  letterSpacing: -0.16,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // 하단 메타
                              Row(
                                children: [
                                  SvgPicture.asset('assets/icons/comment.svg', width: 14.4, height: 14.4),
                                  const SizedBox(width: 4),
                                  Text('${p['comments'] ?? 0}',
                                      style: const TextStyle(
                                        fontSize: 12, color: AppColors.gray700,
                                        fontFamily: 'Pretendard', fontWeight: FontWeight.w500, letterSpacing: -0.12,
                                      )),
                                  const SizedBox(width: 11),
                                  SvgPicture.asset('assets/icons/bookmark.svg', width: 14, height: 14),
                                  const SizedBox(width: 4),
                                  Text('${p['bookmarks'] ?? 0}',
                                      style: const TextStyle(
                                        fontSize: 12, color: AppColors.gray700,
                                        fontFamily: 'Pretendard', fontWeight: FontWeight.w500, letterSpacing: -0.12,
                                      )),
                                  const Spacer(),
                                  Text(
                                    (p['time'] ?? '').toString(),
                                    style: const TextStyle(
                                      fontSize: 14, color: AppColors.gray700,
                                      fontFamily: 'Pretendard', fontWeight: FontWeight.w400, letterSpacing: -0.14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),

                        // 썸네일
                        Container(
                          width: 100, height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: results.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}