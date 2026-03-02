import 'package:flutter/material.dart';
import 'package:inninglog/feature/community/widgets/search/recent_search_chip.dart';
import 'package:inninglog/shared/theme/app_colors.dart';

class RecentSearchSection extends StatelessWidget {
  final List<String> history;
  final ValueChanged<String> onTapTerm;
  final ValueChanged<String> onDeleteTerm;
  final VoidCallback onClearAll;

  const RecentSearchSection({
    super.key,
    required this.history,
    required this.onTapTerm,
    required this.onDeleteTerm,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '최근 검색어',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                  letterSpacing: -0.16,
                ),
              ),
              const Spacer(),
              if (history.isNotEmpty)
                TextButton(
                  onPressed: onClearAll,
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
          Expanded(
            child:
                history.isEmpty
                    ? const Center(
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
                    )
                    : SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            history
                                .map(
                                  (term) => RecentSearchChip(
                                    label: term,
                                    onTap: () => onTapTerm(term),
                                    onDelete: () => onDeleteTerm(term),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
