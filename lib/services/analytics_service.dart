import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:myapp/utils/analytics_event_names.dart';
import 'package:myapp/utils/logger_config.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

// IMPORTANT: no 'dart:js' import here
import 'analytics_js.dart' as webjs;

class AnalyticsService {
  FirebaseAnalytics? _analytics;

  FirebaseAnalyticsObserver getAnalyticsObserver() => FirebaseAnalyticsObserver(
        analytics: _analytics ?? FirebaseAnalytics.instance,
      );

  Future<FirebaseAnalytics> _getInstance() async {
    _analytics ??= FirebaseAnalytics.instance;
    return _analytics!;
  }

  Future<void> logScreenView(String screenName) async {
    final analytics = await _getInstance();
    await analytics.logScreenView(screenName: screenName);
  }

  Future<void> logEvent(String name, Map<String, Object> parameters) async {
    final analytics = await _getInstance();
    await analytics.logEvent(name: name, parameters: parameters);
    pushToGTM(name, parameters);
  }

  /// Public method signature kept intact.
  void pushToGTM(String eventName, Map<String, Object> parameters) {
    try {
      // Delegate to platform-specific implementation.
      webjs.pushToGTM(eventName, parameters);
    } catch (e) {
      logger.e('pushToGTM failed or unsupported on this platform: $e');
    }
  }

  void trackScreen(String screenName) {
    logScreenView(screenName);
    pushToGTM(
      AnalyticsEventNames.screenView,
      {AnalyticsEventNames.screenName: screenName},
    );
  }

  Future<void> setUserId(String userId) async {
    final analytics = await _getInstance();
    final bytes = utf8.encode(userId);
    final digest = sha256.convert(bytes);
    await analytics.setUserId(id: digest.toString());
  }
}
