import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Locale notifier to manage app language and RTL/LTR direction
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en', 'US')) {
    _loadLocale();
  }

  static const String _localeKey = 'app_locale';

  /// Load saved locale from storage
  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_localeKey);

      if (languageCode != null) {
        if (languageCode == 'ar') {
          state = const Locale('ar', 'SA');
        } else {
          state = const Locale('en', 'US');
        }
      }
    } catch (e) {
      // If there's an error, keep default English
      state = const Locale('en', 'US');
    }
  }

  /// Toggle between English and Arabic
  Future<void> toggleLanguage() async {
    if (state.languageCode == 'en') {
      await setLocale(const Locale('ar', 'SA'));
    } else {
      await setLocale(const Locale('en', 'US'));
    }
  }

  /// Set specific locale
  Future<void> setLocale(Locale locale) async {
    state = locale;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
    } catch (e) {
      // Failed to save, but state is already updated
    }
  }

  /// Check if current locale is RTL
  bool get isRTL => state.languageCode == 'ar';

  /// Get current language name
  String get currentLanguageName {
    return state.languageCode == 'ar' ? 'العربية' : 'English';
  }

  /// Get opposite language name (for toggle button)
  String get toggleLanguageName {
    return state.languageCode == 'ar' ? 'English' : 'العربية';
  }
}

/// Provider for locale management
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
