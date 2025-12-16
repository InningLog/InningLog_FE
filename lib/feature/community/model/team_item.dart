import 'package:flutter/foundation.dart';

@immutable
class TeamItem {
  final String code;
  final String label; // 버튼 위에 얹을 텍스트(이모지 포함)
  final String imagePath; // 배경 이미지

  const TeamItem({
    required this.code,
    required this.label,
    required this.imagePath,
  });
}
