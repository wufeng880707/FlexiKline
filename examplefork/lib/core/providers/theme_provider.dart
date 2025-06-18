import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../lang/generated/l10n.dart';
import '../utils/cache_util.dart';

const _cacheKeyTheme = 'cache_key_theme';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    final String? theme = CacheUtil.getString(_cacheKeyTheme);
    if (theme != null) {
      state = ThemeMode.values.firstWhere((e) => e.name == theme, orElse: () => ThemeMode.system);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state != mode) {
      CacheUtil.putString(_cacheKeyTheme, mode.name);
      state = mode;
    }
  }

  String convert(ThemeMode mode, {AppLocalizations? appLocalizations}) {
    appLocalizations ??= AppLocalizations.current;
    switch (mode) {
      case ThemeMode.system:
        return appLocalizations.themeModeSystem;
      case ThemeMode.light:
        return appLocalizations.themeModeLight;
      case ThemeMode.dark:
        return appLocalizations.themeModeDark;
    }
  }
}

final themeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});
