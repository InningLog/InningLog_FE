import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../shared/amplitude/AmplitudeFlutter.dart';
import '../../../shared/theme/app_colors.dart';

class EmotionIcon extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final bool isEditMode;
  final ValueChanged<int> onSelected;

  const EmotionIcon({
    super.key,
    required this.index,
    required this.selectedIndex,
    required this.isEditMode,
    required this.onSelected,
  });

  static const labels = ['짜릿함', '감동', '흡족', '답답함', '아쉬움', '분노'];
  static const emojis = [
    'assets/icons/emotion_thrilled.svg',
    'assets/icons/emotion_touched.svg',
    'assets/icons/emotion_satisfied.svg',
    'assets/icons/emotion_suffocated.svg',
    'assets/icons/emotion_ohmy.svg',
    'assets/icons/emtion_angry.svg',
  ];

  @override
  Widget build(BuildContext context) {
    final bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        if (isEditMode) return;

        onSelected(index); // ✅ 상태 변경은 부모가 setState로 처리

        AmplitudeFlutter.getInstance().logEvent(
          'select_diary_emotion',
          eventProperties: {
            'event_type': 'Custom',
            'component': 'btn_click',
            'emotion': labels[index],
          },
        );
      },
      child: Container(
        width: 112,
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFB0B4A4) : const Color(0xFFDEDFE0),
          ),
          color: isSelected ? AppColors.primary200 : AppColors.gray100,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(emojis[index], width: 40, height: 40),
            const SizedBox(height: 4),
            Text(
              labels[index],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'Pretendard',
              ),
            ),
          ],
        ),
      ),
    );
  }
}