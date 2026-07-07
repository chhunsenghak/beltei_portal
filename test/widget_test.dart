import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:beltei_portal/core/constants/app_colors.dart';

void main() {
  group('AppColors Tests', () {
    test('Default brightness is light', () {
      AppColors.setBrightness(Brightness.light);
      expect(AppColors.brightness, Brightness.light);
      expect(AppColors.primaryNavy, const Color(0xFF1A237E));
    });

    test('Dark brightness updates color values', () {
      AppColors.setBrightness(Brightness.dark);
      expect(AppColors.brightness, Brightness.dark);
      expect(AppColors.primaryNavy, const Color(0xFF5C6BC0));
    });
  });
}


