import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:inninglog/router/app_routes.dart';
import '../../feature/community/screens/alarm_page.dart';

class CommonHeader extends StatelessWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onAlarmPressed;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onBackPressed;

  const CommonHeader({
    super.key,
    required this.title,
    this.onAlarmPressed,
    this.onSearchPressed,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      alignment: Alignment.center,
      child: Row(
        children: [
          if (showBackButton) ...[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onBackPressed ?? () => context.pop(),
              child: SvgPicture.asset(
                'assets/icons/back_but.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF9A9A9A),
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Text(
            title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.26,
              color: Color(0xFF272727),
              fontFamily: 'MBC1961GulimOTF',
              textBaseline: TextBaseline.alphabetic,
            ),
          ),
          const Spacer(),

          // 검색 버튼 (있을 때만)
          if (onSearchPressed != null) ...[
            IconButton(
              icon: SvgPicture.asset(
                'assets/icons/search.svg', // 🔍 아이콘 파일명에 맞춰 수정
                width: 33,
                height: 33,
              ),
              onPressed:
                  onSearchPressed ?? () => context.push(AppRoutePaths.search),
            ),
            const SizedBox(width: 0), // Figma 느낌 간격
          ],

          IconButton(
            icon: SvgPicture.asset('assets/icons/Alarm.svg', width: 19),
            onPressed:
                onAlarmPressed ??
                () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const AlarmPage()));
                },
          ),
        ],
      ),
    );
  }
}
