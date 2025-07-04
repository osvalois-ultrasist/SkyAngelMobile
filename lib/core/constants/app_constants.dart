class AppConstants {
  static const String appName = 'SkyAngel Mobile';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.skyangel.mobile';
  
  // API Configuration
  static const String baseUrl = 'http://skyangel-mock-prod.eba-mtya3rnt.us-east-1.elasticbeanstalk.com';
  static const String wsUrl = 'ws://skyangel-mock-prod.eba-mtya3rnt.us-east-1.elasticbeanstalk.com';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration wsTimeout = Duration(seconds: 10);
  
  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userIdKey = 'user_id';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String onboardingKey = 'onboarding_completed';
  static const String biometricKey = 'biometric_enabled';
  static const String locationKey = 'location_enabled';
  static const String notificationKey = 'notification_enabled';
  
  // Map Configuration
  static const double defaultLatitude = 19.4326;
  static const double defaultLongitude = -99.1332;
  static const double defaultZoom = 10.0;
  static const double maxZoom = 18.0;
  static const double minZoom = 5.0;
  
  // Security Configuration
  static const int maxLoginAttempts = 3;
  static const Duration lockoutDuration = Duration(minutes: 15);
  static const int tokenRefreshThreshold = 300; // 5 minutes
  
  // UI Configuration
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration splashDuration = Duration(seconds: 3);
  
  // Feature Flags
  static const bool enableBiometric = true;
  static const bool enableOfflineMode = true;
  static const bool enableBackgroundLocation = true;
  static const bool enableRealTimeAlerts = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  
  // Cache Configuration
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 50 * 1024 * 1024; // 50MB
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  
  // Notification Categories
  static const String alertNotificationCategory = 'alerts';
  static const String newsNotificationCategory = 'news';
  static const String systemNotificationCategory = 'system';
  
  // Error Messages
  static const String genericErrorMessage = 'Ha ocurrido un error inesperado';
  static const String networkErrorMessage = 'Error de conexión a internet';
  static const String timeoutErrorMessage = 'Tiempo de espera agotado';
  static const String unauthorizedErrorMessage = 'Sesión expirada';
  static const String forbiddenErrorMessage = 'Acceso denegado';
  static const String notFoundErrorMessage = 'Recurso no encontrado';
  static const String validationErrorMessage = 'Datos inválidos';
  
  // Success Messages
  static const String loginSuccessMessage = 'Sesión iniciada correctamente';
  static const String logoutSuccessMessage = 'Sesión cerrada correctamente';
  static const String saveSuccessMessage = 'Guardado correctamente';
  static const String updateSuccessMessage = 'Actualizado correctamente';
  static const String deleteSuccessMessage = 'Eliminado correctamente';
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 50;
  
  // Regular Expressions
  static const String emailRegex = r'^[^\s@]+@[^\s@]+\.[^\s@]+$';
  static const String phoneRegex = r'^\+?[1-9]\d{1,14}$';
  static const String passwordRegex = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';
  
  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String isoDateFormat = 'yyyy-MM-ddTHH:mm:ss.SSSZ';
  
  // Hive Box Names
  static const String userBoxName = 'user_box';
  static const String settingsBoxName = 'settings_box';
  static const String cacheBoxName = 'cache_box';
  static const String alertsBoxName = 'alerts_box';
  static const String routesBoxName = 'routes_box';
  
  // Database Configuration
  static const String databaseName = 'skyangel.db';
  static const int databaseVersion = 1;
  
  // Map Layers
  static const String osmTileUrl = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String satelliteTileUrl = 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
  static const String terrainTileUrl = 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}';
  
  // Risk Levels
  static const String riskLevelLow = 'low';
  static const String riskLevelMedium = 'medium';
  static const String riskLevelHigh = 'high';
  static const String riskLevelCritical = 'critical';
  
  // Crime Types
  static const String crimeTypeRobbery = 'robbery';
  static const String crimeTypeTheft = 'theft';
  static const String crimeTypeHomicide = 'homicide';
  static const String crimeTypeKidnapping = 'kidnapping';
  static const String crimeTypeExtortion = 'extortion';
  static const String crimeTypeDrugTrafficking = 'drug_trafficking';
  
  // Data Sources
  static const String sourceSecretariado = 'secretariado';
  static const String sourceAnerpv = 'anerpv';
  static const String sourceSkyAngel = 'skyangel';
  static const String sourceFuenteExterna = 'fuente_externa';
  
  // Permissions
  static const String permissionLocation = 'location';
  static const String permissionCamera = 'camera';
  static const String permissionStorage = 'storage';
  static const String permissionNotification = 'notification';
  static const String permissionBiometric = 'biometric';
}