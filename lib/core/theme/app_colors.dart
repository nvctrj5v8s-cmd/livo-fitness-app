import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFF080B0A);
  static const surface = Color(0xFF101513);
  static const surfaceHigh = Color(0xFF171D1A);
  static const surfaceSoft = Color(0xFF1D2421);
  static const border = Color(0xFF29312D);
  static const text = Color(0xFFF7F9F7);
  static const textMuted = Color(0xFFA1ACA6);
  static const primary = Color(0xFFD6F76F);
  static const mint = Color(0xFF73DEC5);
  static const orange = Color(0xFFFFA56B);
  static const purple = Color(0xFFA99AF5);
  static const blue = Color(0xFF79BFFF);
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
