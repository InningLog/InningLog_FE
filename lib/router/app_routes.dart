import 'package:flutter/foundation.dart';

@immutable
final class AppRoutePaths {
  const AppRoutePaths._();

  static const postWrite = '/post/new'; // GNB 없는 legacy 글쓰기
  static const boardPostWrite = 'post/new'; // /boards/:code 하위 상대경로
  static const board = '/boards/:code';
  static const search = '/search';

  static String boardLocation(String code, {int? tab}) {
    final tabQuery = tab != null ? '?tab=$tab' : '';
    return '/boards/$code$tabQuery';
  }

  static String boardPostWriteLocation(String code) => '/boards/$code/post/new';
}
