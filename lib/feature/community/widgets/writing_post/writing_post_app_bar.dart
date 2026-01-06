import 'package:flutter/material.dart';
import 'package:inninglog/shared/theme/app_colors.dart';
import 'package:inninglog/shared/theme/app_text_styles.dart';
import 'package:inninglog/feature/community/widgets/shared/board_header_bar.dart';

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
    final submitButton = TextButton(
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
    );

    return BoardHeaderBar(
      title: '글쓰기',
      subtitle: teamLabel,
      leadingIconAsset: 'assets/icons/cancel_button.svg',
      leadingIconSize: const Size(15, 15),
      onTapLeading: onClose,
      trailing: submitButton,
      // height: 72,
    );
  }
}
