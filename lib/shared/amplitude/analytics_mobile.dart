import 'amplitude_flutter.dart';

late final AmplitudeFlutter _amplitude;

// analytics/analytics.dart의 내용 예시
class AnalyticsService {
  final AmplitudeFlutter _amplitude = AmplitudeFlutter.getInstance(instanceName: "default");

  void init() {
    const amplitudeKey = String.fromEnvironment('AMPLITUDE_API_KEY');
    if (amplitudeKey.isNotEmpty) {
      _amplitude.init(amplitudeKey);
      _amplitude.trackingSessionEvents(true);
    } else {
      print('⚠️ Amplitude API Key is missing');
    }
  }

  Future<void> logEvent(String eventName, {Map<String, dynamic>? properties}) async {
    return _amplitude.logEvent(eventName, eventProperties: properties);
  }
}
