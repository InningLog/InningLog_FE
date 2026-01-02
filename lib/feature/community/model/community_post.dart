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
  final String nickName;
  final String profileUrl;
  final bool writeByMe;
  final String title;
  final String content;
  final int likeCount;
  final bool likedByMe;
  final int scrapCount;
  final bool scrapedByMe;
  final int commentCount;
  final String createdAt;
  final bool isEdit;
  final List<ImageItem> images;

  const CommunityPostItem({
    required this.id,
    required this.teamCode,
    required this.title,
    required this.content,
    required this.nickName,
    required this.profileUrl,
    required this.writeByMe,
    required this.likeCount,
    required this.likedByMe,
    required this.scrapCount,
    required this.scrapedByMe,
    required this.commentCount,
    required this.createdAt,
    required this.isEdit,
    this.images = const [],
  });

  factory CommunityPostItem.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? json;
    final member = data['member'] as Map<String, dynamic>?;

    int asInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;
    String asString(dynamic v) => (v ?? '').toString();
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
      teamCode: asString(data['teamShortCode'] ?? data['teamCode']),
      title: asString(data['title']),
      content: asString(data['content']),
      nickName: asString(member?['nickName']),
      profileUrl: asString(member?['profile_url']),
      writeByMe: asBool(data['writedByMe'] ?? data['writeByMe']),
      likeCount: asInt(data['likeCount']),
      likedByMe: asBool(data['likedByMe']),
      scrapCount: asInt(data['scrapCount']),
      scrapedByMe: asBool(data['scrapedByMe']),
      commentCount: asInt(data['commentCount']),
      createdAt: data['postAt'],
      isEdit: asBool(data['isEdit']),
      images:
          images
              .whereType<Map<String, dynamic>>()
              .map(ImageItem.fromJson)
              .toList(),
    );
  }
}

/// Sample dummy posts for development and UI testing.
const dummyCommunityPosts = <CommunityPostItem>[
  CommunityPostItem(
    id: 1,
    teamCode: 'LG',
    title: '오늘 두산 왜이럼',
    content: '아 진짜 이 팀... ㅠㅠ',
    nickName: '볼빨간스트라스버그',
    profileUrl:
        'https://k.kakaocdn.net/dn/sample/img_640x640.jpg',
    writeByMe: true,
    likeCount: 12,
    likedByMe: false,
    scrapCount: 3,
    scrapedByMe: false,
    commentCount: 5,
    createdAt: '2025-01-31 14:22',
    isEdit: false,
    images: [
      ImageItem(
        imageId: 21,
        sequence: 1,
        url:
            'https://inninglog.s3.ap-northeast-3.amazonaws.com/post/1/uuid.jpeg',
      ),
    ],
  ),
  CommunityPostItem(
    id: 2,
    teamCode: 'OB',
    title: '잠실 야구장 내리는 비 소식',
    content: '우취 가능성 있을까요? 정보 아시는 분!',
    nickName: '엘린이',
    profileUrl:
        'https://k.kakaocdn.net/dn/sample/img_320x320.jpg',
    writeByMe: false,
    likeCount: 4,
    likedByMe: true,
    scrapCount: 1,
    scrapedByMe: false,
    commentCount: 2,
    createdAt: '2025-02-01 09:10',
    isEdit: false,
    images: const [],
  ),
  CommunityPostItem(
    id: 3,
    teamCode: 'KT',
    title: '오늘 경기 라인업 공유',
    content: '1. 홍길동\n2. 김철수\n3. 이영희\n타선 괜찮나요?',
    nickName: '야구는과학',
    profileUrl:
        'https://k.kakaocdn.net/dn/sample/img_256x256.jpg',
    writeByMe: false,
    likeCount: 30,
    likedByMe: false,
    scrapCount: 8,
    scrapedByMe: true,
    commentCount: 14,
    createdAt: '2025-02-02 11:45',
    isEdit: true,
    images: [
      ImageItem(
        imageId: 45,
        sequence: 1,
        url:
            'https://inninglog.s3.ap-northeast-3.amazonaws.com/post/3/lineup.jpeg',
      ),
      ImageItem(
        imageId: 46,
        sequence: 2,
        url:
            'https://inninglog.s3.ap-northeast-3.amazonaws.com/post/3/ballpark.jpeg',
      ),
    ],
  ),
];
