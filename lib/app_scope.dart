import 'package:inninglog/feature/community/repositories/comment_repository.dart';
import 'package:inninglog/feature/community/repositories/post_repository.dart';
import 'package:inninglog/feature/user/repositories/user_repository.dart';
import 'package:inninglog/shared/auth/token_storage.dart';
import 'package:inninglog/shared/network/api_client.dart';

class AppScope {
  final TokenStorage tokenStorage;
  final ApiClient apiClient;

  late final CommunityPostRepository communityPostRepository =
      CommunityPostRepository(apiClient.dio);
  late final CommentRepository commentRepository =
      CommentRepository(apiClient.dio);
  late final UserRepository userRepository = UserRepository(apiClient.dio);

  AppScope._({required this.tokenStorage, required this.apiClient});

  static Future<AppScope> create() async {
    final tokenStorage = SharedPrefsTokenStorage();
    final apiClient = ApiClient(
      baseUrl: 'https://api.inninglog.shop',
      tokenStorage: tokenStorage,
    );
    return AppScope._(tokenStorage: tokenStorage, apiClient: apiClient);
  }
}
