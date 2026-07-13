import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_colors.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<ui.PointerDeviceKind> get dragDevices => {
        ui.PointerDeviceKind.touch,
        ui.PointerDeviceKind.mouse,
        ui.PointerDeviceKind.trackpad,
      };
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final brandColor = ref.watch(brandColorProvider);
    final locale = ref.watch(localeProvider);

    final effectiveBrightness = switch (themeMode) {
      ThemeMode.dark => Brightness.dark,
      ThemeMode.light => Brightness.light,
      ThemeMode.system => ui.PlatformDispatcher.instance.platformBrightness,
    };
    AppColors.setBrightness(effectiveBrightness);
    AppColors.setBrandColors(brandColor.lightColor, brandColor.darkColor);

    return MaterialApp.router(
      title: 'BELTEI Portal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.current,
      scrollBehavior: AppScrollBehavior(),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: appRouter,
    );
  }
}
