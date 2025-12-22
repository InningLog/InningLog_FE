import 'package:shared_preferences/shared_preferences.dart';
import 'auth_session.dart';

abstract class TokenStorage {
  Future<String?> readAccessToken();
  Future<String?> readRefreshToken();

  Future<void> saveSession(AuthSession session);
  Future<void> clear();
}

class SharedPrefsTokenStorage implements TokenStorage {
  static const _kAccessTokenKey = 'accessToken';
  static const _kRefreshTokenKey = 'refreshToken';
  static const _kNicknameKey = 'nickname';
  static const _kMemberIdKey = 'memberId';

  @override
  Future<String?> readAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kAccessTokenKey);
  }

  @override
  Future<String?> readRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kRefreshTokenKey);
  }

  @override
  Future<void> saveSession(AuthSession session) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_kAccessTokenKey, session.accessToken);

    if (session.refreshToken != null && session.refreshToken!.isNotEmpty) {
      await prefs.setString(_kRefreshTokenKey, session.refreshToken!);
    }

    if (session.nickname != null && session.nickname!.isNotEmpty) {
      await prefs.setString(_kNicknameKey, session.nickname!);
    }

    if (session.memberId != null) {
      await prefs.setInt(_kMemberIdKey, session.memberId!);
    }
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAccessTokenKey);
    await prefs.remove(_kRefreshTokenKey);
    await prefs.remove(_kNicknameKey);
    await prefs.remove(_kMemberIdKey);
  }
}
