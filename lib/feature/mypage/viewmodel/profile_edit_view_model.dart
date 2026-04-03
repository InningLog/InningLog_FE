import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inninglog/feature/user/repositories/user_repository.dart';

class ProfileEditViewModel extends ChangeNotifier {
  final UserRepository _repo;
  final ImagePicker _picker;

  String nickname;
  String profileUrl;
  final String teamShortCode;
  Uint8List? pickedImageBytes;
  String? _pickedImageName;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ProfileEditViewModel({
    required UserRepository repo,
    required this.nickname,
    required this.profileUrl,
    required this.teamShortCode,
    ImagePicker? picker,
  })  : _repo = repo,
        _picker = picker ?? ImagePicker();

  Future<void> pickImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;
    pickedImageBytes = await file.readAsBytes();
    _pickedImageName = file.name;
    notifyListeners();
  }

  /// 닉네임(+ 이미지) 저장
  /// 성공 시 true, 실패 시 false (errorMessage에 사유 저장)
  Future<bool> save(String newNickname) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repo.patchNickname(newNickname.trim());
      nickname = newNickname.trim();

      if (pickedImageBytes != null) {
        profileUrl = await _repo.uploadProfileImage(
          pickedImageBytes!,
          _pickedImageName ?? 'profile.jpg',
        );
      }

      return true;
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('DUPLICATE_NICKNAME') ||
          msg.contains('이미 존재하는 닉네임')) {
        _errorMessage = '이미 사용 중인 닉네임이에요.';
      } else {
        _errorMessage = '저장에 실패했어요. 다시 시도해 주세요.';
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
