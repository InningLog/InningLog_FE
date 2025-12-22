import 'package:flutter/material.dart';
import 'package:inninglog/shared/theme/app_colors.dart';

class ImageThumb extends StatelessWidget {
  final ImageProvider image;
  final VoidCallback onRemove;

  const ImageThumb({required this.image, required this.onRemove, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          //사진 썸네일
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: AppColors.gray400,
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(image: image, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          right: 5,
          top: 5,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              //삭제 버튼
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.gray900,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.close, size: 12, color: AppColors.gray400),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
