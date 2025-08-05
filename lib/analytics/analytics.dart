import 'package:inninglog/analytics/amplitude_flutter.dart';

class AnalyticsService {
  late final AmplitudeFlutter _amplitude;

  Future<void> init() async {
    _amplitude = AmplitudeFlutter.getInstance(instanceName: "default");

    const amplitudeKey = String.fromEnvironment('AMPLITUDE_API_KEY');
    if (amplitudeKey.isNotEmpty) {
      _amplitude.init(amplitudeKey);
      _amplitude.trackingSessionEvents(true);
    } else {
      print('⚠️ Amplitude API Key is missing in AnalyticsService');
    }
  }

  Future<void> logEvent(String eventName, {Map<String, dynamic>? properties}) async {
    await _amplitude.logEvent(eventName, eventProperties: properties);
  }
}
