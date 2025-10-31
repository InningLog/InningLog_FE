import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inninglog/screens/community_search_page.dart';

import '../screens/alarm_page.dart';

class CommonHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onAlarmPressed;
  final Widget? leading;   // 추가!

  /// 검색 버튼 (null이면 표시 안 함)
  final VoidCallback? onSearchPressed;


  const CommonHeader({
    super.key,
    required this.title,
    this.onAlarmPressed,
    this.leading,
    this.onSearchPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 9),
      alignment: Alignment.center,
      child: Row(
        children: [
          if (leading != null) leading!,
          if (leading != null) const SizedBox(width: 8),
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
              ),
              onPressed: onSearchPressed ??
                      () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CommunitySearchPage()),
                    );
                  },
              splashRadius: 33,
            ),
            const SizedBox(width:0), // Figma 느낌 간격
          ],

          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/Alarm.svg',
              width: 19,
            ),
            onPressed: onAlarmPressed ??
                    () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AlarmPage()),
                  );
                },
          ),
        ],
      ),
    );
  }
}
