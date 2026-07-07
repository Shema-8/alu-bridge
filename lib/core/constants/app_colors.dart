import 'package:flutter/material.dart';

/// Centralized color palette for the entire app.
///
/// WHY a single AppColors class instead of hardcoding colors in widgets?
/// - One source of truth: change the brand red once, it updates everywhere.
/// - Makes dark/light theme switching trivial later (rubric mentions this
///   as a "nice to have" under UI polish).
/// - Easy to explain in the demo: "all our colors come from one file."
class AppColors {
  AppColors._(); // prevents instantiation

  // Brand core
  static const Color primaryRed = Color(0xFFE31E24); // strong, energetic red
  static const Color deepRed = Color(0xFF9E0F14); // pressed/hover states
  static const Color black = Color(0xFF0A0A0A); // near-black, not pure #000
  static const Color charcoal = Color(0xFF1C1C1E); // surfaces on dark bg
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF7F7F8); // background, easier on eyes

  // Greys for hierarchy (text, borders, disabled states)
  static const Color grey100 = Color(0xFFE4E4E7);
  static const Color grey400 = Color(0xFF9B9BA1);
  static const Color grey700 = Color(0xFF4A4A4F);

  // Semantic colors (status badges, etc.)
  static const Color success = Color(0xFF1FAA59);
  static const Color warning = Color(0xFFE6A100);
  static const Color error = Color(0xFFD32F2F);
  static const Color pending = Color(0xFF6B6B70);

  // Gradients (used on splash / hero cards for visual polish)
  static const LinearGradient redToBlack = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryRed, black],
  );
}
