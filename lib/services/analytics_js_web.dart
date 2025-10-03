// Web implementation only. This file is compiled only for web builds.
import 'dart:js' as js;

void pushToGTM(String eventName, Map<String, Object> parameters) {
  // Cast to dynamic map for jsify
  final payload = <String, dynamic>{'event': eventName, ...parameters};

  // Prefer gtag if present
  final gtag = js.context['gtag'];
  if (gtag != null) {
    // gtag('event', 'event_name', { ...params })
    js.context.callMethod('gtag', ['event', eventName, parameters]);
  }

  // Also push to dataLayer if available
  final dataLayer = js.context['dataLayer'];
  if (dataLayer != null) {
    final jsDataLayer = dataLayer as js.JsObject?;
    jsDataLayer?.callMethod('push', [js.JsObject.jsify(payload)]);
  }
}