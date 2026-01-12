import 'package:flutter/material.dart';
import 'package:inninglog/shared/theme/app_colors.dart';
import 'package:inninglog/shared/theme/app_text_styles.dart';

class PostTitle extends StatelessWidget {
  final String text;
  final int maxLines;
  final bool isPreview;

  const PostTitle({
    required this.text,
    this.maxLines = 1,
    this.isPreview = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final titleTextStyle =
        isPreview ? AppTextStyles.headHead6B : AppTextStyles.headHead4B;

    return _PostText(
      text,
      maxLines: maxLines,
      style: titleTextStyle.copyWith(color: AppColors.gray900),
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
    final bodyTextStyle =
        isPreview ? AppTextStyles.bodyBody2M : AppTextStyles.bodyBody1Rg;
    return _PostText(
      text,
      maxLines: isPreview ? 1 : null,
      style: bodyTextStyle.copyWith(color: AppColors.gray900),
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
