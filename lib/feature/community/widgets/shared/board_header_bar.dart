import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inninglog/shared/theme/app_colors.dart';
import 'package:inninglog/shared/theme/app_text_styles.dart';

/// 공통 게시판 헤더: 좌측 아이콘, 중앙 타이틀/서브타이틀, 우측 액션을 재사용하도록 구성.
class BoardHeaderBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final String leadingIconAsset;
  final Size leadingIconSize;
  final VoidCallback onTapLeading;
  final Widget? trailing;
  final double height;
  final double leadingWidth;
  final Color backgroundColor;

  const BoardHeaderBar({
    super.key,
    required this.title,
    required this.subtitle,
    required this.leadingIconAsset,
    required this.onTapLeading,
    this.trailing,
    this.leadingIconSize = const Size(10, 20),
    this.height = 64,
    this.leadingWidth = 54,
    this.backgroundColor = Colors.white,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: false,
      child: Container(
        height: height,
        color: backgroundColor,
        child: Row(
          children: [
            SizedBox(
              width: leadingWidth,
              child: IconButton(
                onPressed: onTapLeading,
                icon: SvgPicture.asset(
                  leadingIconAsset,
                  width: leadingIconSize.width,
                  height: leadingIconSize.height,
                ),
              ),
            ),
            const Spacer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTextStyles.headHead4EB.copyWith(
                    color: AppColors.gray900,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.bodyBody2M.copyWith(
                    color: AppColors.gray700,
                  ),
                ),
              ],
            ),
            const Spacer(),
            trailing ?? SizedBox(width: leadingWidth),
          ],
        ),
      ),
    );
  }
}
