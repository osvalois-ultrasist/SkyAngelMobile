import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/di/injection.dart';
import 'core/constants/app_constants.dart';
import 'core/config/environment.dart';
import 'core/utils/logger.dart';
import 'shared/themes/app_theme.dart';
import 'features/app/presentation/pages/app_page.dart';
import 'core/router/app_router.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicialización básica y crítica solamente
  await _initializeCriticalServices();
  
  runApp(
    const ProviderScope(
      child: SkyAngelApp(),
    ),
  );
}

/// Inicialización crítica que debe completarse antes de mostrar la UI
Future<void> _initializeCriticalServices() async {
  try {
    AppLogger.info('Initializing critical services...');
    
    // Set system UI overlay style first
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
    
    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    // Initialize critical dependencies needed for app startup
    await configureDependencies();
    AppLogger.info('Critical dependencies initialized');
    
    AppLogger.info('Critical services initialized successfully');
  } catch (e, stackTrace) {
    AppLogger.error('Error initializing critical services', error: e, stackTrace: stackTrace);
    // No rethrow aquí para evitar que la app no arranque
  }
}

/// Inicialización completa que se ejecuta en el splash screen
Future<void> initializeApp() async {
  try {
    AppLogger.info('Starting full app initialization...');
    
    // Initialize Firebase (with fallback)
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      AppLogger.info('Firebase initialized successfully');
    } catch (e) {
      AppLogger.warning('Firebase initialization failed, continuing without Firebase: $e');
      // Continue without Firebase - the app can still work
    }
    
    // Initialize Hive
    await Hive.initFlutter();
    AppLogger.info('Hive initialized');
    
    // Print environment configuration
    EnvironmentConfig.printConfiguration();
    
    AppLogger.info('SkyAngel Mobile initialized successfully');
  } catch (e, stackTrace) {
    AppLogger.error('Error initializing app', error: e, stackTrace: stackTrace);
    rethrow;
  }
}

class SkyAngelApp extends ConsumerWidget {
  const SkyAngelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = ref.watch(appThemeProvider);
    
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: appTheme.lightTheme,
      darkTheme: appTheme.darkTheme,
      themeMode: appTheme.themeMode,
      routerConfig: AppRouter.router,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}