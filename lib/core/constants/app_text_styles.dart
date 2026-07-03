import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const double _defaultHeight = 1.45;

  static TextStyle _style({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? letterSpacing,
    double? height,
  }) {
    final khmerFont = GoogleFonts.notoSansKhmer(
      fontWeight: fontWeight,
    ).fontFamily!;

    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height ?? _defaultHeight,
      letterSpacing: letterSpacing,
    ).copyWith(fontFamilyFallback: [khmerFont]);
  }

  // Display
  static TextStyle get displayLarge => _style(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // Headings
  static TextStyle get h1 => _style(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle get h2 => _style(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle get h3 => _style(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body
  static TextStyle get bodyLarge => _style(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static TextStyle get body => _style(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyMedium => _style(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodySemiBold => _style(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Caption / Label
  static TextStyle get caption => _style(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static TextStyle get label => _style(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textLabel,
    letterSpacing: 0,
  );

  // Metric / Number display
  static TextStyle get metric => _style(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static TextStyle get metricSmall => _style(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.25,
  );

  // Button
  static TextStyle get button => _style(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
    letterSpacing: 0,
    height: 1.35,
  );

  // Link
  static TextStyle get link => _style(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryBlue,
  );

  // White variants
  static TextStyle get h1White => h1.copyWith(color: AppColors.textWhite);
  static TextStyle get h2White => h2.copyWith(color: AppColors.textWhite);
  static TextStyle get h3White => h3.copyWith(color: AppColors.textWhite);
  static TextStyle get bodyWhite => body.copyWith(color: AppColors.textWhite);
  static TextStyle get captionWhite =>
      caption.copyWith(color: AppColors.textWhite.withValues(alpha: 0.8));
}
