import 'package:fitness_ai_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Knopftexte nennen die Schrift ausdrücklich (keine leeren Kästchen)',
    () {
      final style = AppTheme.dark.filledButtonTheme.style!.textStyle!.resolve(
        <WidgetState>{},
      )!;
      expect(style.fontFamily, isNotNull);
      expect(style.fontFamily, isNotEmpty);
      expect(style.fontWeight, FontWeight.w800);
    },
  );
}
