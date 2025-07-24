import 'package:inninglog/analytics/amplitude_flutter.dart';

class AnalyticsService {
  late final AmplitudeFlutter _amplitude;

  void init() {
    _amplitude = AmplitudeFlutter.getInstance(instanceName: "default");
    _amplitude.init("821c8925a751c008310e896ad437b1bc");
    _amplitude.trackingSessionEvents(true);
  }

  Future<void> logEvent(String eventName, {Map<String, dynamic>? properties}) async {
    await _amplitude.logEvent(eventName, eventProperties: properties);
  }
}
