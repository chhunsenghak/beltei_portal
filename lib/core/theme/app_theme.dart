import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

class AppTheme {
  AppTheme._();

  static final String _khmerFont = GoogleFonts.notoSansKhmer().fontFamily!;

  static TextTheme _textTheme(TextTheme base) {
    return GoogleFonts.interTextTheme(
      base,
    ).apply(fontFamilyFallback: [_khmerFont], heightFactor: 1.08);
  }

  // A getter (not a cached field) so it re-resolves from the current
  // AppColors brightness every time the app rebuilds after a theme change.
  static ThemeData get current => ThemeData(
    useMaterial3: true,
    brightness: AppColors.brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryNavy,
      brightness: AppColors.brightness,
      primary: AppColors.primaryNavy,
      surface: AppColors.bgPage,
    ),
    scaffoldBackgroundColor: AppColors.bgPage,
    textTheme: _textTheme(
      AppColors.brightness == Brightness.dark
          ? ThemeData.dark().textTheme
          : ThemeData.light().textTheme,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.bgPage,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),
    cardTheme: CardThemeData(
      color: AppColors.bgCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        side: BorderSide(color: AppColors.border),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: AppColors.textWhite,
        minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
        ),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bgCard,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        borderSide: BorderSide(color: AppColors.primaryBlue, width: 1.5),
      ),
      hintStyle: TextStyle(color: AppColors.textLabel, fontSize: 14),
    ),
    dividerTheme: DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.bgCard,
      selectedItemColor: AppColors.primaryNavy,
      unselectedItemColor: AppColors.textSecondary,
      showUnselectedLabels: true,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) {
          return AppColors.textSecondary.withValues(alpha: 0.6);
        }
        return AppColors.textSecondary.withValues(alpha: 0.3);
      }),
      thickness: WidgetStateProperty.all(8.0),
      radius: const Radius.circular(4.0),
      interactive: true,
    ),
  );
}
