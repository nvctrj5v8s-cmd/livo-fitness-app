import 'package:fitness_ai_app/features/auth/data/email_link.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  const base = 'https://nvctrj5v8s-cmd.github.io/livo-fitness-app/';

  test('Reset-Link aus der Lookin-Mail wird erkannt', () {
    final link = EmailLink.fromUri(
      Uri.parse('$base?token_hash=pkce_abc123&type=recovery'),
    );
    expect(link, isNotNull);
    expect(link!.tokenHash, 'pkce_abc123');
    expect(link.type, OtpType.recovery);
    expect(link.isPasswordRecovery, isTrue);
  });

  test('Bestätigung und E-Mail-Wechsel, auch im Fragment', () {
    expect(
      EmailLink.fromUri(Uri.parse('$base?token_hash=x&type=email'))!.type,
      OtpType.email,
    );
    expect(
      EmailLink.fromUri(
        Uri.parse('$base#token_hash=y&type=email_change'),
      )!.type,
      OtpType.emailChange,
    );
  });

  test('normale Aufrufe und unvollständige Links werden ignoriert', () {
    for (final url in [
      base,
      '$base?code=abc',
      '$base?token_hash=&type=recovery',
      '$base?token_hash=abc',
      '$base?token_hash=abc&type=sms',
      '$base#access_token=x&type=recovery',
    ]) {
      expect(EmailLink.fromUri(Uri.parse(url)), isNull, reason: url);
    }
  });
}
