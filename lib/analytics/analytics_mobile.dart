import 'package:amplitude_flutter/amplitude_flutter.dart';

late final AmplitudeFlutter _amplitude;

// analytics/analytics.dart의 내용 예시
class AnalyticsService {
  final AmplitudeFlutter _amplitude = AmplitudeFlutter.getInstance(instanceName: "default");

  void init() {
    _amplitude.init("821c8925a751c008310e896ad437b1bc");
    _amplitude.trackingSessionEvents(true);
  }

  Future<void> logEvent(String eventName, {Map<String, dynamic>? properties}) async {
    return _amplitude.logEvent(eventName, eventProperties: properties);
  }
}

