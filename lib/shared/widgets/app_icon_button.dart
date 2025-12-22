import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIconButton extends StatelessWidget {
  final String asset;
  final VoidCallback? onPressed;

  /// 터치 영역 크기 (기본 48x48)
  final double buttonSize;

  /// 아이콘 실제 크기 (기본 24)
  final double iconSize;

  /// svg 틴트용 (png에는 적용되지 않음)
  final Color? iconColor;

  /// 비활성화일 때 투명도
  final double disabledOpacity;

  final String? tooltip;

  const AppIconButton({
    super.key,
    required this.asset,
    required this.onPressed,
    this.buttonSize = 48,
    this.iconSize = 24,
    this.iconColor,
    this.disabledOpacity = 0.4,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(), // 기본 48x48 강제 방지
        splashRadius: buttonSize / 2,
        icon: Opacity(
          opacity: enabled ? 1 : disabledOpacity,
          child: _buildIcon(),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final lower = asset.toLowerCase();
    if (lower.endsWith('.svg')) {
      return SvgPicture.asset(
        asset,
        width: iconSize,
        height: iconSize,
        colorFilter:
            iconColor == null
                ? null
                : ColorFilter.mode(iconColor!, BlendMode.srcIn),
      );
    }

    return Image.asset(
      asset,
      width: iconSize,
      height: iconSize,
      fit: BoxFit.contain,
    );
  }
}
