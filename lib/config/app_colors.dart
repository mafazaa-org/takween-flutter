import 'package:flutter/material.dart';

class AppColors {
  // Navy Blue Palette
  static const Color navyBlue = Color(0xFF0A2647);
  static const Color darkNavy = Color(0xFF144272);
  static const Color mediumNavy = Color(0xFF205295);
  static const Color lightNavy = Color(0xFF2C74B3);

  // Green Palette
  static const Color green = Color(0xFF10B981);
  static const Color darkGreen = Color(0xFF059669);
  static const Color lightGreen = Color(0xFF34D399);
  static const Color emeraldGreen = Color(0xFF6EE7B7);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF9FAFB);
  static const Color lightGray = Color(0xFFF3F4F6);
  static const Color gray = Color(0xFF9CA3AF);
  static const Color darkGray = Color(0xFF6B7280);
  static const Color charcoal = Color(0xFF374151);

  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [navyBlue, mediumNavy],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [green, darkGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [mediumNavy, green],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

