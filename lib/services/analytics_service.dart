import 'package:firebase_analytics/firebase_analytics.dart';
import 'dart:js' as js;
import 'package:myapp/utils/logger_config.dart';

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

  void pushToGTM(String eventName, Map<String, Object> parameters) {
    try {
      final js.JsObject? dataLayer = js.context['dataLayer'];
      final eventData = js.JsObject.jsify({'event': eventName, ...parameters});
      dataLayer?.callMethod('push', [eventData]);
      //js.context.callMethod('dataLayer.push', [data]);
    } catch (e) {
      logger.e('dataLayer not available: $e');
    }
  }
}
