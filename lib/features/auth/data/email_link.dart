import 'package:supabase_flutter/supabase_flutter.dart';

/// A sign-in link from a LIVO e-mail: `…?token_hash=…&type=recovery`.
///
/// The e-mail templates in `supabase/templates/` link with a one-time token
/// hash instead of the default PKCE code. Unlike the code, the hash does not
/// need a verifier stored in the browser that requested the mail, so a reset
/// requested on a computer can be opened on a phone.
class EmailLink {
  const EmailLink(this.tokenHash, this.type);

  final String tokenHash;
  final OtpType type;

  bool get isPasswordRecovery => type == OtpType.recovery;

  static const _types = {
    'recovery': OtpType.recovery,
    'signup': OtpType.signup,
    'email': OtpType.email,
    'email_change': OtpType.emailChange,
    'invite': OtpType.invite,
  };

  /// The link in [uri], from the query or (after a redirect) the fragment,
  /// or `null` when [uri] is no complete e-mail link.
  static EmailLink? fromUri(Uri uri) {
    final parameters = {
      ...uri.queryParameters,
      if (uri.fragment.contains('token_hash='))
        ...Uri.splitQueryString(uri.fragment),
    };
    final hash = parameters['token_hash']?.trim();
    final type = _types[parameters['type']];
    if (hash == null || hash.isEmpty || hash.length > 512 || type == null) {
      return null;
    }
    return EmailLink(hash, type);
  }

  /// Exchanges the link for a session. Recovery links emit
  /// [AuthChangeEvent.passwordRecovery], which opens the new-password page.
  /// Returns `false` when the link is expired or was already used.
  Future<bool> verify(GoTrueClient auth) async {
    try {
      final response = await auth.verifyOTP(type: type, tokenHash: tokenHash);
      return response.session != null || type == OtpType.emailChange;
    } on AuthException {
      return false;
    }
  }
}
