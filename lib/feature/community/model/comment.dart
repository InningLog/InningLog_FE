class Comment {
  final int id;
  final String nickName;
  final String? profileUrl;
  final String content;
  final int likeCount;
  final bool likedByMe;
  final bool writeByMe;
  final String? createdAt;
  final List<Comment>? replies;

  const Comment({
    required this.id,
    required this.content,
    required this.nickName,
    this.profileUrl,
    this.likeCount = 0,
    this.likedByMe = false,
    this.writeByMe = false,
    this.createdAt,
    this.replies = const [],
  });
}

const List<Comment> dummyComments = [
  Comment(
    id: 1,
    nickName: '메롱',
    content: '아아',
    createdAt: '10/24(화) 14:10',
    likedByMe: false,
    likeCount: 1,
    replies: [
      Comment(
        id: 1,
        nickName: '메롱',
        content: '아아',
        createdAt: '10/24(화) 14:10',
        likedByMe: false,
        likeCount: 1,
      ),
    ],
  ),
  Comment(
    id: 1,
    nickName: '메롱',
    content: '아아',
    createdAt: '10/24(화) 14:10',
    likedByMe: false,
    likeCount: 1,
  ),
];
