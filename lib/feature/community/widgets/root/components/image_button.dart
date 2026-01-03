import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ImageButton extends StatelessWidget {
  final String imagePath;
  final double borderRadius;
  final VoidCallback? onTap;

  const ImageButton({
    super.key,
    required this.imagePath,
    this.borderRadius = 12,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSvg = imagePath.toLowerCase().endsWith('.svg');

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          child: isSvg
              ? SvgPicture.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                )
              : Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
        ),
      ),
    );
  }
}
