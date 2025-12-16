import 'package:flutter/material.dart';
import 'package:inninglog/shared/theme/app_colors.dart';

enum MyMenuIconKind { emoji, svg }

class MyMenuAction {
  final String label;
  final VoidCallback onTap;

  final MyMenuIconKind iconKind;

  // emoji용
  final String? emoji;
  final Color? emojiColor;
  final double? emojiSize;

  // svg용
  final String? svgPath;
  final Color? svgColor;
  final double? svgWidth;
  final double? svgHeight;

  const MyMenuAction._({
    required this.label,
    required this.onTap,
    required this.iconKind,
    this.emoji,
    this.emojiColor,
    this.emojiSize,
    this.svgPath,
    this.svgColor,
    this.svgWidth,
    this.svgHeight,
  });

  factory MyMenuAction.emoji({
    required String label,
    required String emoji,
    required VoidCallback onTap,
    Color? emojiColor,
    double emojiSize = 12,
  }) {
    return MyMenuAction._(
      label: label,
      emoji: emoji,
      onTap: onTap,
      iconKind: MyMenuIconKind.emoji,
      emojiColor: emojiColor,
      emojiSize: emojiSize,
    );
  }

  factory MyMenuAction.svg({
    required String label,
    required String svgPath,
    required VoidCallback onTap,
    Color svgColor = AppColors.primary700,
    double width = 12,
    double height = 14,
  }) {
    return MyMenuAction._(
      label: label,
      svgPath: svgPath,
      onTap: onTap,
      iconKind: MyMenuIconKind.svg,
      svgColor: svgColor,
      svgWidth: width,
      svgHeight: height,
    );
  }
}
