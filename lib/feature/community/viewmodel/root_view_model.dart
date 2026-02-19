import 'package:flutter/material.dart';
import 'package:inninglog/feature/community/data/team_catalog.dart';
import 'package:inninglog/feature/community/model/post_base.dart';
import 'package:inninglog/feature/community/model/team_item.dart';
import 'package:inninglog/feature/community/repositories/post_repository.dart';
import 'package:inninglog/feature/user/repositories/user_repository.dart';

class CommunityRootViewModel extends ChangeNotifier {
  final UserRepository userRepository;
  final CommunityPostRepository postRepository;

  CommunityRootViewModel({
    required this.userRepository,
    required this.postRepository,
  });

  List<TeamItem> _teamGridItems = kboTeams;
  List<TeamItem> get teamGridItems => _teamGridItems;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String? myTeamCode;

  List<PostBase> _popularPosts = [];
  List<PostBase> get popularPosts => _popularPosts;

  bool _isPopularPostsLoading = false;
  bool get isPopularPostsLoading => _isPopularPostsLoading;

  Future<void> fetchMyTeam() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final res = await userRepository.getTeam();
      final teamCode = res.data['teamShortCode'];
      myTeamCode = teamCode;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _rebuildTeamGridItems();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPopularPosts() async {
    if (_isPopularPostsLoading) return;
    _isPopularPostsLoading = true;
    notifyListeners();

    try {
      _popularPosts = await postRepository.getCommunityHome();
    } catch (e) {
      debugPrint('fetchPopularPosts error: $e');
    } finally {
      _isPopularPostsLoading = false;
      notifyListeners();
    }
  }

  void _rebuildTeamGridItems() {
    if (myTeamCode == null) {
      _teamGridItems = kboTeams;
      return;
    }

    _teamGridItems = [...kboTeams.where((t) => t.code != myTeamCode)];
  }
}
