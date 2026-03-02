class PostBase {
  final int postId;
  final String teamShortCode;
  final String title;
  final String content;
  final int likeCount;
  final bool likedByMe;
  final int scrapCount;
  final bool scrapedByMe;
  final int commentCount;
  final String? thumbImageUrl;
  final int imageCount;
  final String? postAt;

  const PostBase({
    required this.postId,
    required this.teamShortCode,
    required this.title,
    required this.content,
    this.likeCount = 0,
    this.likedByMe = false,
    this.scrapCount = 0,
    this.scrapedByMe = false,
    this.commentCount = 0,
    this.thumbImageUrl,
    this.imageCount = 0,
    this.postAt,
  });

  factory PostBase.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;
    bool asBool(dynamic v) {
      if (v is bool) return v;
      if (v is num) return v != 0;
      final s = v?.toString().toLowerCase();
      return s == 'true';
    }
    String? asStringOpt(dynamic v) {
      if (v == null) return null;
      final s = v.toString();
      return s.isEmpty ? null : s;
    }

    return PostBase(
      postId: asInt(json['postId']),
      teamShortCode: asStringOpt(json['teamShortCode']) ?? 'ALL',
      title: asStringOpt(json['title']) ?? '',
      content: asStringOpt(json['content']) ?? '',
      likeCount: asInt(json['likeCount']),
      likedByMe: asBool(json['likedByMe']),
      scrapCount: asInt(json['scrapCount']),
      scrapedByMe: asBool(json['scrapedByMe']),
      commentCount: asInt(json['commentCount']),
      thumbImageUrl: asStringOpt(json['thumbImageUrl']),
      imageCount: asInt(json['imageCount']),
      postAt: asStringOpt(json['postAt']),
    );
  }
}
