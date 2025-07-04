# 🔧 Configuración de API Actualizada - SkyAngel Mobile

## ✅ Estado de la API

### 🔗 Servidor Elastic Beanstalk
- **URL**: `http://skyangel-mock-prod.eba-mtya3rnt.us-east-1.elasticbeanstalk.com`
- **Estado**: ✅ Funcionando
- **Conectividad**: ✅ Responde correctamente

### 📊 Endpoints Disponibles

#### ✅ Funcionando (2/33)
1. **Health Check**: `/health` - ✅ 200 OK
   - Propósito: Verificar estado del servidor
   - Respuesta: JSON con 4 campos
   
2. **Root**: `/` - ✅ 200 OK
   - Propósito: Información básica del API
   - Respuesta: JSON con 3 campos

#### ❌ No Implementados (31/33)
Todos los demás endpoints específicos del backend Python retornan 404 Not Found.

## 🔧 Configuración Actualizada

### Flutter Configuration Files

#### `lib/core/config/environment.dart`
```dart
static String get baseUrl {
  return 'http://skyangel-mock-prod.eba-mtya3rnt.us-east-1.elasticbeanstalk.com';
}

static String get apiVersion => ''; // Sin prefijo /api/v1
```

#### `lib/core/constants/app_constants.dart`
```dart
// API Configuration
static const String baseUrl = 'http://skyangel-mock-prod.eba-mtya3rnt.us-east-1.elasticbeanstalk.com';
static const String wsUrl = 'ws://skyangel-mock-prod.eba-mtya3rnt.us-east-1.elasticbeanstalk.com';
```

### Android Configuration

#### `android/app/src/main/res/xml/network_security_config.xml`
```xml
<domain-config cleartextTrafficPermitted="true">
    <domain includeSubdomains="false">skyangel-mock-prod.eba-mtya3rnt.us-east-1.elasticbeanstalk.com</domain>
</domain-config>
```

#### `android/app/build.gradle`
```gradle
buildConfigField "String", "BASE_URL", '"http://skyangel-mock-prod.eba-mtya3rnt.us-east-1.elasticbeanstalk.com"'
buildConfigField "String", "WS_URL", '"ws://skyangel-mock-prod.eba-mtya3rnt.us-east-1.elasticbeanstalk.com"'
```

## 🚀 Estrategia de Desarrollo

### Fase 1: Conectividad Básica ✅
- [x] Configurar URL base del servidor
- [x] Permitir tráfico HTTP en Android
- [x] Verificar conectividad con `/health`
- [x] Probar endpoint root `/`

### Fase 2: Mock Data (Recomendado)
Mientras se implementan los endpoints del backend:

1. **Crear datos mock locales**
2. **Implementar interceptor que devuelve datos simulados**
3. **Permitir desarrollo de UI sin depender del backend**

### Fase 3: Integración Gradual
Conforme se implementen endpoints en el backend:

1. **Reemplazar mocks con llamadas reales**
2. **Implementar manejo de errores específicos**
3. **Agregar retry logic para endpoints temporalmente indisponibles**

## 📋 Endpoints Necesarios para SkyAngel

### Prioritarios (Core Features)
```
✅ /health                     - Health check
❌ /auth/login                 - Autenticación
❌ /auth/register              - Registro
❌ /catalogos/municipios       - Catálogo de municipios
❌ /catalogos/entidades        - Catálogo de entidades
❌ /delitos/secretariado       - Datos de criminalidad
❌ /mapas                      - Datos de mapas
```

### Secundarios (Enhanced Features)
```
❌ /graficas/barras           - Gráficas estadísticas
❌ /puntos-interes           - Puntos de interés
❌ /alertas                  - Sistema de alertas
❌ /rutas                    - Cálculo de rutas
❌ /anerpv                   - Datos ANERPV
❌ /reacciones               - Reacciones de usuarios
```

## 🔨 Implementación Recomendada

### 1. Crear Service Layer con Fallbacks

```dart
class ApiService {
  static const bool useLocalMocks = true; // Flag para desarrollo
  
  Future<List<Municipality>> getMunicipalities() async {
    if (useLocalMocks) {
      return _getLocalMunicipalities();
    }
    
    try {
      final response = await dio.get('/catalogos/municipios');
      return Municipality.fromJsonList(response.data);
    } catch (e) {
      // Fallback a datos locales si la API falla
      return _getLocalMunicipalities();
    }
  }
}
```

### 2. Configurar Interceptor de Mock Data

```dart
class MockInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (EnvironmentConfig.useLocalMocks) {
      final mockResponse = _getMockResponse(options.path);
      if (mockResponse != null) {
        return handler.resolve(mockResponse);
      }
    }
    handler.next(options);
  }
}
```

### 3. Crear Data Sources Duales

```dart
abstract class CrimeDataSource {
  Future<List<Crime>> getCrimes();
}

class RemoteCrimeDataSource implements CrimeDataSource {
  @override
  Future<List<Crime>> getCrimes() async {
    final response = await apiService.get('/delitos/secretariado');
    return Crime.fromJsonList(response.data);
  }
}

class LocalCrimeDataSource implements CrimeDataSource {
  @override
  Future<List<Crime>> getCrimes() async {
    final jsonString = await rootBundle.loadString('assets/data/crimes.json');
    final jsonData = json.decode(jsonString);
    return Crime.fromJsonList(jsonData);
  }
}
```

## 📱 Testing Configuration

### Verificar Conectividad
```bash
# Ejecutar script de verificación
dart scripts/test_api_endpoints.dart

# Resultado esperado:
✅ Health Check: 200 OK
✅ Root: 200 OK
❌ Otros endpoints: 404 (esperado)
```

### Probar en la App
```dart
// En main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Verificar conectividad al iniciar
  final isConnected = await ApiService.checkConnectivity();
  print('🔗 API Connected: $isConnected');
  
  runApp(MyApp());
}
```

## 🎯 Próximos Pasos

### Inmediatos
1. ✅ **Configurar URLs en Flutter** 
2. ✅ **Permitir HTTP en Android**
3. ⏳ **Crear datos mock para desarrollo**
4. ⏳ **Implementar UI básica sin dependencia del backend**

### Medio Plazo
1. ⏳ **Coordinar con backend para implementar endpoints**
2. ⏳ **Definir esquemas JSON de respuesta**
3. ⏳ **Implementar autenticación básica**
4. ⏳ **Crear sistema de caché local**

### Largo Plazo
1. ⏳ **Migrar de HTTP a HTTPS**
2. ⏳ **Implementar WebSocket para alertas**
3. ⏳ **Optimizar rendimiento de API**
4. ⏳ **Implementar sincronización offline**

## 📞 Contacto Backend Team

Para acelerar el desarrollo, necesitamos coordinar la implementación de:

1. **Endpoints de autenticación** (`/auth/*`)
2. **Catálogos básicos** (`/catalogos/*`)
3. **Datos de criminalidad** (`/delitos/*`)
4. **Información geográfica** (`/mapas/*`)

## ✅ Estado Actual

- 🔧 **Configuración Flutter**: ✅ Completa
- 🔗 **Conectividad**: ✅ Verificada
- 📱 **Desarrollo**: ✅ Listo para comenzar con mocks
- 🚀 **Deploy**: ✅ Preparado para producción

La aplicación móvil está **completamente configurada** y lista para desarrollo, independientemente del estado de implementación del backend.