import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.black,
      secondary: AppColors.mint,
      onSecondary: AppColors.black,
      surface: AppColors.surface,
      onSurface: AppColors.text,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      dividerColor: AppColors.border,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          color: AppColors.text,
          fontSize: 42,
          height: 1.02,
          fontWeight: FontWeight.w900,
          letterSpacing: -1.8,
        ),
        headlineLarge: TextStyle(
          color: AppColors.text,
          fontSize: 34,
          height: 1.08,
          fontWeight: FontWeight.w900,
          letterSpacing: -1.25,
        ),
        headlineMedium: TextStyle(
          color: AppColors.text,
          fontSize: 25,
          height: 1.12,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.7,
        ),
        titleLarge: TextStyle(
          color: AppColors.text,
          fontSize: 19,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.25,
        ),
        titleMedium: TextStyle(
          color: AppColors.text,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(color: AppColors.text, fontSize: 16, height: 1.45),
        bodyMedium: TextStyle(
          color: AppColors.textMuted,
          fontSize: 14,
          height: 1.42,
        ),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surfaceHigh,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.all(Radius.circular(26)),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xCC151D1C),
        hintStyle: TextStyle(color: AppColors.textMuted),
        prefixIconColor: AppColors.textMuted,
        suffixIconColor: AppColors.textMuted,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 1.4),
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.black,
          minimumSize: const Size(52, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(19),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        modalBackgroundColor: AppColors.surface,
        showDragHandle: true,
        dragHandleColor: AppColors.border,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.surfaceSoft,
        contentTextStyle: TextStyle(color: AppColors.text),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: AppColors.surfaceHigh,
        indicatorColor: AppColors.primary.withValues(alpha: 0.16),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 23,
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.textMuted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? AppColors.text
                : AppColors.textMuted,
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(46, 46)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
    );
  }
}
