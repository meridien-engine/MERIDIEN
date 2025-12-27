import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/locale_provider.dart';

/// Language toggle button for switching between English and Arabic
class LanguageToggleButton extends ConsumerWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeNotifier = ref.read(localeProvider.notifier);
    final currentLocale = ref.watch(localeProvider);
    final isArabic = currentLocale.languageCode == 'ar';

    return IconButton(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.language_rounded,
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            isArabic ? 'EN' : 'ع',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      tooltip: isArabic ? 'Switch to English' : 'التبديل إلى العربية',
      onPressed: () async {
        await localeNotifier.toggleLanguage();
      },
    );
  }
}

/// Alternative compact version - just shows language code
class LanguageToggleButtonCompact extends ConsumerWidget {
  const LanguageToggleButtonCompact({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeNotifier = ref.read(localeProvider.notifier);
    final currentLocale = ref.watch(localeProvider);
    final isArabic = currentLocale.languageCode == 'ar';

    return TextButton.icon(
      icon: const Icon(Icons.translate_rounded, size: 18),
      label: Text(
        isArabic ? 'English' : 'عربي',
        style: const TextStyle(fontSize: 13),
      ),
      onPressed: () async {
        await localeNotifier.toggleLanguage();
      },
    );
  }
}
