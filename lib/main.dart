import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/config/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Supabase may consume and clear the web recovery URL during initialize,
  // before the first widget can subscribe to auth events.
  final initialPasswordRecovery =
      Uri.base.queryParameters['type'] == 'recovery' ||
      Uri.base.fragment.contains('type=recovery');

  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );

  runApp(FitnessAiApp(initialPasswordRecovery: initialPasswordRecovery));
}
