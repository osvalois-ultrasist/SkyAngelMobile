#!/usr/bin/env dart

import 'dart:io';

void main() {
  print('🔍 Verificando estructura del proyecto SkyAngel Mobile...\n');
  
  final projectRoot = Directory.current;
  print('📁 Directorio del proyecto: ${projectRoot.path}\n');
  
  // Verificar archivos principales
  final mainFiles = [
    'pubspec.yaml',
    'analysis_options.yaml',
    'README.md',
    'lib/main.dart',
  ];
  
  print('📋 Verificando archivos principales:');
  for (final file in mainFiles) {
    final exists = File('${projectRoot.path}/$file').existsSync();
    print('  ${exists ? '✅' : '❌'} $file');
  }
  
  // Verificar estructura de carpetas
  final folders = [
    'lib/core',
    'lib/core/constants',
    'lib/core/di',
    'lib/core/error',
    'lib/core/network',
    'lib/core/storage',
    'lib/core/utils',
    'lib/features',
    'lib/features/auth',
    'lib/features/delitos',
    'lib/features/riesgos',
    'lib/features/rutas',
    'lib/features/alertas',
    'lib/features/profile',
    'lib/shared',
    'lib/shared/widgets',
    'lib/shared/themes',
  ];
  
  print('\n📂 Verificando estructura de carpetas:');
  for (final folder in folders) {
    final exists = Directory('${projectRoot.path}/$folder').existsSync();
    print('  ${exists ? '✅' : '❌'} $folder');
  }
  
  // Verificar archivos core
  final coreFiles = [
    'lib/core/constants/app_constants.dart',
    'lib/core/di/injection.dart',
    'lib/core/error/app_error.dart',
    'lib/core/network/dio_client.dart',
    'lib/core/storage/secure_storage.dart',
    'lib/core/utils/logger.dart',
    'lib/shared/themes/app_theme.dart',
  ];
  
  print('\n🔧 Verificando archivos core:');
  for (final file in coreFiles) {
    final exists = File('${projectRoot.path}/$file').existsSync();
    print('  ${exists ? '✅' : '❌'} $file');
  }
  
  // Verificar configuración Android
  final androidFiles = [
    'android/app/build.gradle',
    'android/app/src/main/AndroidManifest.xml',
  ];
  
  print('\n🤖 Verificando configuración Android:');
  for (final file in androidFiles) {
    final exists = File('${projectRoot.path}/$file').existsSync();
    print('  ${exists ? '✅' : '❌'} $file');
  }
  
  // Contar líneas de código
  print('\n📊 Estadísticas del proyecto:');
  int dartFiles = 0;
  int totalLines = 0;
  
  void countDartFiles(Directory dir) {
    try {
      for (final entity in dir.listSync()) {
        if (entity is File && entity.path.endsWith('.dart')) {
          dartFiles++;
          final lines = entity.readAsLinesSync().length;
          totalLines += lines;
        } else if (entity is Directory && !entity.path.contains('.')) {
          countDartFiles(entity);
        }
      }
    } catch (e) {
      // Ignorar errores de permisos
    }
  }
  
  final libDir = Directory('${projectRoot.path}/lib');
  if (libDir.existsSync()) {
    countDartFiles(libDir);
  }
  
  print('  📄 Archivos Dart: $dartFiles');
  print('  📝 Líneas de código: $totalLines');
  
  // Verificar dependencias principales
  final pubspecFile = File('${projectRoot.path}/pubspec.yaml');
  if (pubspecFile.existsSync()) {
    final content = pubspecFile.readAsStringSync();
    final dependencies = [
      'flutter_riverpod',
      'dio',
      'flutter_map',
      'firebase_core',
      'flutter_secure_storage',
      'drift',
      'local_auth',
    ];
    
    print('\n📦 Verificando dependencias principales:');
    for (final dep in dependencies) {
      final exists = content.contains(dep);
      print('  ${exists ? '✅' : '❌'} $dep');
    }
  }
  
  print('\n🎉 Verificación completada!');
  print('');
  print('🚀 Próximos pasos:');
  print('  1. Ejecutar: flutter pub get');
  print('  2. Configurar Firebase');
  print('  3. Generar código: flutter packages pub run build_runner build');
  print('  4. Ejecutar: flutter run');
  print('');
  print('📚 Documentación disponible en README.md');
}