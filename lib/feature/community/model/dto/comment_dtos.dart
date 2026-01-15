import 'package:inninglog/feature/community/model/comment.dart';

class CommentMemberShortResDto {
  final String nickName;
  final String? profileUrl;

  const CommentMemberShortResDto({
    required this.nickName,
    this.profileUrl,
  });

  factory CommentMemberShortResDto.fromJson(Map<String, dynamic> json) {
    return CommentMemberShortResDto(
      nickName: (json['nickName'] ?? '') as String,
      profileUrl: json['profile_url'] as String?,
    );
  }
}

class CommentResDto {
  final int commentId;
  final CommentMemberShortResDto? member;
  final bool writedByMe;
  final String content;
  final String? commentAt;
  final int likeCount;
  final bool likedByMe;
  final bool isDeleted;
  final List<CommentResDto> replies;

  const CommentResDto({
    required this.commentId,
    required this.member,
    required this.writedByMe,
    required this.content,
    required this.commentAt,
    required this.likeCount,
    required this.likedByMe,
    required this.isDeleted,
    required this.replies,
  });

  factory CommentResDto.fromJson(Map<String, dynamic> json) {
    final replies =
        (json['replies'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(CommentResDto.fromJson)
            .toList();
    return CommentResDto(
      commentId: (json['commentId'] ?? 0) as int,
      member:
          json['memberShortResDto'] is Map<String, dynamic>
              ? CommentMemberShortResDto.fromJson(
                json['memberShortResDto'] as Map<String, dynamic>,
              )
              : null,
      writedByMe: json['writedByMe'] == true,
      content: (json['content'] ?? '') as String,
      commentAt: json['commentAt'] as String?,
      likeCount: (json['likeCount'] ?? 0) as int,
      likedByMe: json['likedByMe'] == true,
      isDeleted: json['isDeleted'] == true,
      replies: replies,
    );
  }

  Comment toDomain() {
    return Comment(
      id: commentId,
      nickName: member?.nickName ?? '',
      profileUrl: member?.profileUrl,
      content: content,
      likeCount: likeCount,
      likedByMe: likedByMe,
      createdAt: commentAt,
    );
  }
}

class CreateCommentRequest {
  final int? rootCommentId;
  final String content;

  const CreateCommentRequest({required this.content, this.rootCommentId});

  Map<String, dynamic> toJson() {
    return {'rootCommentId': rootCommentId, 'content': content};
  }
}
