#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

void main() async {
  print('🔗 Probando conectividad con la API de SkyAngel...\n');
  
  const String baseUrl = 'http://skyangel-mock-prod.eba-mtya3rnt.us-east-1.elasticbeanstalk.com';
  
  // Lista de endpoints para probar
  final Map<String, String> endpoints = {
    'Health Check': '$baseUrl/health',
    'API Info': '$baseUrl/api/v1',
    'Catalogos': '$baseUrl/api/v1/catalogos',
    'Municipios': '$baseUrl/api/v1/municipios',
    'Entidades': '$baseUrl/api/v1/entidades',
    'Delitos Secretariado': '$baseUrl/api/v1/secretariado/delitos',
    'Delitos ANERPV': '$baseUrl/api/v1/anerpv/delitos',
    'Mapas': '$baseUrl/api/v1/mapas',
    'Puntos de Interés': '$baseUrl/api/v1/puntos-interes',
  };
  
  print('🎯 Probando endpoints de la API:\n');
  
  int successCount = 0;
  int totalCount = endpoints.length;
  
  for (final entry in endpoints.entries) {
    final String name = entry.key;
    final String url = entry.value;
    
    try {
      print('📡 Probando: $name');
      print('   URL: $url');
      
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      
      final request = await client.getUrl(Uri.parse(url));
      request.headers.set('Accept', 'application/json');
      request.headers.set('User-Agent', 'SkyAngel-Mobile-Test/1.0');
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('   ✅ Status: ${response.statusCode} - OK');
        
        // Intentar parsear JSON si es posible
        try {
          final jsonData = json.decode(responseBody);
          if (jsonData is Map) {
            print('   📄 Respuesta: JSON válido (${jsonData.keys.length} campos)');
          } else if (jsonData is List) {
            print('   📄 Respuesta: Array JSON (${jsonData.length} elementos)');
          }
        } catch (e) {
          print('   📄 Respuesta: ${responseBody.length} caracteres');
        }
        
        successCount++;
      } else {
        print('   ❌ Status: ${response.statusCode} - Error');
        print('   📄 Respuesta: ${responseBody.substring(0, responseBody.length > 100 ? 100 : responseBody.length)}...');
      }
      
      client.close();
    } catch (e) {
      print('   ❌ Error: $e');
    }
    
    print('');
  }
  
  print('📊 Resumen de conectividad:');
  print('  ✅ Exitosas: $successCount');
  print('  ❌ Fallidas: ${totalCount - successCount}');
  print('  📈 Porcentaje: ${((successCount / totalCount) * 100).toStringAsFixed(1)}%');
  
  if (successCount == totalCount) {
    print('\n🎉 ¡Todos los endpoints responden correctamente!');
    print('La API está lista para ser consumida por la app móvil.');
  } else if (successCount > 0) {
    print('\n⚠️  Algunos endpoints no responden.');
    print('Verifica la configuración del servidor o la conectividad.');
  } else {
    print('\n❌ No se pudo conectar a ningún endpoint.');
    print('Verifica que el servidor esté ejecutándose en:');
    print('$baseUrl');
  }
  
  print('\n🔧 Configuración actual:');
  print('  Base URL: $baseUrl');
  print('  Timeout: 10 segundos');
  print('  User-Agent: SkyAngel-Mobile-Test/1.0');
  
  print('\n📚 Documentación:');
  print('  • Revisa el estado del servidor en Elastic Beanstalk');
  print('  • Verifica que el backend Python esté ejecutándose');
  print('  • Confirma que los endpoints estén implementados');
  print('  • Checa los logs del servidor para errores');
}