import 'dart:convert';

/// Servicio que proporciona datos mock para desarrollo
/// Permite desarrollar la UI sin depender del backend
class MockDataService {
  static const bool enableMocks = true;
  
  // Datos mock para municipios
  static List<Map<String, dynamic>> get municipios => [
    {
      'id': 1,
      'nombre': 'Ciudad de México',
      'entidad': 'Ciudad de México',
      'codigo': '09001',
      'latitud': 19.4326,
      'longitud': -99.1332,
      'poblacion': 9209944,
    },
    {
      'id': 2,
      'nombre': 'Guadalajara',
      'entidad': 'Jalisco',
      'codigo': '14039',
      'latitud': 20.6597,
      'longitud': -103.3496,
      'poblacion': 1385629,
    },
    {
      'id': 3,
      'nombre': 'Monterrey',
      'entidad': 'Nuevo León',
      'codigo': '19039',
      'latitud': 25.6866,
      'longitud': -100.3161,
      'poblacion': 1135512,
    },
    {
      'id': 4,
      'nombre': 'Puebla',
      'entidad': 'Puebla',
      'codigo': '21114',
      'latitud': 19.0413,
      'longitud': -98.2062,
      'poblacion': 1576259,
    },
    {
      'id': 5,
      'nombre': 'Tijuana',
      'entidad': 'Baja California',
      'codigo': '02004',
      'latitud': 32.5149,
      'longitud': -117.0382,
      'poblacion': 1810645,
    },
  ];
  
  // Datos mock para entidades
  static List<Map<String, dynamic>> get entidades => [
    {
      'id': 1,
      'nombre': 'Aguascalientes',
      'codigo': '01',
      'capital': 'Aguascalientes',
    },
    {
      'id': 2,
      'nombre': 'Baja California',
      'codigo': '02',
      'capital': 'Mexicali',
    },
    {
      'id': 3,
      'nombre': 'Baja California Sur',
      'codigo': '03',
      'capital': 'La Paz',
    },
    {
      'id': 9,
      'nombre': 'Ciudad de México',
      'codigo': '09',
      'capital': 'Ciudad de México',
    },
    {
      'id': 14,
      'nombre': 'Jalisco',
      'codigo': '14',
      'capital': 'Guadalajara',
    },
    {
      'id': 19,
      'nombre': 'Nuevo León',
      'codigo': '19',
      'capital': 'Monterrey',
    },
  ];
  
  // Datos mock para tipos de delito
  static List<Map<String, dynamic>> get tiposDelito => [
    {
      'id': 1,
      'nombre': 'Robo',
      'descripcion': 'Delitos de robo en todas sus modalidades',
      'color': '#FF5722',
    },
    {
      'id': 2,
      'nombre': 'Homicidio',
      'descripcion': 'Homicidios dolosos y culposos',
      'color': '#D32F2F',
    },
    {
      'id': 3,
      'nombre': 'Secuestro',
      'descripcion': 'Secuestros y privación ilegal de la libertad',
      'color': '#7B1FA2',
    },
    {
      'id': 4,
      'nombre': 'Extorsión',
      'descripcion': 'Extorsión y amenazas',
      'color': '#FF9800',
    },
    {
      'id': 5,
      'nombre': 'Narcotráfico',
      'descripcion': 'Delitos contra la salud',
      'color': '#795548',
    },
    {
      'id': 6,
      'nombre': 'Violencia Familiar',
      'descripcion': 'Violencia familiar y de género',
      'color': '#E91E63',
    },
  ];
  
  // Datos mock para delitos con estadísticas
  static List<Map<String, dynamic>> get delitosEstadisticas => [
    {
      'municipio': 'Ciudad de México',
      'entidad': 'Ciudad de México',
      'tipo_delito': 'Robo',
      'modalidad': 'Robo a transeúnte',
      'incidencias': 1547,
      'mes': '2024-12',
      'coordenadas': {'lat': 19.4326, 'lng': -99.1332},
      'nivel_riesgo': 'alto',
    },
    {
      'municipio': 'Guadalajara',
      'entidad': 'Jalisco',
      'tipo_delito': 'Robo',
      'modalidad': 'Robo de vehículo',
      'incidencias': 892,
      'mes': '2024-12',
      'coordenadas': {'lat': 20.6597, 'lng': -103.3496},
      'nivel_riesgo': 'medio',
    },
    {
      'municipio': 'Monterrey',
      'entidad': 'Nuevo León',
      'tipo_delito': 'Homicidio',
      'modalidad': 'Homicidio doloso',
      'incidencias': 45,
      'mes': '2024-12',
      'coordenadas': {'lat': 25.6866, 'lng': -100.3161},
      'nivel_riesgo': 'alto',
    },
    {
      'municipio': 'Tijuana',
      'entidad': 'Baja California',
      'tipo_delito': 'Narcotráfico',
      'modalidad': 'Posesión de drogas',
      'incidencias': 234,
      'mes': '2024-12',
      'coordenadas': {'lat': 32.5149, 'lng': -117.0382},
      'nivel_riesgo': 'crítico',
    },
  ];
  
