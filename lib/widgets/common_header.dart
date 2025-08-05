import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CommonHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onAlarmPressed;
  final Widget? leading;   // 추가!


  const CommonHeader({
    super.key,
    required this.title,
    this.onAlarmPressed,
    this.leading,          // 추가!
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
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/Alarm.svg',
              width: 18.05,
            ),
            onPressed: () {
              Fluttertoast.showToast(
                msg: "아직 개발 중이에요 ㅠ.ㅠ",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.black.withOpacity(0.7),
                textColor: Colors.white,
                fontSize: 14,
              );
            },
          ),
        ],
      ),
    );
  }
}
