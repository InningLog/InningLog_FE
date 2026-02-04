import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inninglog/shared/theme/app_colors.dart';
import 'package:inninglog/shared/theme/app_text_styles.dart';

/// 공통 게시판 헤더: 좌측 아이콘, 중앙 타이틀/서브타이틀, 우측 액션을 재사용하도록 구성.
class BoardHeaderBar extends StatelessWidget implements PreferredSizeWidget {
  /// 중앙에 표시할 메인 타이틀 텍스트.
  final String title;

  /// 타이틀 하단에 표시할 서브타이틀 텍스트.
  final String subtitle;

  /// 좌측 아이콘의 SVG 에셋 경로.
  final String leadingIconAsset;

  /// 좌측 아이콘 크기.
  final Size leadingIconSize;

  /// 좌측 아이콘 탭 콜백.
  final VoidCallback onTapLeading;

  /// 우측에 배치할 커스텀 위젯(없으면 좌측 폭과 동일한 여백).
  final Widget? trailing;

  /// 헤더 전체 높이.
  final double height;

  /// 좌측 아이콘 영역의 고정 폭.
  final double leadingWidth;

  /// 헤더 배경색.
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
                  style: AppTextStyles.headHead6B.copyWith(
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
