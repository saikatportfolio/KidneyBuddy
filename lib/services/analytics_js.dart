// Picks the right implementation at compile time.
export 'analytics_js_stub.dart'
  if (dart.library.html) 'analytics_js_web.dart';