import 'environment.dart';

/// Clase que define todos los endpoints de la API de SkyAngel
/// Basado en el análisis del backend Python existente
class ApiEndpoints {
  // Base URLs
  static String get baseUrl => EnvironmentConfig.fullApiUrl;
  static String get wsUrl => EnvironmentConfig.wsUrl;
  
  // === AUTENTICACIÓN ===
  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get logout => '$baseUrl/auth/logout';
  static String get refreshToken => '$baseUrl/auth/refresh';
  static String get forgotPassword => '$baseUrl/auth/forgot-password';
  static String get resetPassword => '$baseUrl/auth/reset-password';
  static String get verifyEmail => '$baseUrl/auth/verify-email';
  static String get changePassword => '$baseUrl/auth/change-password';
  static String get validateEmail => '$baseUrl/validar_correo';
  static String get checkToken => '$baseUrl/check_token';
  
  // === DELITOS Y CRIMINALIDAD ===
  // Secretariado (Fuente oficial de datos de criminalidad)
  static String get secretariadoDelitos => '$baseUrl/secretariado/delitos';
  static String get secretariadoBarras => '$baseUrl/secretariado/barras';
  static String get secretariadoBarrasEstado => '$baseUrl/secretariado/barras/estado';
  static String get secretariadoBarrasMunicipio => '$baseUrl/secretariado/barras/municipio';
  static String get secretariadoBarrasAcum => '$baseUrl/secretariado/barras/acumulado';
  static String get secretariadoPieAnuales => '$baseUrl/secretariado/pie/anuales';
  static String get secretariadoPieModalidad => '$baseUrl/secretariado/pie/modalidad';
  static String get secretariadoPieSubtipo => '$baseUrl/secretariado/pie/subtipo';
  static String get secretariadoPieTipo => '$baseUrl/secretariado/pie/tipo';
  static String get secretariadoScatterAA => '$baseUrl/secretariado/scatter/anio-anterior';
  
  // ANERPV (Asociación Nacional de Empresas de Rastreo y Protección Vehicular)
  static String get anerpvDelitos => '$baseUrl/anerpv/delitos';
  static String get anerpvMunicipio => '$baseUrl/anerpv/municipio';
  static String get anerpvModalidad => '$baseUrl/anerpv/modalidad';
  static String get anerpvEntidad => '$baseUrl/anerpv/entidad';
  static String get anerpvNacional => '$baseUrl/anerpv/nacional';
  
  // SkyAngel (Datos propios)
  static String get skyAngelDelitos => '$baseUrl/skyangel/delitos';
  static String get skyAngelMunicipio => '$baseUrl/skyangel/municipio';
  static String get skyAngelReacciones => '$baseUrl/skyangel/reacciones';
  static String get skyAngelIncidencias => '$baseUrl/skyangel/incidencias';
  
  // Fuentes Externas
  static String get fuentesExternas => '$baseUrl/fuentes-externas';
  static String get fuentesExternasBarras => '$baseUrl/fuentes-externas/barras';
  static String get fuentesExternasPie => '$baseUrl/fuentes-externas/pie';
  static String get fuentesExternasScatter => '$baseUrl/fuentes-externas/scatter';
  static String get fuentesExternasTabla => '$baseUrl/fuentes-externas/tabla';
  static String get fuentesExternasVelas => '$baseUrl/fuentes-externas/velas';
  
  // === MAPAS Y GEOGRAFÍA ===
  static String get mapas => '$baseUrl/mapas';
  static String get municipios => '$baseUrl/municipios';
  static String get entidades => '$baseUrl/entidades';
  static String get poligonos => '$baseUrl/poligonos';
  static String get mallados => '$baseUrl/mallados';
  static String get malladosMunicipios => '$baseUrl/mallados/municipios';
  static String get hexagonos => '$baseUrl/hexagonos';
  
  // === PUNTOS DE INTERÉS ===
  static String get puntosInteres => '$baseUrl/puntos-interes';
  static String get accidentesTransito => '$baseUrl/puntos-interes/accidentes-transito';
  static String get ferroviarios => '$baseUrl/puntos-interes/ferroviarios';
  static String get agenciasMinisterio => '$baseUrl/puntos-interes/agencias-ministerio';
  static String get guardiasNacionales => '$baseUrl/puntos-interes/guardias-nacionales';
  static String get casetas => '$baseUrl/puntos-interes/casetas';
  static String get corralones => '$baseUrl/puntos-interes/corralones';
  static String get paraderos => '$baseUrl/puntos-interes/paraderos';
  static String get pensiones => '$baseUrl/puntos-interes/pensiones';
  static String get cobertura => '$baseUrl/puntos-interes/cobertura';
  
  // === RUTAS Y NAVEGACIÓN ===
  static String get rutas => '$baseUrl/rutas';
  static String get rutasSeguras => '$baseUrl/rutas/seguras';
  static String get rutasOptimizadas => '$baseUrl/rutas/optimizadas';
  static String get rutasRiesgo => '$baseUrl/rutas/riesgo';
  static String get rutasAlternativas => '$baseUrl/rutas/alternativas';
  
