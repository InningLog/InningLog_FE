import 'package:flutter/material.dart';

/// 섹션 타이틀
class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 19,
          fontFamily: 'pretendard',
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
    );
  }
}
