import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  FirebaseAnalytics? _analytics;

  FirebaseAnalyticsObserver getAnalyticsObserver() =>
      FirebaseAnalyticsObserver(analytics: _analytics ?? FirebaseAnalytics.instance);

  Future<FirebaseAnalytics> _getInstance() async {
    _analytics ??= FirebaseAnalytics.instance;
    return _analytics!;
  }

  Future<void> logScreenView(String screenName) async {
    final analytics = await _getInstance();
    await analytics.setCurrentScreen(screenName: screenName);
  }

  Future<void> logEvent(String name, Map<String, Object> parameters) async {
    final analytics = await _getInstance();
    await analytics.logEvent(name: name, parameters: parameters);
  }
}