  // Datos mock para alertas
  static List<Map<String, dynamic>> get alertas => [
    {
      'id': 1,
      'titulo': 'Incremento de robos en zona centro',
      'descripcion': 'Se ha detectado un incremento del 25% en robos a transeúnte en la zona centro durante las últimas 2 semanas.',
      'tipo': 'seguridad',
      'nivel': 'alto',
      'municipio': 'Ciudad de México',
      'fecha_creacion': '2024-12-20T10:30:00Z',
      'activa': true,
      'coordenadas': {'lat': 19.4326, 'lng': -99.1332},
    },
    {
      'id': 2,
      'titulo': 'Operativo policíaco en curso',
      'descripcion': 'Operativo policíaco en Av. Insurgentes. Se recomienda usar rutas alternas.',
      'tipo': 'trafico',
      'nivel': 'medio',
      'municipio': 'Ciudad de México',
      'fecha_creacion': '2024-12-20T08:15:00Z',
      'activa': true,
      'coordenadas': {'lat': 19.4200, 'lng': -99.1400},
    },
    {
      'id': 3,
      'titulo': 'Zona de riesgo identificada',
      'descripcion': 'Nueva zona de alto riesgo identificada en Ecatepec. Evitar circulación nocturna.',
      'tipo': 'seguridad',
      'nivel': 'crítico',
      'municipio': 'Ecatepec',
      'fecha_creacion': '2024-12-19T22:45:00Z',
      'activa': true,
      'coordenadas': {'lat': 19.6083, 'lng': -99.0608},
    },
  ];
  
  // Datos mock para puntos de interés
  static List<Map<String, dynamic>> get puntosInteres => [
    {
      'id': 1,
      'nombre': 'Hospital General',
      'tipo': 'hospital',
      'direccion': 'Av. Cuauhtémoc 330, Doctores',
      'municipio': 'Ciudad de México',
      'coordenadas': {'lat': 19.4103, 'lng': -99.1449},
      'telefono': '555-1234567',
      'horario': '24 horas',
    },
    {
      'id': 2,
      'nombre': 'Estación de Policía Centro',
      'tipo': 'policia',
      'direccion': 'Calle Regina 34, Centro',
      'municipio': 'Ciudad de México',
      'coordenadas': {'lat': 19.4267, 'lng': -99.1310},
      'telefono': '911',
      'horario': '24 horas',
    },
    {
      'id': 3,
      'nombre': 'Gasolinera PEMEX',
      'tipo': 'gasolinera',
      'direccion': 'Av. Insurgentes Sur 1234',
      'municipio': 'Ciudad de México',
      'coordenadas': {'lat': 19.3635, 'lng': -99.1708},
      'telefono': '555-9876543',
      'horario': '6:00 - 22:00',
    },
  ];
  
  // Datos mock para rutas seguras
  static List<Map<String, dynamic>> get rutasSeguras => [
    {
      'id': 1,
      'origen': {'lat': 19.4326, 'lng': -99.1332, 'nombre': 'Centro Histórico'},
      'destino': {'lat': 19.3635, 'lng': -99.1708, 'nombre': 'Zona Rosa'},
      'distancia_km': 8.5,
      'tiempo_estimado': 25,
      'nivel_riesgo': 'bajo',
      'puntos_ruta': [
        {'lat': 19.4326, 'lng': -99.1332},
        {'lat': 19.4200, 'lng': -99.1400},
        {'lat': 19.4000, 'lng': -99.1500},
        {'lat': 19.3800, 'lng': -99.1600},
        {'lat': 19.3635, 'lng': -99.1708},
      ],
      'alertas_ruta': [],
    },
    {
      'id': 2,
      'origen': {'lat': 19.4326, 'lng': -99.1332, 'nombre': 'Centro Histórico'},
      'destino': {'lat': 19.5033, 'lng': -99.1471, 'nombre': 'Polanco'},
      'distancia_km': 12.3,
      'tiempo_estimado': 35,
      'nivel_riesgo': 'medio',
      'puntos_ruta': [
        {'lat': 19.4326, 'lng': -99.1332},
        {'lat': 19.4500, 'lng': -99.1400},
        {'lat': 19.4700, 'lng': -99.1450},
        {'lat': 19.4900, 'lng': -99.1460},
        {'lat': 19.5033, 'lng': -99.1471},
      ],
      'alertas_ruta': [
        {
          'tipo': 'construccion',
          'descripcion': 'Obras en Av. Reforma',
          'coordenadas': {'lat': 19.4700, 'lng': -99.1450},
        }
      ],
    },
  ];
  
