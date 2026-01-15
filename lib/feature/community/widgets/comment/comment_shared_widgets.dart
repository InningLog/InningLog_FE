import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inninglog/shared/theme/app_colors.dart';

class CommentIconButtonBox extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const CommentIconButtonBox({
    super.key,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),

      child: SizedBox(width: 34, height: 24, child: Center(child: child)),
    );
  }
}

class CommentVBar extends StatelessWidget {
  const CommentVBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 10, color: AppColors.gray400);
  }
}

class CommentReplyButton extends StatelessWidget {
  final VoidCallback onTap;

  const CommentReplyButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return CommentIconButtonBox(
      onTap: onTap,
      child: SvgPicture.asset(
        'assets/icons/board_comment.svg',
        width: 14,
        height: 12,
        colorFilter: const ColorFilter.mode(AppColors.gray400, BlendMode.srcIn),
      ),
    );
  }
}

class CommentLikeButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const CommentLikeButton({
    super.key,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CommentIconButtonBox(
      onTap: onTap,
      child: SvgPicture.asset(
        'assets/icons/board_heart.svg',
        width: 14,
        height: 12,
        colorFilter: ColorFilter.mode(
          isActive ? AppColors.primary700 : AppColors.gray400,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

class CommentMoreButton extends StatelessWidget {
  final VoidCallback onTap;

  const CommentMoreButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return CommentIconButtonBox(
      onTap: onTap,
      child: const Icon(Icons.more_vert, size: 14, color: AppColors.gray400),
    );
  }
}
