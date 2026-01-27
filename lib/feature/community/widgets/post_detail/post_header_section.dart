import 'package:flutter/material.dart';
import 'package:inninglog/feature/community/widgets/post/post_texts.dart';
import 'package:inninglog/feature/community/widgets/post_detail/post_image_gallery.dart';
import 'package:inninglog/shared/theme/app_colors.dart';
import 'package:inninglog/shared/theme/app_text_styles.dart';
import 'package:inninglog/shared/utils/date_time_utils.dart';

class PostSection extends StatelessWidget {
  // 작성자/메타
  final String nickName;
  final String createAt;

  // 컨텐츠
  final String title;
  final String content;

  /// (선택) 프로필 이미지 위젯을 주입받고 싶을 때
  /// - 안 주면 기본 원형 플레이스홀더가 노출됨
  final String? profileUrl;

  final List<String> imageUrls;

  const PostSection({
    super.key,
    required this.nickName,
    required this.createAt,
    required this.title,
    required this.content,
    this.imageUrls = const [],
    this.profileUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary50,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          PostAuthorRow(
            createAt: createAt,
            nickName: nickName,
            profileUrl: profileUrl,
          ),
          PostTitle(text: title),
          PostBody(text: content),
          if (imageUrls.isNotEmpty) PostImageGallery(imageUrls: imageUrls),
        ],
      ),
    );
  }
}

class PostAuthorRow extends StatelessWidget {
  final String nickName;
  final String createAt;
  final String? profileUrl;

  const PostAuthorRow({
    super.key,
    required this.nickName,
    required this.createAt,
    this.profileUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.gray200,
          backgroundImage:
              (profileUrl != null && profileUrl!.isNotEmpty)
                  ? NetworkImage(profileUrl!)
                  : null,
        ),
        Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nickName,
              style: AppTextStyles.headHead7Sb.copyWith(
                color: AppColors.gray800,
              ),
            ),
            Text(
              DateTimeUtils.formatToKoreanDateTimeShort(createAt),
              style: AppTextStyles.headHead8M.copyWith(
                color: AppColors.gray700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
