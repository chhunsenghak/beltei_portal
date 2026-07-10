import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static Brightness _brightness = Brightness.light;
  static void setBrightness(Brightness brightness) => _brightness = brightness;
  static Brightness get brightness => _brightness;
  static bool get _isDark => _brightness == Brightness.dark;

  static Color _brandLightColor = const Color(0xFF1A237E);
  static Color _brandDarkColor = const Color(0xFF5C6BC0);

  static void setBrandColors(Color light, Color dark) {
    _brandLightColor = light;
    _brandDarkColor = dark;
  }

  // Primary
  static Color get primaryNavy => _isDark ? _brandDarkColor : _brandLightColor;
  static Color get primaryBlue => _isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);
  static Color get accentGold => _isDark ? const Color(0xFFE8B93A) : const Color(0xFFD4A017);

  // Status
  static Color get statusGreen => _isDark ? const Color(0xFF4ADE80) : const Color(0xFF22C55E);
  static Color get statusRed => _isDark ? const Color(0xFFF87171) : const Color(0xFFEF4444);
  static Color get statusAmber => _isDark ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B);
  static const Color statusGray = Color(0xFF9CA3AF);

  // Status backgrounds (light tint in light mode, dark tint in dark mode)
  static Color get statusGreenBg => _isDark ? const Color(0xFF1B3A2E) : const Color(0xFFDCFCE7);
  static Color get statusRedBg => _isDark ? const Color(0xFF3F1D1D) : const Color(0xFFFEE2E2);
  static Color get statusAmberBg => _isDark ? const Color(0xFF3F2F0F) : const Color(0xFFFEF3C7);
  static Color get statusGrayBg => _isDark ? const Color(0xFF2A2E37) : const Color(0xFFF3F4F6);
  static Color get statusBlueBg => _isDark ? const Color(0xFF1E2A47) : const Color(0xFFDBEAFE);

  // Background
  static Color get bgPage => _isDark ? const Color(0xFF0F1115) : const Color(0xFFF8F9FF);
  static Color get bgCard => _isDark ? const Color(0xFF1A1D23) : const Color(0xFFFFFFFF);
  static Color get bgInput => _isDark ? const Color(0xFF20242C) : const Color(0xFFF9FAFB);

  // Border
  static Color get border => _isDark ? const Color(0xFF2E323C) : const Color(0xFFE5E7EB);
  static Color get borderDark => _isDark ? const Color(0xFF3A3F4B) : const Color(0xFFD1D5DB);

  // Text
  static Color get textPrimary => _isDark ? const Color(0xFFF3F4F6) : const Color(0xFF111827);
  static Color get textSecondary => _isDark ? const Color(0xFFA1A8B5) : const Color(0xFF6B7280);
  static Color get textLabel => _isDark ? const Color(0xFF7B8291) : const Color(0xFF9CA3AF);
  static const Color textWhite = Color(0xFFFFFFFF);
  static Color get textLink => _isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);

  // Divider
  static Color get divider => _isDark ? const Color(0xFF2A2E37) : const Color(0xFFF3F4F6);

  // Splash gradient (unaffected by theme — pre-auth branding)
  static const Color splashDark = Color(0xFF1A237E);
  static const Color splashLight = Color(0xFF283593);
}
