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
    print('[Amplitude:$instanceName] Initialized with key $apiKey');
  }

  /// 세션 이벤트 로깅 여부 설정 (실제 로직은 없음, 로그용)
  void trackingSessionEvents(bool enable) {
    print('[Amplitude:$instanceName] Tracking session events: $enable');
  }

  /// 사용자 ID 설정
  void setUserId(String userId) {
    _userId = userId;
    print('[Amplitude:$instanceName] Set userId: $userId');
  }

  /// Amplitude에 이벤트 전송
  Future<void> logEvent(String eventName, {Map<String, dynamic>? eventProperties}) async {
    print('[Amplitude:$instanceName] ⚙️ logEvent() 진입');

    if (_apiKey == null) {
      print('[Amplitude:$instanceName] ❌ API key not set');
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
    print('[Amplitude:$instanceName] 🔁 Sending payload: ${jsonEncode(body)}');

    try {
      final response = await http.post(
        Uri.parse('https://api2.amplitude.com/2/httpapi'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('[Amplitude:$instanceName] ✅ Event sent to Amplitude');
        print('[Amplitude:$instanceName] 🔁 Sending payload: ${jsonEncode(body)}');
        print('[Amplitude:$instanceName] 📡 Response code: ${response.statusCode}');
        print('[Amplitude:$instanceName] 📬 Response body: ${response.body}');
      } else {
        print('[Amplitude:$instanceName] ❌ Failed to send: ${response.statusCode}');
        print(response.body);
      }
    } catch (e) {
      print('[Amplitude:$instanceName] ❌ Exception: $e');
    }
  }
}
