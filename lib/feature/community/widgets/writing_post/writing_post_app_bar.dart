import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inninglog/shared/theme/app_colors.dart';
import 'package:inninglog/shared/theme/app_text_styles.dart';

class WritingPostAppBar extends StatelessWidget {
  final String teamLabel;
  final VoidCallback onClose;
  final VoidCallback onSubmit;
  final bool isSubmitEnabled;

  const WritingPostAppBar({
    super.key,
    required this.teamLabel,
    required this.onClose,
    required this.onSubmit,
    required this.isSubmitEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      alignment: Alignment.center,
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: SvgPicture.asset(
              'assets/icons/cancel_button.svg',
              width: 15,
              height: 15,
            ),
          ),
          const Spacer(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '글쓰기',
                style: AppTextStyles.headHead4EB.copyWith(
                  color: AppColors.gray900,
                ),
              ),
              Text(
                teamLabel,
                style: AppTextStyles.bodyBody2M.copyWith(
                  color: AppColors.gray700,
                ),
              ),
            ],
          ),
          const Spacer(),
          TextButton(
            onPressed: isSubmitEnabled ? onSubmit : null,
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.disabled)) {
                  return AppColors.gray700;
                }
                return AppColors.primary700;
              }),
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              ),
              textStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
                final isDisabled = states.contains(WidgetState.disabled);
                return AppTextStyles.bodyBody1Rg.copyWith(
                  fontWeight: isDisabled ? FontWeight.w400 : FontWeight.w700,
                );
              }),
              overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
                if (states.contains(WidgetState.disabled)) {
                  return Colors.transparent;
                }
                return null;
              }),
            ),
            child: const Text('등록'),
          ),
        ],
      ),
    );
  }
}
