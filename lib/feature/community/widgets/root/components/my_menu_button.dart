import 'package:flutter/material.dart';
import 'package:inninglog/shared/theme/app_colors.dart';

class MyMenuButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const MyMenuButton({required this.child, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.gray300, width: 0.8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Center(child: child),
      ),
    );
  }
}
