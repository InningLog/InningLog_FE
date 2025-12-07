import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AmplitudeFlutter {
  static final Map<String, AmplitudeFlutter> _instances = {};
  final String instanceName;
  String? _apiKey;
  String? _deviceId;

  AmplitudeFlutter._internal(this.instanceName);

  static AmplitudeFlutter getInstance({String instanceName = 'default'}) {
    return _instances.putIfAbsent(
      instanceName,
          () => AmplitudeFlutter._internal(instanceName),
    );
  }

  /// API 키 설정 + deviceId 고정
  Future<void> init(String apiKey) async {
    _apiKey = apiKey;

    final prefs = await SharedPreferences.getInstance();
    String? savedDeviceId = prefs.getString('amplitude_device_id');

    if (savedDeviceId == null) {
      // 최초 실행 시 UUID 생성
      savedDeviceId = const Uuid().v4();
      await prefs.setString('amplitude_device_id', savedDeviceId);
      print('📱 새 deviceId 생성: $savedDeviceId');
    } else {
      print('📱 기존 deviceId 불러옴: $savedDeviceId');
    }

    _deviceId = savedDeviceId;
  }

  /// 이벤트 전송 (userId 없이 deviceId만)
  Future<void> logEvent(String eventName, {Map<String, dynamic>? eventProperties}) async {
    if (_apiKey == null) {
      print('⚠️ Amplitude API Key 없음');
      return;
    }

    final body = {
      'api_key': _apiKey,
      'events': [
        {
          'device_id': _deviceId ?? 'unknown_device',
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

      if (response.statusCode != 200) {
        print('❌ Amplitude 이벤트 전송 실패: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Amplitude 예외: $e');
    }
  }
}
