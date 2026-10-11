import 'package:web/web.dart' as web;

/// Replaces `…/?token_hash=…&type=…` with the plain page address, so a reload
/// does not try to use the already spent link again.
void replaceBrowserUrlWithoutQuery() {
  final location = web.window.location;
  web.window.history.replaceState(null, '', location.pathname);
}
