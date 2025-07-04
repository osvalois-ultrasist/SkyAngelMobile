enum Environment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  static const Environment _environment = Environment.development;
  
  static Environment get environment => _environment;
  
  static String get baseUrl {
    switch (_environment) {
      case Environment.development:
      case Environment.staging:
      case Environment.production:
        return 'http://skyangel-mock-prod.eba-mtya3rnt.us-east-1.elasticbeanstalk.com';
    }
  }
  
  static String get wsUrl {
    switch (_environment) {
      case Environment.development:
      case Environment.staging:
      case Environment.production:
        return 'ws://skyangel-mock-prod.eba-mtya3rnt.us-east-1.elasticbeanstalk.com';
    }
  }
  
  static String get apiVersion => ''; // Sin prefijo de versión
  
  static String get fullApiUrl => '$baseUrl$apiVersion';
  
  static bool get isProduction => _environment == Environment.production;
  
  static bool get isDevelopment => _environment == Environment.development;
  
  static bool get isStaging => _environment == Environment.staging;
  
  static bool get enableLogging => !isProduction;
  
  static bool get enableCrashlytics => isProduction || isStaging;
  
  static Duration get apiTimeout => const Duration(seconds: 30);
  
  static Duration get wsTimeout => const Duration(seconds: 10);
  
  // Endpoints específicos de SkyAngel
  static String get authEndpoint => '$fullApiUrl/auth';
  static String get delitosEndpoint => '$fullApiUrl/delitos';
  static String get riesgosEndpoint => '$fullApiUrl/riesgos';
  static String get rutasEndpoint => '$fullApiUrl/rutas';
  static String get alertasEndpoint => '$fullApiUrl/alertas';
  static String get mapasEndpoint => '$fullApiUrl/mapas';
  static String get graficasEndpoint => '$fullApiUrl/graficas';
  static String get catalogosEndpoint => '$fullApiUrl/catalogos';
  
  // WebSocket endpoints
  static String get alertasWsEndpoint => '$wsUrl/ws/alertas';
  static String get notificacionesWsEndpoint => '$wsUrl/ws/notificaciones';
  
  // Configuración de headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-API-Version': '1.0',
    'X-Platform': 'mobile',
    'X-App-Version': '1.0.0',
  };
  
  // Configuración de SSL para HTTP (temporal para desarrollo)
  static bool get allowHttpTraffic => true;
  
  // Endpoints específicos basados en el análisis del backend Python
  static String get secretariadoEndpoint => '$fullApiUrl/secretariado';
  static String get anerpvEndpoint => '$fullApiUrl/anerpv';
  static String get skyAngelEndpoint => '$fullApiUrl/skyangel';
  static String get fuentesExternasEndpoint => '$fullApiUrl/fuentes-externas';
  static String get municipiosEndpoint => '$fullApiUrl/municipios';
  static String get entidadesEndpoint => '$fullApiUrl/entidades';
  static String get reaccionesEndpoint => '$fullApiUrl/reacciones';
  static String get incidenciasEndpoint => '$fullApiUrl/incidencias';
  static String get puntosInteresEndpoint => '$fullApiUrl/puntos-interes';
  static String get malladosEndpoint => '$fullApiUrl/mallados';
  static String get poligonosEndpoint => '$fullApiUrl/poligonos';
  
  // Configuración específica para SkyAngel Mock API
  static Map<String, String> get skyAngelHeaders => {
    ...defaultHeaders,
    'X-SkyAngel-Source': 'mobile-app',
    'X-Mock-Environment': 'elasticbeanstalk',
  };
  
  static void printConfiguration() {
    print('🔧 Environment Configuration:');
    print('   Environment: ${_environment.name}');
    print('   Base URL: $baseUrl');
    print('   WebSocket URL: $wsUrl');
    print('   Full API URL: $fullApiUrl');
    print('   Logging Enabled: $enableLogging');
    print('   Crashlytics Enabled: $enableCrashlytics');
    print('   Allow HTTP: $allowHttpTraffic');
  }
}