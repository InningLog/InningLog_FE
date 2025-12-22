class CommunityPost {
  final int id;
  final String teamCode; // ALL, LG, ...
  final String title;
  final String content;
  final String? authorNickname;
  final int? likeCount;
  final int? commentCount;
  final DateTime? createdAt;

  CommunityPost({
    required this.id,
    required this.teamCode,
    required this.title,
    required this.content,
    this.authorNickname,
    this.likeCount,
    this.commentCount,
    this.createdAt,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;
    String asString(dynamic v) => (v ?? '').toString();

    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    return CommunityPost(
      id: asInt(json['postId'] ?? json['id']),
      teamCode: asString(
        json['teamCode'] ?? json['boardCode'] ?? json['team_code'],
      ),
      title: asString(json['title']),
      content: asString(json['content'] ?? json['body']),
      authorNickname:
          (json['authorNickname'] ?? json['nickname'] ?? json['writerNickname'])
              ?.toString(),
      likeCount:
          (json['likeCount'] ?? json['like_count']) == null
              ? null
              : asInt(json['likeCount'] ?? json['like_count']),
      commentCount:
          (json['commentCount'] ?? json['comment_count']) == null
              ? null
              : asInt(json['commentCount'] ?? json['comment_count']),
      createdAt: parseDate(json['createdAt'] ?? json['created_at']),
    );
  }
}
