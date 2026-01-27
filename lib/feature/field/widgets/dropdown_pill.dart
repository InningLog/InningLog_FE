import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../shared/theme/app_colors.dart';

class DropdownPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isOpen;
  final VoidCallback onTap;

  /// 필요하면 배경색/패딩 같은 것도 외부에서 주입 가능하게 확장할 수 있어
  const DropdownPill({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isOpen = false,
  });

  @override
  Widget build(BuildContext context) {
    // 우선순위: 열림(연두) > 선택됨(검정) > 미선택(회색)
    final Color baseColor = isOpen
        ? AppColors.primary600
        : (isSelected ? const Color(0xFF272727) : AppColors.gray400);

    return IntrinsicWidth(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary50,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: baseColor,
              width: 0.75,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: baseColor,
                  letterSpacing: -0.12,
                  fontFamily: 'Pretendard',
                ),
              ),
              const SizedBox(width: 4),
              SvgPicture.asset(
                isOpen
                    ? 'assets/icons/up_button.svg'
                    : 'assets/icons/filter_down_blackk.svg',
                width: 10,
                height: 10,
                color: baseColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
