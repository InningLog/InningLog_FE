import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:inninglog/shared/theme/app_colors.dart';
import 'package:inninglog/shared/theme/app_text_styles.dart';

Future<T?> showNewsAiSummaryBottomSheet<T>(BuildContext context) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: false,
    enableDrag: true,
    isDismissible: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.gray900.withValues(alpha: 0.75),
    builder: (_) => const _NewsAiSummaryBottomSheet(),
  );
}

class _NewsAiSummaryBottomSheet extends StatelessWidget {
  const _NewsAiSummaryBottomSheet();

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final bottomSpacing = math.max(20.0, bottomInset + 8);

    return SafeArea(
      top: false,
      bottom: false,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(20, 14, 20, bottomSpacing),
        decoration: const BoxDecoration(
          color: AppColors.primary50,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 43,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.gray500,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'AI로 기사를 요약했어요',
              style: AppTextStyles.bodyBody1Sb.copyWith(
                color: AppColors.gray900,
              ),
            ),
            const SizedBox(height: 16),
            _bulletText('응원팀과 관련된 주요 소식을 요약했어요.'),
            const SizedBox(height: 2),
            _bulletText('전체 맥락을 이해하기 위해선 원문 보기를 권장해요.'),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(36),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                child: Text(
                  '확인했어요',
                  style: AppTextStyles.headHead6B.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bulletText(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '•',
          style: AppTextStyles.bodyBody2M.copyWith(
            color: AppColors.gray850,
            height: 24 / 14,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyBody2M.copyWith(
              color: AppColors.gray850,
              height: 24 / 14,
            ),
          ),
        ),
      ],
    );
  }
}
