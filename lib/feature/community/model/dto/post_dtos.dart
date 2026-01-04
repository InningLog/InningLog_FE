import 'package:inninglog/feature/community/model/community_post.dart';

class PostListResponse {
  final List<CommunityPostItem> content;
  final bool hasNext;
  final int page;
  final int size;

  PostListResponse({
    required this.content,
    required this.hasNext,
    required this.page,
    required this.size,
  });

  factory PostListResponse.fromJson(Map<String, dynamic> json) {
    final body = (json['data'] as Map<String, dynamic>?) ?? json;

    final content =
        (body['content'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(CommunityPostItem.fromJson)
            .toList();
    return PostListResponse(
      content: content,
      hasNext: body['hasNext'] == true,
      page: (body['page'] ?? 0) as int,
      size: (body['size'] ?? content.length) as int,
    );
  }
}
