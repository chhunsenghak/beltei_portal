import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';

const _kThemeModePrefKey = 'theme_mode';
const _kBrandColorPrefKey = 'brand_color';

enum BrandColor {
  navy('Navy', Color(0xFF1A237E), Color(0xFF5C6BC0)),
  blue('Blue', Color(0xFF2563EB), Color(0xFF60A5FA)),
  green('Green', Color(0xFF16A34A), Color(0xFF4ADE80)),
  purple('Purple', Color(0xFF7C3AED), Color(0xFFA78BFA)),
  red('Red', Color(0xFFDC2626), Color(0xFFF87171)),
  orange('Orange', Color(0xFFEA580C), Color(0xFFFB923C)),
  teal('Teal', Color(0xFF0D9488), Color(0xFF2DD4BF));

  final String label;
  final Color lightColor;
  final Color darkColor;

  const BrandColor(this.label, this.lightColor, this.darkColor);
}

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kThemeModePrefKey);
    state = ThemeMode.values.firstWhere(
      (m) => m.name == saved,
      orElse: () => ThemeMode.dark,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeModePrefKey, mode.name);
  }
}

class BrandColorNotifier extends StateNotifier<BrandColor> {
  BrandColorNotifier() : super(BrandColor.navy) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kBrandColorPrefKey);
    final color = BrandColor.values.firstWhere(
      (c) => c.name == saved,
      orElse: () => BrandColor.navy,
    );
    state = color;
    AppColors.setBrandColors(color.lightColor, color.darkColor);
  }

  Future<void> setBrandColor(BrandColor color) async {
    state = color;
    AppColors.setBrandColors(color.lightColor, color.darkColor);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kBrandColorPrefKey, color.name);
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) => ThemeModeNotifier());

final brandColorProvider =
    StateNotifierProvider<BrandColorNotifier, BrandColor>((ref) => BrandColorNotifier());
