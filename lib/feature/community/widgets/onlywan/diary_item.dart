import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inninglog/feature/community/model/diary_item.dart';
import 'package:inninglog/feature/community/widgets/post_detail/post_action_button.dart';
import 'package:inninglog/shared/theme/app_colors.dart';
import 'package:inninglog/shared/theme/app_text_styles.dart';

enum FeedImageRatio { ratio3x4, ratio1x1, ratio4x3 }

class DiaryItem extends StatelessWidget {
  final DiaryItemModel item;
  final VoidCallback? onTapMore;
  final VoidCallback? onTap;
  final VoidCallback? onTapLike;
  final VoidCallback? onTapComment;
  final VoidCallback? onTapScrap;

  const DiaryItem({
    super.key,
    required this.item,
    this.onTapMore,
    this.onTap,
    this.onTapLike,
    this.onTapComment,
    this.onTapScrap,
  });

  @override
  Widget build(BuildContext context) {
    // final imageRatio = _ratioValue(ratio3x4);
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Column(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderRow(item: item, onTapMore: onTapMore),
              SizedBox(
                width: 270,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      item.thumbImageUrl == null
                          ? Container(color: const Color(0xFFD9D9D9))
                          : Image.network(
                            item.thumbImageUrl!,
                            fit: BoxFit.cover,
                          ),
                ),
              ),

              Text(
                item.content,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyBody2Rg.copyWith(
                  color: AppColors.gray900,
                ),
              ),
              _ActionRow(
                item: item,
                onTapLike: onTapLike,
                onTapComment: onTapComment,
                onTapScrap: onTapScrap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final DiaryItemModel item;
  final VoidCallback? onTapMore;

  const _HeaderRow({required this.item, this.onTapMore});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 15,
          backgroundColor: AppColors.gray200,
          backgroundImage:
              item.profileUrl != null ? NetworkImage(item.profileUrl!) : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.nickName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.headHead7Sb.copyWith(
                  color: AppColors.gray800,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.createdAt ?? '',
                style: AppTextStyles.headHead8M.copyWith(
                  color: AppColors.gray700,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: onTapMore,
          borderRadius: BorderRadius.circular(13),
          child: SizedBox(
            width: 26,
            height: 26,
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/board_dots.svg',
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(
                  AppColors.gray700,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  final DiaryItemModel item;
  final VoidCallback? onTapLike;
  final VoidCallback? onTapComment;
  final VoidCallback? onTapScrap;

  const _ActionRow({
    required this.item,
    this.onTapLike,
    this.onTapComment,
    this.onTapScrap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PostActionButton(
          asset:
              item.likedByMe
                  ? 'assets/icons/board_heart.svg'
                  : 'assets/icons/green_heart.svg',
          color: item.likedByMe ? AppColors.primary700 : AppColors.gray800,
          label: item.likeCount.toString(),
          onTap: onTapLike,
          iconSize: 14,
          labelStyle: AppTextStyles.bodyBody3M,
        ),
        const SizedBox(width: 20),

        PostActionButton(
          asset: 'assets/icons/green_comment.svg',
          color: AppColors.gray800,
          label: item.commentCount.toString(),
          onTap: onTapComment,
          iconSize: 14,
          labelStyle: AppTextStyles.bodyBody3M,
        ),
        const SizedBox(width: 20),
        PostActionButton(
          asset:
              item.scrapedByMe
                  ? 'assets/icons/board_scrap.svg'
                  : 'assets/icons/green_bookmark.svg',
          color: item.scrapedByMe ? AppColors.primary700 : AppColors.gray800,
          label: item.scrapCount.toString(),
          onTap: onTapScrap,
          iconSize: 14,
          labelStyle: AppTextStyles.bodyBody3M,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _ActionButton({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: child,
      ),
    );
  }
}
