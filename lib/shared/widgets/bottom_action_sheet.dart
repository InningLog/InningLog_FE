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
}) {
  assert(actions.isNotEmpty);
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder:
        (_) => BottomActionSheet(
          actions: actions,
          closeOnTap: closeOnTap,
          maxWidth: maxWidth,
          radius: radius,
          backgroundOpacity: backgroundOpacity,
        ),
  );
}

class BottomActionSheet extends StatelessWidget {
  final List<BottomActionSheetAction> actions;
  final bool closeOnTap;
  final double maxWidth;
  final double radius;
  final double backgroundOpacity;

  const BottomActionSheet({
    super.key,
    required this.actions,
    this.closeOnTap = true,
    this.maxWidth = 358,
    this.radius = 12,
    this.backgroundOpacity = 0.95,
  });

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
      child: Align(
        alignment: AlignmentGeometry.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(actions.length, (index) {
                final action = actions[index];
                final background = Colors.white.withOpacity(backgroundOpacity);
                final textStyle =
                    action.textStyle ??
                    TextStyle(
                      color:
                          action.isDestructive
                              ? AppColors.secondary700
                              : AppColors.gray800,
                      fontSize: 20,
                      fontFamily: 'Pretendard',
                      fontWeight:
                          action.isDestructive
                              ? FontWeight.w600
                              : FontWeight.w400,
                      height: 1,
                      letterSpacing: -0.2,
                    );

                return Material(
                  color: background,
                  child: InkWell(
                    onTap: () {
                      if (closeOnTap) {
                        Navigator.of(context).pop();
                      }
                      action.onTap();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        border:
                            index == 0
                                ? null
                                : const Border(
                                  top: BorderSide(
                                    width: 0.5,
                                    color: AppColors.gray300,
                                  ),
                                ),
                      ),
                      alignment: Alignment.center,
                      child: Text(action.label, style: textStyle),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
