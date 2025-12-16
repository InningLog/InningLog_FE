class PostPreview {
  final String title;
  final String preview; // 버튼 위에 얹을 텍스트(이모지 포함)
  final String dateTime;
  final int likeCount;
  final int commentCount;
  final int bookmarkCount; // 배경 이미지

  const PostPreview({
    required this.title,
    required this.preview,
    required this.dateTime,
    required this.likeCount,
    required this.commentCount,
    required this.bookmarkCount,
  });
}
