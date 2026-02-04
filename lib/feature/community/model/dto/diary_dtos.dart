import 'package:inninglog/feature/community/model/diary_item.dart';

class DiaryFeedResponse {
  final List<DiaryFeedItemDto> content;
  final bool hasNext;
  final int page;
  final int size;

  const DiaryFeedResponse({
    required this.content,
    required this.hasNext,
    required this.page,
    required this.size,
  });

  factory DiaryFeedResponse.fromJson(Map<String, dynamic> json) {
    final body = (json['data'] as Map<String, dynamic>?) ?? json;
    final content =
        (body['content'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(DiaryFeedItemDto.fromJson)
            .toList();

    return DiaryFeedResponse(
      content: content,
      hasNext: body['hasNext'] == true,
      page: (body['page'] ?? 0) as int,
      size: (body['size'] ?? content.length) as int,
    );
  }
}

class DiaryFeedItemDto {
  final String journalId;
  final String? thumbnailUrl;
  final DiaryFeedMemberDto member;
  final bool writedByMe;
  final String reviewPreview;
  final String? createdAt;
  final int likeCount;
  final bool likedByMe;
  final int commentCount;
  final int scrapCount;
  final bool scrapedByMe;

  const DiaryFeedItemDto({
    required this.journalId,
    required this.member,
    required this.writedByMe,
    required this.reviewPreview,
    required this.createdAt,
    required this.likeCount,
    required this.likedByMe,
    required this.commentCount,
    required this.scrapCount,
    required this.scrapedByMe,
    this.thumbnailUrl,
  });

  factory DiaryFeedItemDto.fromJson(Map<String, dynamic> json) {
    return DiaryFeedItemDto(
      journalId: (json['journalId'] ?? '').toString(),
      thumbnailUrl: json['thumbnailUrl'] as String?,
      member: DiaryFeedMemberDto.fromJson(
        (json['member'] as Map<String, dynamic>? ?? const {}),
      ),
      writedByMe: json['writedByMe'] == true,
      reviewPreview: (json['reviewPreview'] ?? '').toString(),
      createdAt: json['createdAt'] as String?,
      likeCount: (json['likeCount'] ?? 0) as int,
      likedByMe: json['likedByMe'] == true,
      commentCount: (json['commentCount'] ?? 0) as int,
      scrapCount: (json['scrapCount'] ?? 0) as int,
      scrapedByMe: json['scrapedByMe'] == true,
    );
  }

  DiaryItemModel toModel() {
    return DiaryItemModel(
      journalId: journalId,
      content: reviewPreview,
      nickName: member.nickName,
      profileUrl: member.profileUrl,
      writeByMe: writedByMe,
      likeCount: likeCount,
      likedByMe: likedByMe,
      scrapCount: scrapCount,
      scrapedByMe: scrapedByMe,
      commentCount: commentCount,
      createdAt: createdAt,
      thumbImageUrl: thumbnailUrl,
    );
  }
}

class DiaryFeedMemberDto {
  final String nickName;
  final String? profileUrl;

  const DiaryFeedMemberDto({required this.nickName, this.profileUrl});

  factory DiaryFeedMemberDto.fromJson(Map<String, dynamic> json) {
    return DiaryFeedMemberDto(
      nickName: (json['nickName'] ?? '').toString(),
      profileUrl: json['profile_url'] as String?,
    );
  }
}
