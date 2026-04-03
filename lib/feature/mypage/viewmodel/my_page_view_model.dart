import 'package:flutter/material.dart';
import 'package:inninglog/feature/user/repositories/user_repository.dart';

class MyPageViewModel extends ChangeNotifier {
  final UserRepository _repo;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  MemberProfileResponse? _profile;
  MemberProfileResponse? get profile => _profile;

  String? _error;
  String? get error => _error;

  MyPageViewModel(this._repo);

  Future<void> refresh() => fetch();

  Future<void> fetch() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _repo.getProfile();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
