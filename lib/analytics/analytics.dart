import 'package:inninglog/analytics/amplitude_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AnalyticsService {
  late final AmplitudeFlutter _amplitude;

  Future<void> init() async {
    await dotenv.load();
    _amplitude = AmplitudeFlutter.getInstance(instanceName: "default");

    final amplitudeKey = dotenv.env['AMPLITUDE_API_KEY'];
    _amplitude.init(amplitudeKey!); // amplitude → _amplitude (오타 주의)
    _amplitude.trackingSessionEvents(true);
  }

  Future<void> logEvent(String eventName, {Map<String, dynamic>? properties}) async {
    await _amplitude.logEvent(eventName, eventProperties: properties);
  }
}
