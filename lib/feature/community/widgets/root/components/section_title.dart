import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 19,
        fontFamily: 'pretendard',
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    );
  }
}
