class DiaryItemModel {
  final String journalId;
  final String? thumbImageUrl;
  final String content;
  final String nickName;

  final String? profileUrl;
  final bool writeByMe;
  final int likeCount;
  final bool likedByMe;
  final int scrapCount;
  final bool scrapedByMe;
  final int commentCount;
  final String? createdAt;

  const DiaryItemModel({
    required this.journalId,
    required this.content,
    required this.nickName,
    this.profileUrl,
    this.writeByMe = false,
    this.likeCount = 0,
    this.likedByMe = false,
    this.scrapCount = 0,
    this.scrapedByMe = false,
    this.commentCount = 0,
    this.createdAt,
    this.thumbImageUrl,
  });

  DiaryItemModel copyWith({
    String? journalId,
    String? thumbImageUrl,
    String? content,
    String? nickName,
    String? profileUrl,
    bool? writeByMe,
    int? likeCount,
    bool? likedByMe,
    int? scrapCount,
    bool? scrapedByMe,
    int? commentCount,
    String? createdAt,
  }) {
    return DiaryItemModel(
      journalId: journalId ?? this.journalId,
      content: content ?? this.content,
      nickName: nickName ?? this.nickName,
      profileUrl: profileUrl ?? this.profileUrl,
      writeByMe: writeByMe ?? this.writeByMe,
      likeCount: likeCount ?? this.likeCount,
      likedByMe: likedByMe ?? this.likedByMe,
      scrapCount: scrapCount ?? this.scrapCount,
      scrapedByMe: scrapedByMe ?? this.scrapedByMe,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt ?? this.createdAt,
      thumbImageUrl: thumbImageUrl ?? this.thumbImageUrl,
    );
  }
}
