import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inninglog/shared/theme/app_colors.dart';
import 'package:inninglog/shared/theme/app_text_styles.dart';

class EmptyComment extends StatelessWidget {
  const EmptyComment({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary50,
      padding: const EdgeInsets.only(top: 120),
      alignment: Alignment.center,
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/icons/board_bori.svg',
            width: 60,
            height: 60,
          ),
          const SizedBox(height: 24),
          Text(
            '첫 번째 댓글을 남겨주세요!',
            style: AppTextStyles.bodyBody1Rg.copyWith(color: AppColors.gray600),
          ),
        ],
      ),
    );
  }
}
