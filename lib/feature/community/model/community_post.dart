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

  factory CommunityPostItem.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? json;
    final member = data['member'] as Map<String, dynamic>?;

    int asInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;
    String? asStringOpt(dynamic v) {
      if (v == null) return null;
      final s = v.toString();
      return s.isEmpty ? null : s;
    }

    bool asBool(dynamic v) {
      if (v is bool) return v;
      if (v is num) return v != 0;
      final s = v?.toString().toLowerCase();
      if (s == 'true') return true;
      if (s == 'false') return false;
      return false;
    }

    final images =
        ((data['imageListResDto'] as Map<String, dynamic>?)?['imageResDtos']
            as List<dynamic>?) ??
        const [];

    return CommunityPostItem(
      id: asInt(data['postId']),
      teamCode: asStringOpt(data['teamShortCode'] ?? data['teamCode']) ?? 'ALL',
      title: asStringOpt(data['title']) ?? '',
      content: asStringOpt(data['content']) ?? '',
      nickName: asStringOpt(member?['nickName']),
      profileUrl: asStringOpt(member?['profile_url']),
      writeByMe: asBool(data['writedByMe'] ?? data['writeByMe']),
      likeCount: asInt(data['likeCount']),
      likedByMe: asBool(data['likedByMe']),
      scrapCount: asInt(data['scrapCount']),
      scrapedByMe: asBool(data['scrapedByMe']),
      commentCount: asInt(data['commentCount']),
      createdAt: asStringOpt(data['postAt']),
      isEdit: asBool(data['isEdit']),
      thumbImageUrl: asStringOpt(data['thumbImageUrl']),

      images:
          images
              .whereType<Map<String, dynamic>>()
              .map(ImageItem.fromJson)
              .toList(),
      imageCount: asInt(data['imageCount']),
    );
  }
}