  // === ALERTAS Y NOTIFICACIONES ===
  static String get alertas => '$baseUrl/alertas';
  static String get alertasActivas => '$baseUrl/alertas/activas';
  static String get alertasHistorial => '$baseUrl/alertas/historial';
  static String get alertasScheduler => '$baseUrl/alertas/scheduler';
  static String get notificaciones => '$baseUrl/notificaciones';
  
  // === GRÁFICAS Y ANÁLISIS ===
  static String get graficas => '$baseUrl/graficas';
  static String get graficasBarras => '$baseUrl/graficas/barras';
  static String get graficasPie => '$baseUrl/graficas/pie';
  static String get graficasScatter => '$baseUrl/graficas/scatter';
  static String get graficasLinea => '$baseUrl/graficas/linea';
  static String get graficasAcumulado => '$baseUrl/graficas/acumulado';
  static String get graficasComparativa => '$baseUrl/graficas/comparativa';
  
  // === CATÁLOGOS ===
  static String get catalogos => '$baseUrl/catalogos';
  static String get catAnios => '$baseUrl/catalogos/anios';
  static String get catDelitos => '$baseUrl/catalogos/delitos';
  static String get catModalidades => '$baseUrl/catalogos/modalidades';
  static String get catTiposDelito => '$baseUrl/catalogos/tipos-delito';
  static String get catSubtiposDelito => '$baseUrl/catalogos/subtipos-delito';
  static String get catBienJuridico => '$baseUrl/catalogos/bien-juridico';
  static String get catMunicipios => '$baseUrl/catalogos/municipios';
  static String get catEntidades => '$baseUrl/catalogos/entidades';
  
  // === USUARIO Y PERFIL ===
  static String get perfil => '$baseUrl/perfil';
  static String get configuraciones => '$baseUrl/configuraciones';
  static String get preferencias => '$baseUrl/preferencias';
  static String get historial => '$baseUrl/historial';
  
  // === WEBSOCKETS ===
  static String get wsAlertas => '$wsUrl/ws/alertas';
  static String get wsNotificaciones => '$wsUrl/ws/notificaciones';
  static String get wsReacciones => '$wsUrl/ws/reacciones';
  static String get wsIncidencias => '$wsUrl/ws/incidencias';
  
  // === MÉTODOS HELPER ===
  
  /// Construye URL para gráficas específicas con parámetros
  static String buildGraficaUrl({
    required String tipo, // barras, pie, scatter, etc.
    required String fuente, // secretariado, anerpv, skyangel
    Map<String, dynamic>? params,
  }) {
    String url = '$baseUrl/graficas/$fuente/$tipo';
    
    if (params != null && params.isNotEmpty) {
      final queryParams = params.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');
      url += '?$queryParams';
    }
    
    return url;
  }
  
  /// Construye URL para delitos con filtros
  static String buildDelitosUrl({
    required String fuente, // secretariado, anerpv, skyangel
    String? municipio,
    String? entidad,
    String? tipoDelito,
    String? modalidad,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) {
    String url = '$baseUrl/$fuente/delitos';
    final Map<String, String> params = {};
    
    if (municipio != null) params['municipio'] = municipio;
    if (entidad != null) params['entidad'] = entidad;
    if (tipoDelito != null) params['tipo_delito'] = tipoDelito;
    if (modalidad != null) params['modalidad'] = modalidad;
    if (fechaInicio != null) params['fecha_inicio'] = fechaInicio.toIso8601String();
    if (fechaFin != null) params['fecha_fin'] = fechaFin.toIso8601String();
    
    if (params.isNotEmpty) {
      final queryParams = params.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      url += '?$queryParams';
    }
    
    return url;
  }
  
  /// Construye URL para mapas con filtros geográficos
  static String buildMapaUrl({
    double? latitud,
    double? longitud,
    double? radio,
    String? municipio,
    String? entidad,
    int? zoom,
  }) {
    String url = '$baseUrl/mapas';
    final Map<String, String> params = {};
    
    if (latitud != null) params['lat'] = latitud.toString();
    if (longitud != null) params['lng'] = longitud.toString();
    if (radio != null) params['radio'] = radio.toString();
    if (municipio != null) params['municipio'] = municipio;
    if (entidad != null) params['entidad'] = entidad;
    if (zoom != null) params['zoom'] = zoom.toString();
    
    if (params.isNotEmpty) {
      final queryParams = params.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      url += '?$queryParams';
    }
    
    return url;
  }
  
  /// Obtiene URL completa con dominio
  static String getFullUrl(String endpoint) {
    if (endpoint.startsWith('http')) {
      return endpoint;
    }
    return endpoint.startsWith('/') ? '$baseUrl$endpoint' : '$baseUrl/$endpoint';
  }
  
  /// Valida si una URL es del dominio de la API
  static bool isApiUrl(String url) {
    return url.startsWith(EnvironmentConfig.baseUrl);
  }
}