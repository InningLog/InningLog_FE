import 'package:flutter/material.dart';
import 'package:inninglog/feature/community/widgets/writing_post/image_thumb.dart';
import 'package:inninglog/shared/widgets/app_icon_button.dart';

class ImageAttachmentBar extends StatelessWidget {
  final List<ImageProvider> images;
  final int maxImages;
  final VoidCallback? onPickImages; // null이면 비활성
  final void Function(int index) onRemoveImageAt;

  const ImageAttachmentBar({
    super.key,
    required this.images,
    required this.maxImages,
    required this.onPickImages,
    required this.onRemoveImageAt,
  });

  static const double height = 72;

  @override
  Widget build(BuildContext context) {
    final canPick = onPickImages != null && images.length < maxImages;

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.white,
      child: Row(
        spacing: 24,
        children: [
          if (canPick)
            //이미지 등록 아이콘 버튼
            AppIconButton(
              asset: 'assets/icons/image-upload.svg',
              onPressed: onPickImages,
              tooltip: '이미지 추가',
            ),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return ImageThumb(
                  image: images[index],
                  onRemove: () => onRemoveImageAt(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
