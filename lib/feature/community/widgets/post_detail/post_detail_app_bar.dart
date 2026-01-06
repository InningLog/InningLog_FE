import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inninglog/feature/community/widgets/shared/board_header_bar.dart';

class PostDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String teamLabel;

  /// 상단 첫 줄 타이틀 (기본: 자유 게시판)
  final String boardTitle;

  /// 뒤로가기 탭
  final VoidCallback? onBack;

  /// 우측 더보기 탭
  final VoidCallback? onTapMore;

  /// 아이콘 에셋 경로 (프로젝트 기본값 유지)
  final String backIconAsset;
  final String moreIconAsset;

  /// 우측 액션 노출 여부
  final bool showMore;

  const PostDetailAppBar({
    super.key,
    required this.teamLabel,
    this.boardTitle = '자유 게시판',
    this.onBack,
    this.onTapMore,
    this.backIconAsset = 'assets/icons/back_but.svg',
    this.moreIconAsset = 'assets/icons/board_dots.svg',
    this.showMore = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return BoardHeaderBar(
      title: boardTitle,
      subtitle: teamLabel,
      leadingIconAsset: backIconAsset,
      onTapLeading: onBack ?? () => Navigator.pop(context),
      trailing:
          showMore
              ? IconButton(
                icon: SvgPicture.asset(moreIconAsset, width: 18),
                onPressed: onTapMore ?? () {},
              )
              : null,
      backgroundColor: Colors.white,
      // height: 72,
    );
  }
}
