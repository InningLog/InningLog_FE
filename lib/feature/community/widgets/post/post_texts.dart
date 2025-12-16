import 'package:flutter/material.dart';
import 'package:inninglog/shared/theme/app_colors.dart';

class PostTitle extends StatelessWidget {
  final String text;
  final int maxLines;

  const PostTitle({required this.text, this.maxLines = 1, super.key});

  @override
  Widget build(BuildContext context) {
    return _PostText(
      text,
      maxLines: maxLines,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        fontFamily: 'Pretendard',
        color: AppColors.gray850,
        letterSpacing: -0.15,
      ),
    );
  }
}

class PostDateTimeText extends StatelessWidget {
  final String text;

  const PostDateTimeText({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        fontFamily: 'Pretendard',
        color: AppColors.gray700,
        letterSpacing: -0.1,
      ),
    );
  }
}

class PostBody extends StatelessWidget {
  final String text;
  final bool isPreview;

  const PostBody({required this.text, this.isPreview = false, super.key});

  @override
  Widget build(BuildContext context) {
    return _PostText(
      text,
      maxLines: isPreview ? 1 : null,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        fontFamily: 'Pretendard',
        color: AppColors.gray900,
        letterSpacing: -0.12,
        height: 1.5,
      ),
    );
  }
}

// 공통 규칙(ellipsis, maxLines)만 묶어서 private로
class _PostText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final int? maxLines;

  const _PostText(this.text, {required this.style, required this.maxLines});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: maxLines == null ? TextOverflow.visible : TextOverflow.ellipsis,
      style: style,
    );
  }
}
