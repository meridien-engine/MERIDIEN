import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/locale_provider.dart';
import 'core/localization/app_localizations_delegate.dart';
import 'data/services/storage_service.dart';
import 'data/providers/dio_provider.dart';
import 'routes/app_router.dart';
import 'features/auth/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage services
  const secureStorage = FlutterSecureStorage();
  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(
    secureStorage: secureStorage,
    prefs: prefs,
  );

  runApp(
    ProviderScope(
      overrides: [
        // Override storage service provider with actual instance
        storageServiceProvider.overrideWithValue(storageService),
      ],
      child: const MeridienApp(),
    ),
  );
}

class MeridienApp extends ConsumerStatefulWidget {
  const MeridienApp({super.key});

  @override
  ConsumerState<MeridienApp> createState() => _MeridienAppState();
}

class _MeridienAppState extends ConsumerState<MeridienApp> {
  @override
  void initState() {
    super.initState();
    // Check auth status on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'MERIDIEN',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      // RTL Support - Dynamic based on locale provider
      locale: locale,
      supportedLocales: const [
        Locale('en', 'US'), // English (default)
        Locale('ar', 'SA'), // Arabic
      ],
      localizationsDelegates: const [
        AppLocalizationsDelegate(), // Our custom localizations
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      routerConfig: router,
    );
  }
}
