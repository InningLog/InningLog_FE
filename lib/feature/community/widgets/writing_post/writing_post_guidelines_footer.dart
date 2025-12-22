import 'package:flutter/material.dart';
import 'package:inninglog/shared/theme/app_colors.dart';
import 'package:inninglog/shared/theme/app_text_styles.dart';

class WritingPostGuidelinesFooter extends StatelessWidget {
  const WritingPostGuidelinesFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final p = AppTextStyles.bodyBody3Lg.copyWith(color: AppColors.gray800);

    Widget warning(String t) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [const Text('📝'), Expanded(child: Text(t, style: p))],
    );

    Widget bullet(String t) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '-',
          style: AppTextStyles.bodyBody3Lg.copyWith(color: AppColors.gray800),
        ),
        Expanded(child: Text(t, style: p)),
      ],
    );

    Widget warn(String t) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '⚠️️',
          style: AppTextStyles.bodyBody3Lg.copyWith(color: AppColors.gray800),
        ),
        Expanded(child: Text(t, style: p)),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        warning('게시물 작성 시 유의사항'),
        const SizedBox(height: 2),
        bullet('불법 도박, 음란물, 폭력성·혐오 표현, 개인정보 유출, 특정인 비방 등의 내용은 작성이 제한될 수 있습니다.'),
        const SizedBox(height: 2),
        bullet('위반 시 게시글이 삭제되거나 계정이 제한될 수 있습니다.'),
        const SizedBox(height: 8),
        warn('커뮤니티 이용 규칙을 위반한 게시물은 사전 통보 없이 삭제될 수 있습니다.'),
      ],
    );
  }
}
