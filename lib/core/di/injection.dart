import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:local_auth/local_auth.dart';

import '../constants/app_constants.dart';
import '../config/environment.dart';
import '../network/dio_client.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../network/interceptors/logging_interceptor.dart';
import '../network/interceptors/error_interceptor.dart';
import '../storage/secure_storage.dart';
import '../storage/preferences_storage.dart';
import '../error/error_handler.dart';
import '../utils/logger.dart';

import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  await _registerExternalDependencies();
  getIt.init();
  AppLogger.info('Dependency injection configured successfully');
}

Future<void> _registerExternalDependencies() async {
  // Register external dependencies that require async initialization
  
  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  
  // PackageInfo
  final packageInfo = await PackageInfo.fromPlatform();
  getIt.registerSingleton<PackageInfo>(packageInfo);
  
  // Other external dependencies
  getIt.registerSingleton<FlutterSecureStorage>(
    const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    ),
  );
  
  getIt.registerSingleton<Connectivity>(Connectivity());
  getIt.registerSingleton<DeviceInfoPlugin>(DeviceInfoPlugin());
  getIt.registerSingleton<LocalAuthentication>(LocalAuthentication());
  
  // Dio configuration
  final dio = Dio(
    BaseOptions(
      baseUrl: EnvironmentConfig.fullApiUrl,
      connectTimeout: EnvironmentConfig.apiTimeout,
      receiveTimeout: EnvironmentConfig.apiTimeout,
      sendTimeout: EnvironmentConfig.apiTimeout,
      headers: EnvironmentConfig.skyAngelHeaders,
    ),
  );
  
  // Add interceptors (storage services will be available after getIt.init())
  dio.interceptors.addAll([
    LoggingInterceptor(),
    AuthInterceptor(),
    ErrorInterceptor(),
  ]);
  
  getIt.registerSingleton<Dio>(dio);
}


// Service Locator helpers
T locate<T extends Object>() => getIt<T>();

Future<void> resetDependencies() async {
  await getIt.reset();
  await configureDependencies();
}

void registerTestDependencies() {
  // Register test-specific dependencies
  // This method should be called in tests
}

// Lazy registration for heavy dependencies
Future<void> registerLazyDependencies() async {
  // Register dependencies that should be loaded lazily
  // This can be called after app initialization
}

// Feature-specific dependency registration
Future<void> registerAuthDependencies() async {
  // Auth dependencies are registered automatically via @Injectable annotations
  // This method can be used for manual registrations if needed
}

Future<void> registerMapDependencies() async {
  // Register map-specific dependencies
}

Future<void> registerCrimeDependencies() async {
  // Register crime data dependencies
}

Future<void> registerAlertDependencies() async {
  // Register alert-specific dependencies
}

Future<void> registerAnalyticsDependencies() async {
  // Register analytics dependencies
}

// Conditional registration based on platform or feature flags
Future<void> registerPlatformDependencies() async {
  // Register platform-specific dependencies
}

// Clean up resources
Future<void> disposeDependencies() async {
  await getIt.reset();
  AppLogger.info('Dependencies disposed');
}