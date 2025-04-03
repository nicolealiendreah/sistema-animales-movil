import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF43A047); // Verde fuerte (botones)
  static const Color background = Color(0xFFA5D6A7); // Verde claro (pantallas login/register)
  static const Color white = Colors.white;
  static const Color textLight = Colors.white;
  static const Color textDark = Colors.black87;
  static const Color border = Colors.white;
  static const Color buttonText = Color(0xFF1B5E20); // Verde oscuro
}

class AppPadding {
  static const double horizontal = 32.0;
  static const double vertical = 24.0;
  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
}

class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textLight,
  );

  static const TextStyle inputHint = TextStyle(
    color: AppColors.textLight,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.buttonText,
  );

  static const subheading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );
}
