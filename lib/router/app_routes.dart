import 'package:flutter/foundation.dart';

@immutable
final class AppRoutePaths {
  const AppRoutePaths._();

  static const postWrite = '/post/write'; // GNB 없는 legacy 글쓰기
  static const boardPostWrite = 'post/write'; // /boards/:code 하위 상대경로

  static String boardPostWriteLocation(String code) =>
      '/boards/$code/post/write';
}
