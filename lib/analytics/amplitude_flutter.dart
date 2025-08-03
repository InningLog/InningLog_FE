import 'dart:convert';
import 'package:http/http.dart' as http;

/// Amplitude 서버에 직접 이벤트 전송을 위한 클래스
class AmplitudeFlutter {
  static final Map<String, AmplitudeFlutter> _instances = {};

  final String instanceName;
  String? _apiKey;
  String? _userId;

  AmplitudeFlutter._internal(this.instanceName);

  /// 싱글턴 인스턴스 가져오기
  static AmplitudeFlutter getInstance({String instanceName = 'default'}) {
    return _instances.putIfAbsent(
      instanceName,
          () => AmplitudeFlutter._internal(instanceName),
    );
  }

  /// API 키 설정
  void init(String apiKey) {
    _apiKey = apiKey;
  }

  /// 세션 이벤트 로깅 여부 설정 (실제 로직은 없음, 로그용)
  void trackingSessionEvents(bool enable) {
  }

  /// 사용자 ID 설정
  void setUserId(String userId) {
    _userId = userId;

  }

  /// Amplitude에 이벤트 전송
  Future<void> logEvent(String eventName, {Map<String, dynamic>? eventProperties}) async {


    if (_apiKey == null) {

      return;
    }

    final body = {
      'api_key': _apiKey,
      'events': [
        {
          'user_id': _userId ?? 'anonymous',
          'device_id': 'flutter-device-id',
          'event_type': eventName,
          'event_properties': eventProperties ?? {},
        }
      ]
    };

    try {
      final response = await http.post(
        Uri.parse('https://api2.amplitude.com/2/httpapi'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {

      } else {

      }
    } catch (e) {

    }
  }
}
