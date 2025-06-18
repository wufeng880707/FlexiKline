import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _localeKey = 'app_locale';

final localeProvider = StateNotifierProvider<AppLocaleNotifier, Locale>((ref) {
  return AppLocaleNotifier();
});

class AppLocaleNotifier extends StateNotifier<Locale> {
  AppLocaleNotifier() : super(const Locale('zh', 'CN')) {
    _loadSavedLocale();
  }

  static const supportedLocales = [Locale('en'), Locale('zh', 'CN')];

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedLocale = prefs.getString(_localeKey);
    if (savedLocale != null) {
      final parts = savedLocale.split('_');
      state = parts.length > 1 ? Locale(parts[0], parts[1]) : Locale(parts[0]);
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;

    final prefs = await SharedPreferences.getInstance();
    final localeStr =
        locale.countryCode == null
            ? locale.languageCode
            : '${locale.languageCode}_${locale.countryCode}';

    await prefs.setString(_localeKey, localeStr);
    state = locale;
  }

  bool isSupported(Locale locale) {
    return supportedLocales.contains(locale);
  }
}