  // Datos mock para gráficas
  static Map<String, dynamic> get graficasBarras => {
    'titulo': 'Incidencias por Tipo de Delito',
    'periodo': '2024-12',
    'datos': [
      {'tipo': 'Robo', 'incidencias': 2547, 'color': '#FF5722'},
      {'tipo': 'Homicidio', 'incidencias': 156, 'color': '#D32F2F'},
      {'tipo': 'Secuestro', 'incidencias': 23, 'color': '#7B1FA2'},
      {'tipo': 'Extorsión', 'incidencias': 89, 'color': '#FF9800'},
      {'tipo': 'Narcotráfico', 'incidencias': 445, 'color': '#795548'},
      {'tipo': 'Violencia Familiar', 'incidencias': 678, 'color': '#E91E63'},
    ],
  };
  
  static Map<String, dynamic> get graficasPie => {
    'titulo': 'Distribución de Delitos por Modalidad',
    'periodo': '2024-12',
    'total': 3938,
    'datos': [
      {'modalidad': 'Robo a transeúnte', 'porcentaje': 35.2, 'incidencias': 1386},
      {'modalidad': 'Robo de vehículo', 'porcentaje': 28.7, 'incidencias': 1130},
      {'modalidad': 'Robo a casa habitación', 'porcentaje': 15.6, 'incidencias': 615},
      {'modalidad': 'Robo a negocio', 'porcentaje': 12.3, 'incidencias': 485},
      {'modalidad': 'Otros', 'porcentaje': 8.2, 'incidencias': 322},
    ],
  };
  
  // Método principal para obtener datos mock
  static Map<String, dynamic> getMockData(String endpoint) {
    switch (endpoint) {
      case '/catalogos/municipios':
        return {'data': municipios, 'count': municipios.length};
      
      case '/catalogos/entidades':
        return {'data': entidades, 'count': entidades.length};
      
      case '/catalogos/tipos-delito':
        return {'data': tiposDelito, 'count': tiposDelito.length};
      
      case '/delitos/estadisticas':
        return {'data': delitosEstadisticas, 'count': delitosEstadisticas.length};
      
      case '/alertas':
        return {'data': alertas, 'count': alertas.length};
      
      case '/puntos-interes':
        return {'data': puntosInteres, 'count': puntosInteres.length};
      
      case '/rutas/seguras':
        return {'data': rutasSeguras, 'count': rutasSeguras.length};
      
      case '/graficas/barras':
        return graficasBarras;
      
      case '/graficas/pie':
        return graficasPie;
      
      case '/health':
        return {
          'status': 'ok',
          'timestamp': DateTime.now().toIso8601String(),
          'version': '1.0.0',
          'environment': 'mock',
        };
      
      default:
        return {
          'error': 'Endpoint not found',
          'message': 'Mock data not available for endpoint: $endpoint',
          'available_endpoints': [
            '/catalogos/municipios',
            '/catalogos/entidades',
            '/catalogos/tipos-delito',
            '/delitos/estadisticas',
            '/alertas',
            '/puntos-interes',
            '/rutas/seguras',
            '/graficas/barras',
            '/graficas/pie',
            '/health',
          ],
        };
    }
  }
  
  // Método para simular delay de red
  static Future<Map<String, dynamic>> getMockDataAsync(
    String endpoint, {
    Duration delay = const Duration(milliseconds: 500),
  }) async {
    await Future.delayed(delay);
    return getMockData(endpoint);
  }
  
  // Método para generar datos aleatorios para testing
  static List<Map<String, dynamic>> generateRandomCrimes(int count) {
    final List<Map<String, dynamic>> crimes = [];
    final random = DateTime.now().millisecondsSinceEpoch;
    
    for (int i = 0; i < count; i++) {
      crimes.add({
        'id': i + 1,
        'tipo': tiposDelito[(i + random) % tiposDelito.length]['nombre'],
        'municipio': municipios[(i + random) % municipios.length]['nombre'],
        'incidencias': 10 + (i * 17) % 200,
        'fecha': DateTime.now().subtract(Duration(days: i)).toIso8601String(),
        'coordenadas': {
          'lat': 19.4326 + ((i * 0.001) % 0.5),
          'lng': -99.1332 + ((i * 0.001) % 0.5),
        },
      });
    }
    
    return crimes;
  }
}