#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

void main() async {
  print('🔗 Probando endpoints del servidor SkyAngel (Elastic Beanstalk)...\n');
  
  const String baseUrl = 'http://skyangel-mock-prod.eba-mtya3rnt.us-east-1.elasticbeanstalk.com';
  
  // Lista de endpoints para probar basados en el backend Python actual
  final Map<String, String> endpoints = {
    // Endpoints básicos
    'Health Check': '$baseUrl/health',
    'Root': '$baseUrl/',
    
    // Endpoints de login y autenticación
    'Login': '$baseUrl/login',
    'Registro': '$baseUrl/registro',
    
    // Endpoints de catálogos
    'Catálogos Municipios': '$baseUrl/catalogos_municipios',
    'Catálogos Años': '$baseUrl/cat_anios',
    'Catálogos Delitos': '$baseUrl/cat_delitos_secretariado',
    'Catálogos Modalidad': '$baseUrl/cat_modalidad',
    'Catálogos Tipo Delito': '$baseUrl/cat_tipo_de_delito',
    'Catálogos Subtipo Delito': '$baseUrl/cat_subtipo_de_delito',
    
    // Endpoints de datos geográficos
    'Datos Geográficos Entidad': '$baseUrl/datosGeograficosEntidad',
    'Datos Geográficos Municipios': '$baseUrl/datosGeograficosMunicipios',
    'Mallados': '$baseUrl/mallados',
    'Mallado Municipios': '$baseUrl/mallado_municipios',
    'Polígonos': '$baseUrl/poligonos',
    
    // Endpoints de delitos
    'Delitos Secretariado Municipio': '$baseUrl/delitos_secretariado_municipio',
    'JSON Delitos': '$baseUrl/json_delitos',
    'Incidencias por Año': '$baseUrl/incidencias_por_anio',
    
    // Endpoints de puntos de interés
    'Puntos de Interés': '$baseUrl/puntos_interes',
    'Accidentes Tránsito': '$baseUrl/accidentes_transito_punto_interes',
    'Punto Ferroviarios': '$baseUrl/punto_ferroviarios',
    
    // Endpoints de gráficas
    'Gráficas Secretariado Barras': '$baseUrl/graficas_secretariadoBarras',
    'Gráficas Secretariado Pie': '$baseUrl/graficas_secretariadoPieAnuales',
    'Gráficas ANERPV': '$baseUrl/graficas_anerpv_y_secretariado_AcumBarras',
    
    // Endpoints de alertas
    'Alertas': '$baseUrl/alertas',
    'Scheduler Alertas': '$baseUrl/scheduler_alertas',
    
    // Endpoints de mapas
    'Hexágonos de Riesgos': '$baseUrl/hexagonosDeRiesgos',
    'Mapas': '$baseUrl/mapas',
    
    // Endpoints específicos de datos
    'Sum Delitos Municipio': '$baseUrl/sum_delitos_municipio_mes',
    'Sum Delitos Entidad ANERPV': '$baseUrl/sum_delitos_entidad_mes_anerpv',
    'JSON Getter Secretariado': '$baseUrl/json_getter_sec',
    'JSON Getter ANERPV': '$baseUrl/json_getter_anerpv_mun',
    'JSON Getter SkyAngel': '$baseUrl/json_getter_sky',
  };
  
  print('🎯 Probando endpoints específicos del backend Python:\n');
  
  int successCount = 0;
  int totalCount = endpoints.length;
  final List<String> workingEndpoints = [];
  final List<String> failingEndpoints = [];
  
  for (final entry in endpoints.entries) {
    final String name = entry.key;
    final String url = entry.value;
    
    try {
      print('📡 $name');
      print('   🔗 $url');
      
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      
      final request = await client.getUrl(Uri.parse(url));
      request.headers.set('Accept', 'application/json');
      request.headers.set('User-Agent', 'SkyAngel-Mobile/1.0');
      request.headers.set('Content-Type', 'application/json');
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('   ✅ ${response.statusCode} - OK');
        
        try {
          final jsonData = json.decode(responseBody);
          if (jsonData is Map) {
            print('   📄 JSON: ${jsonData.keys.length} campos');
            if (jsonData.containsKey('data')) {
              print('   📊 Contiene datos');
            }
          } else if (jsonData is List) {
            print('   📄 Array: ${jsonData.length} elementos');
          }
        } catch (e) {
          print('   📄 Texto: ${responseBody.length} chars');
        }
        
        workingEndpoints.add(name);
        successCount++;
      } else if (response.statusCode == 405) {
        print('   ⚠️  ${response.statusCode} - Método no permitido (puede requerir POST)');
        failingEndpoints.add('$name (405)');
      } else if (response.statusCode == 404) {
        print('   ❌ ${response.statusCode} - No encontrado');
        failingEndpoints.add('$name (404)');
      } else {
        print('   ❌ ${response.statusCode} - Error');
        failingEndpoints.add('$name (${response.statusCode})');
      }
      
      client.close();
    } catch (e) {
      print('   ❌ Error: ${e.toString().split('\n').first}');
      failingEndpoints.add('$name (Error)');
    }
    
    print('');
  }
  
  print('📊 Resumen de conectividad:');
  print('  ✅ Exitosos: $successCount');
  print('  ❌ Fallidos: ${totalCount - successCount}');
  print('  📈 Éxito: ${((successCount / totalCount) * 100).toStringAsFixed(1)}%');
  
  if (workingEndpoints.isNotEmpty) {
    print('\n✅ Endpoints que funcionan:');
    for (final endpoint in workingEndpoints) {
      print('  • $endpoint');
    }
  }
  
  if (failingEndpoints.isNotEmpty) {
    print('\n❌ Endpoints con problemas:');
    for (final endpoint in failingEndpoints.take(10)) { // Mostrar solo los primeros 10
      print('  • $endpoint');
    }
    if (failingEndpoints.length > 10) {
      print('  • ... y ${failingEndpoints.length - 10} más');
    }
  }
  
  print('\n💡 Recomendaciones:');
  if (successCount > 0) {
    print('  ✅ El servidor está funcionando');
    print('  📝 Usar endpoints que respondan correctamente');
    print('  🔧 Ajustar URLs en la configuración de la app');
  } else {
    print('  ⚠️  Verificar que el backend esté ejecutándose');
    print('  🔍 Revisar logs del servidor en Elastic Beanstalk');
    print('  📋 Confirmar rutas implementadas en Flask/Python');
  }
  
  print('\n🔧 Configuración sugerida para Flutter:');
  print('  baseUrl: "$baseUrl"');
  print('  apiVersion: "" (sin prefijo)');
  print('  timeout: 30 segundos');
  
  print('\n📚 Próximos pasos:');
  print('  1. Usar solo endpoints que respondan 200');
  print('  2. Implementar manejo de errores 404/405');
  print('  3. Configurar retry logic para endpoints temporalmente indisponibles');
  print('  4. Implementar fallbacks para datos críticos');
}