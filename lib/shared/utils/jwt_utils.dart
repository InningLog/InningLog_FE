import 'dart:convert';

class JwtUtils {
  static String decodePayload(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length != 3) return '(not a JWT)';

      String normalize(String s) => s
          .padRight(s.length + (4 - s.length % 4) % 4, '=')
          .replaceAll('-', '+')
          .replaceAll('_', '/');

      final payload = utf8.decode(base64Url.decode(normalize(parts[1])));
      return payload;
    } catch (_) {
      return '(decode failed)';
    }
  }

  /// JWT에서 memberId 추출: memberId 우선, 없으면 sub
  static int? extractMemberId(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length != 3) return null;

      String normalize(String s) => s
          .padRight(s.length + (4 - s.length % 4) % 4, '=')
          .replaceAll('-', '+')
          .replaceAll('_', '/');

      final payloadJson = utf8.decode(base64Url.decode(normalize(parts[1])));
      final map = jsonDecode(payloadJson) as Map<String, dynamic>;
      final v = map['memberId'] ?? map['sub'];
      if (v == null) return null;
      return int.tryParse(v.toString());
    } catch (_) {
      return null;
    }
  }
}
