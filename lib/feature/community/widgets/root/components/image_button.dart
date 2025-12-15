import 'package:flutter/material.dart';

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
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius),
      clipBehavior: Clip.antiAlias,
      child: Ink.image(
        image: AssetImage(imagePath),
        fit: BoxFit.cover,
        child: InkWell(onTap: onTap),
      ),
    );
  }
}
