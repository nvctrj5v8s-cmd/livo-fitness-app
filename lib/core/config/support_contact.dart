import 'package:url_launcher/url_launcher.dart';

/// Where questions, problems and reports about coach answers go. The same
/// address is in the imprint and the privacy policy.
abstract final class SupportContact {
  static const email = 'lookinsupport@gmail.com';

  /// A `mailto:` link. Spaces become `%20` (the `+` of a normal query would
  /// show up as a plus sign in many mail apps).
  static Uri mailto({String? subject, String? body}) {
    final parts = <String>[
      if (subject != null && subject.isNotEmpty)
        'subject=${Uri.encodeComponent(subject)}',
      if (body != null && body.isNotEmpty) 'body=${Uri.encodeComponent(body)}',
    ];
    return Uri.parse(
      'mailto:$email${parts.isEmpty ? '' : '?${parts.join('&')}'}',
    );
  }

  /// Opens the mail app with a prepared message. Returns `false` when no
  /// mail app could be opened; nothing is sent by Lookin itself.
  static Future<bool> open({
    String? subject,
    String? body,
    Future<bool> Function(Uri uri)? opener,
  }) async {
    final uri = mailto(subject: subject, body: body);
    try {
      return await (opener ?? (uri) => launchUrl(uri))(uri);
    } catch (_) {
      return false;
    }
  }
}
