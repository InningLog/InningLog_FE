import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CommonHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onAlarmPressed;

  const CommonHeader({
    super.key,
    required this.title,
    this.onAlarmPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      child: Row(
        children: [
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
              width: 24,
            ),
            onPressed: onAlarmPressed ?? () {},
          ),
        ],
      ),
    );
  }
}
