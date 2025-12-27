import 'package:flutter/material.dart';
import 'app_localizations.dart';

/// Extension for easy access to localizations from BuildContext
extension LocalizationExtension on BuildContext {
  /// Get AppLocalizations instance
  AppLocalizations get loc => AppLocalizations.of(this);

  /// Check if current locale is RTL
  bool get isRTL => Localizations.localeOf(this).languageCode == 'ar';

  /// Get current locale
  Locale get currentLocale => Localizations.localeOf(this);
}
