class AuthSession {
  final String accessToken;
  final String? refreshToken;
  final String? nickname;
  final int? memberId;
  final bool isNewMember;

  AuthSession({
    required this.accessToken,
    this.refreshToken,
    this.nickname,
    this.memberId,
    required this.isNewMember,
  });

  factory AuthSession.fromCallbackJson(Map<String, dynamic> map) {
    final accessToken = map['accessToken'] as String?;
    if (accessToken == null || accessToken.isEmpty) {
      throw const FormatException('accessToken is missing');
    }

    return AuthSession(
      accessToken: accessToken,
      refreshToken: map['refreshToken'] as String?,
      nickname: map['nickname'] as String?,
      isNewMember: (map['newMember'] ?? false) as bool,
      memberId: null,
    );
  }

  AuthSession copyWith({int? memberId}) => AuthSession(
    accessToken: accessToken,
    refreshToken: refreshToken,
    nickname: nickname,
    isNewMember: isNewMember,
    memberId: memberId,
  );
}
