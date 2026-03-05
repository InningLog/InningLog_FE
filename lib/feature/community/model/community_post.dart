class ImageItem {
  final int imageId;
  final int sequence;
  final String url;

  const ImageItem({
    required this.imageId,
    required this.sequence,
    required this.url,
  });

  factory ImageItem.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;
    String asString(dynamic v) => (v ?? '').toString();

    return ImageItem(
      imageId: asInt(json['imageId']),
      sequence: asInt(json['sequence']),
      url: asString(json['url']),
    );
  }
}

class CommunityPostItem {
  final int id;
  final String teamCode; // ALL, LG, ...
  final String title;
  final String content;
  final String? nickName;
  final String? profileUrl;
  final bool writeByMe;
  final int likeCount;
  final bool likedByMe;
  final int scrapCount;
  final bool scrapedByMe;
  final int commentCount;
  final String? createdAt;
  final bool isEdit;
  final List<ImageItem> images;
  final int? imageCount;
  final String? thumbImageUrl;

  const CommunityPostItem({
    required this.id,
    required this.teamCode,
    required this.title,
    required this.content,
    this.nickName,
    this.profileUrl,
    this.writeByMe = false,
    this.likeCount = 0,
    this.likedByMe = false,
    this.scrapCount = 0,
    this.scrapedByMe = false,
    this.commentCount = 0,
    this.createdAt,
    this.isEdit = false,
    this.images = const [],
    this.imageCount = 0,
    this.thumbImageUrl,
  });

  CommunityPostItem copyWith({
    int? id,
    String? teamCode,
    String? title,
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
    bool? isEdit,
    List<ImageItem>? images,
    int? imageCount,
    String? thumbImageUrl,
  }) {
    return CommunityPostItem(
      id: id ?? this.id,
      teamCode: teamCode ?? this.teamCode,
      title: title ?? this.title,
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
      isEdit: isEdit ?? this.isEdit,
      images: images ?? this.images,
      imageCount: imageCount ?? this.imageCount,
      thumbImageUrl: thumbImageUrl ?? this.thumbImageUrl,
    );
  }
}
