import 'package:web/web.dart' as web;

void updateDocumentLanguage(String code) {
  web.document.documentElement?.setAttribute('lang', code);
}
