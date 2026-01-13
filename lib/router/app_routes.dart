import 'package:flutter/foundation.dart';

@immutable
final class AppRoutePaths {
  const AppRoutePaths._();

  // 팀 게시판 루트 (/boards/:code)
  static const board = '/boards/:code';
  // 팀 게시판 내 글쓰기 (ShellRoute 하위 상대 경로)
  static const boardPostWrite = 'post/new';
  // 게시판 상세 포스트 (중첩 라우터에서 상대 경로)
  static const boardPostDetail = 'posts/:postId';
  // 팀 게시판 내 글쓰기 (절대 경로)
  static const boardPostWriteAbs = '/boards/:code/post/new';
  // 게시판 상세 포스트 (절대 경로)
  static const boardPostDetailAbs = '/boards/:code/posts/:postId';
  // 커뮤니티 검색
  static const search = '/search';

  static String boardLocation(String code, {String? tab}) {
    final tabQuery = '?tab=${tab ?? 'onlywan'}';
    return '/boards/$code$tabQuery';
  }

  // 절대 경로: 팀 게시판 글쓰기
  static String boardPostWriteLocation(String code) => '/boards/$code/post/new';
  // 절대 경로: 팀 게시판 게시글 상세
  static String boardPostDetailLocation(String code, int postId) =>
      '/boards/$code/posts/$postId';
}

@immutable
final class AppRouteNames {
  const AppRouteNames._();

  static const writingPost = 'writing_post';
  static const postDetail = 'post_detail';
}
