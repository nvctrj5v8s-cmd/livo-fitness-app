import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFF050708);
  static const backgroundRaised = Color(0xFF090D0E);
  static const surface = Color(0xFF0E1414);
  static const surfaceHigh = Color(0xFF151D1C);
  static const surfaceSoft = Color(0xFF1B2523);
  static const border = Color(0xFF283633);
  static const borderBright = Color(0xFF3A4A46);
  static const text = Color(0xFFF5F8F7);
  static const textMuted = Color(0xFF98A6A1);
  static const primary = Color(0xFFC8FF5A);
  static const primarySoft = Color(0xFF9EEA4F);
  static const mint = Color(0xFF57E3BC);
  static const orange = Color(0xFFFFB06A);
  static const purple = Color(0xFFB6A3FF);
  static const blue = Color(0xFF5DCAFF);
  static const cyan = Color(0xFF55E2E8);
  static const error = Color(0xFFFF7E82);
  static const black = Color(0xFF050706);
  static const white = Color(0xFFFFFFFF);

  // Compatibility aliases for older widgets while the prototype evolves.
  static const ink = text;
  static const forest = mint;
  static const darkForest = background;
  static const lime = primary;
  static const cream = background;
  static const muted = textMuted;
  static const line = border;
  static const peach = orange;
  static const coral = orange;
  static const lilac = purple;
  static const sky = blue;
}
