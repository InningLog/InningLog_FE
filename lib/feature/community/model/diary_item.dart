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
}
