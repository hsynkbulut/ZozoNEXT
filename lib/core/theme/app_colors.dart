import 'package:flutter/material.dart';

class AppColors {
  // Modern, vibrant color palette
  static const primary = Color(0xFF6C63FF); // Vibrant Purple
  static const primaryLight = Color(0xFF837DFF);
  static const primaryDark = Color(0xFF5046E4);

  // Secondary Colors - Playful and energetic
  static const secondary = Color(0xFF00D9F5); // Bright Cyan
  static const secondaryLight = Color(0xFF52E9FF);
  static const secondaryDark = Color(0xFF00B6CE);

  // Accent Colors - For highlights and important actions
  static const accent = Color(0xFFFF6B6B); // Coral Red
  static const accentLight = Color(0xFFFF8E8E);
  static const accentDark = Color(0xFFE64545);

  // Success Colors - Fresh and positive
  static const success = Color(0xFF4CAF50); // Green
  static const successLight = Color(0xFF69C66D);
  static const successDark = Color(0xFF388E3C);

  // Warning Colors - Attention-grabbing
  static const warning = Color(0xFFFFBE0B); // Bright Yellow
  static const warningLight = Color(0xFFFFCE3C);
  static const warningDark = Color(0xFFE6A800);

  // Error Colors - Clear but not harsh
  static const error = Color(0xFFFF686B); // Soft Red
  static const errorLight = Color(0xFFFF8E91);
  static const errorDark = Color(0xFFE63E42);

  // Neutral Colors - Clean and modern
  static const background = Color(0xFFF8F9FF); // Very Light Purple tint
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF2D3142); // Dark Blue-Grey
  static const textSecondary = Color(0xFF9094A6); // Medium Grey
  static const border = Color(0xFFEAEBF6); // Light Purple-Grey

  // Gradient Colors - Dynamic and engaging
  static const gradientStart = Color(0xFF6C63FF); // Vibrant Purple
  static const gradientMiddle = Color(0xFF837DFF); // Mid Purple
  static const gradientEnd = Color(0xFF00D9F5); // Bright Cyan

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientMiddle, gradientEnd],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF8F9FF),
      Color(0xFFFFFFFF),
      Color(0xFFF0F3FF),
    ],
  );

  // Card gradients for visual interest
  static const LinearGradient cardGradient1 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6C63FF),
      Color(0xFF837DFF),
    ],
  );

  static const LinearGradient cardGradient2 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF00D9F5),
      Color(0xFF52E9FF),
    ],
  );

  // Overlay gradients for depth
  static const LinearGradient overlayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.black12,
      Colors.black26,
    ],
  );
}
