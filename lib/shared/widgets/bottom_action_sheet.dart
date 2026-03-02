import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:inninglog/shared/theme/app_colors.dart';

class BottomActionSheetAction {
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  final TextStyle? textStyle;

  const BottomActionSheetAction({
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    this.textStyle,
  });
}

Future<T?> showBottomActionSheet<T>(
  BuildContext context, {
  required List<BottomActionSheetAction> actions,
  bool closeOnTap = true,
  double maxWidth = 358,
  double radius = 12,
  double backgroundOpacity = 0.95,
}) async {
  assert(actions.isNotEmpty);
  final selectedIndex = await showModalActionSheet<int>(
    context: context,
    actions: List.generate(actions.length, (index) {
      final action = actions[index];
      return SheetAction<int>(
        key: index,
        label: action.label,
        textStyle:
            action.textStyle ??
            TextStyle(
              color:
                  action.isDestructive
                      ? AppColors.secondary700
                      : AppColors.gray900,
              fontFamily: 'Pretendard',
              fontWeight:
                  action.isDestructive ? FontWeight.w600 : FontWeight.w500,
            ),
        isDestructiveAction: action.isDestructive,
      );
    }),
  );

  if (selectedIndex == null) return null;
  actions[selectedIndex].onTap();
  return null;
}
