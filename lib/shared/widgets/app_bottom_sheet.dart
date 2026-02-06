import 'package:flutter/material.dart';

Future<T?> showAppBottomSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool useRootNavigator = true,
  bool isScrollControlled = true,
  bool useSafeArea = false,
  Color backgroundColor = Colors.transparent,
  bool enableDrag = true,
  bool isDismissible = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    builder: builder,
    backgroundColor: backgroundColor,
    isScrollControlled: isScrollControlled,
    useSafeArea: useSafeArea,
    useRootNavigator: useRootNavigator,
    enableDrag: enableDrag,
    isDismissible: isDismissible,
  );
}

class AppBottomSheetContainer extends StatelessWidget {
  final Widget child;
  final double? height;
  final Color backgroundColor;
  final BorderRadiusGeometry borderRadius;
  final List<BoxShadow> boxShadow;
  final bool safeAreaTop;
  final bool safeAreaBottom;

  const AppBottomSheetContainer({
    super.key,
    required this.child,
    this.height,
    this.backgroundColor = Colors.white,
    this.borderRadius = const BorderRadius.vertical(top: Radius.circular(20)),
    this.boxShadow = const [
      BoxShadow(color: Color(0x40000000), blurRadius: 4, offset: Offset(0, 4)),
    ],
    this.safeAreaTop = false,
    this.safeAreaBottom = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = child;
    if (safeAreaTop || safeAreaBottom) {
      content = SafeArea(
        top: safeAreaTop,
        bottom: safeAreaBottom,
        child: content,
      );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
          boxShadow: boxShadow,
        ),
        child: content,
      ),
    );
  }
}
