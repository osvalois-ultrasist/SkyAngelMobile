# SkyAngel Mobile

SkyAngel Mobile es una aplicación Flutter para análisis de seguridad y riesgo en el transporte de México. Esta aplicación proporciona mapas interactivos de criminalidad, rutas seguras, alertas en tiempo real y análisis de datos de múltiples fuentes.

## 🏗️ Arquitectura

La aplicación está construida siguiendo principios de **Clean Architecture** y **Domain-Driven Design (DDD)** con las siguientes capas:

### Estructura de Carpetas

```
lib/
├── core/                     # Núcleo de la aplicación
│   ├── constants/           # Constantes de la aplicación
│   ├── di/                  # Inyección de dependencias
│   ├── error/               # Manejo de errores
│   ├── network/             # Cliente HTTP y interceptores
│   ├── storage/             # Almacenamiento local y seguro
│   └── utils/               # Utilidades y helpers
├── features/                # Módulos de funcionalidades
│   ├── auth/               # Autenticación
│   ├── delitos/            # Visualización de criminalidad
│   ├── riesgos/            # Análisis de riesgos
│   ├── rutas/              # Rutas seguras
│   ├── alertas/            # Sistema de alertas
│   └── profile/            # Perfil de usuario
└── shared/                  # Componentes compartidos
    ├── widgets/            # Widgets reutilizables
    ├── themes/             # Temas y estilos
    ├── extensions/         # Extensiones de Dart
    └── models/             # Modelos compartidos
```

### Principios de Arquitectura

- **Clean Architecture**: Separación clara de responsabilidades
- **SOLID Principles**: Código mantenible y escalable
- **Dependency Injection**: Gestión de dependencias con GetIt e Injectable
- **State Management**: Riverpod para gestión de estado reactivo
- **Repository Pattern**: Abstracción de fuentes de datos
- **Error Handling**: Manejo centralizado de errores

## 🚀 Características Principales

### 📊 Visualización de Datos
- **Mapas Interactivos**: Visualización de datos de criminalidad en tiempo real
- **Múltiples Fuentes**: Integración con Secretariado, ANERPV y SkyAngel
- **Filtros Avanzados**: Filtrado por tipo de delito, fecha y ubicación
- **Escalas de Riesgo**: Visualización por hexágonos con niveles de riesgo

### 🗺️ Rutas Seguras
- **Cálculo Inteligente**: Algoritmos de optimización con análisis de riesgo
- **Rutas Alternativas**: Múltiples opciones de rutas seguras
- **Navegación en Tiempo Real**: Guía paso a paso con alertas de seguridad
- **Histórico de Rutas**: Guardado de rutas favoritas y recientes

### 🚨 Sistema de Alertas
- **Alertas en Tiempo Real**: Notificaciones WebSocket instantáneas
- **Geofencing**: Alertas basadas en ubicación
- **Clasificación por Severidad**: Niveles de alerta crítica, alta, media y baja
- **Historial de Alertas**: Registro completo de alertas recibidas

### 🔐 Seguridad
- **Autenticación Biométrica**: Huella dactilar y reconocimiento facial
- **Cifrado de Datos**: Almacenamiento seguro con Flutter Secure Storage
- **Certificate Pinning**: Validación de certificados SSL/TLS
- **Detección de Root/Jailbreak**: Protección contra dispositivos comprometidos

### 📱 Características Móviles
- **Modo Offline**: Funcionalidad limitada sin conexión a internet
- **Sincronización**: Actualización automática de datos
- **Notificaciones Push**: Firebase Cloud Messaging
- **Ubicación en Segundo Plano**: Seguimiento para alertas de seguridad

## 🛠️ Tecnologías Utilizadas

### Framework y Lenguaje
- **Flutter 3.16+**: Framework de desarrollo multiplataforma
- **Dart 3.2+**: Lenguaje de programación
- **Material 3**: Sistema de diseño de Google

### Gestión de Estado
- **Riverpod 2.4+**: State management reactivo
- **Flutter Hooks**: Hooks para widgets
- **Freezed**: Inmutabilidad y serialización

### Networking
- **Dio 5.4+**: Cliente HTTP avanzado
- **Retrofit**: Generación de clientes API
- **Socket.IO**: Comunicación WebSocket en tiempo real

### Base de Datos y Almacenamiento
- **Drift**: Base de datos SQLite type-safe
- **Hive**: Base de datos NoSQL rápida
- **Flutter Secure Storage**: Almacenamiento cifrado
- **Shared Preferences**: Preferencias de usuario

### Mapas y Ubicación
- **Flutter Map**: Mapas basados en Leaflet
- **Geolocator**: Servicios de ubicación
- **Background Location**: Ubicación en segundo plano

### Visualización de Datos
- **FL Chart**: Gráficos nativos de Flutter
- **Syncfusion Charts**: Gráficos avanzados

### Firebase y Analytics
- **Firebase Core**: Configuración base
- **Firebase Analytics**: Análisis de uso
- **Firebase Crashlytics**: Reporte de errores
- **Firebase Messaging**: Notificaciones push
- **Firebase Performance**: Monitoreo de rendimiento

### Seguridad
- **Local Auth**: Autenticación biométrica
- **Crypto**: Cifrado de datos
- **Trust Fall**: Detección de root/jailbreak

### UI/UX
- **Dynamic Color**: Colores adaptativos Material You
- **Lottie**: Animaciones vectoriales
- **Rive**: Animaciones interactivas
- **Shimmer**: Efectos de carga

## 📋 Prerequisitos

- Flutter SDK 3.16.0 o superior
- Dart SDK 3.2.0 o superior
- Android Studio / VS Code
- Xcode (para desarrollo iOS)
- Firebase CLI
- Git

## 🔧 Instalación y Configuración

### 1. Clonar el Repositorio
```bash
git clone https://github.com/tu-usuario/skyangel-mobile.git
cd skyangel-mobile
```

### 2. Instalar Dependencias
```bash
flutter pub get
```

### 3. Configurar Firebase
```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Iniciar sesión en Firebase
firebase login

# Configurar proyecto
flutterfire configure
```

### 4. Generar Código
```bash
# Generar archivos de código
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 5. Configurar Android
```bash
# Crear keystore para release (opcional)
keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Crear archivo keystore.properties
echo "storePassword=tu_password
keyPassword=tu_key_password
keyAlias=upload
storeFile=upload-keystore.jks" > android/keystore.properties
```

### 6. Configurar iOS
```bash
# Abrir en Xcode para configurar certificados
open ios/Runner.xcworkspace
```

## 🚀 Ejecución

### Desarrollo
```bash
# Ejecutar en modo debug
flutter run

# Ejecutar con hot reload
flutter run --hot
```

### Producción
```bash
# Build para Android
flutter build apk --release
flutter build appbundle --release

# Build para iOS
flutter build ios --release
```

## 🧪 Testing

### Ejecutar Tests
```bash
# Tests unitarios
flutter test

# Tests de integración
flutter test integration_test/

# Tests con cobertura
flutter test --coverage
```

### Análisis de Código
```bash
# Análisis estático
flutter analyze

# Formateo de código
dart format .

# Verificar dependencias
flutter pub deps
```

## 📱 Estructura de Features

Cada feature sigue la estructura de Clean Architecture:

```
features/example/
├── data/
│   ├── datasources/        # Fuentes de datos (API, local)
│   ├── models/            # Modelos de datos
│   └── repositories/      # Implementación de repositorios
├── domain/
│   ├── entities/          # Entidades de negocio
│   ├── repositories/      # Contratos de repositorios
│   └── usecases/         # Casos de uso
└── presentation/
    ├── pages/            # Páginas/Pantallas
    ├── widgets/          # Widgets específicos
    └── providers/        # Providers de Riverpod
```

## 🔐 Configuración de Seguridad

### Variables de Entorno
Crea un archivo `.env` en la raíz del proyecto:

```env
# API Configuration
BASE_URL=https://api.skyangel.com
WS_URL=wss://ws.skyangel.com

# Firebase Configuration
FIREBASE_PROJECT_ID=skyangel-mobile
FIREBASE_APP_ID=tu_app_id
FIREBASE_API_KEY=tu_api_key

# Security
ENABLE_CERTIFICATE_PINNING=true
ENABLE_ROOT_DETECTION=true
ENABLE_DEBUG_LOGGING=false
```

### Certificate Pinning
Configura los certificados en `assets/config/certificates.json`:

```json
{
  "pins": [
    {
      "host": "api.skyangel.com",
      "sha256": "sha256_hash_del_certificado"
    }
  ]
}
```

## 📊 Monitoreo y Analytics

### Firebase Analytics
- Eventos personalizados de usuario
- Seguimiento de pantallas
- Conversion funnels
- Retención de usuarios

### Crashlytics
- Reporte automático de errores
- Logs personalizados
- Métricas de estabilidad

### Performance Monitoring
- Tiempos de carga de pantallas
- Rendimiento de red
- Métricas de UI

## 🔄 CI/CD

### GitHub Actions
El proyecto incluye workflows para:
- Tests automatizados
- Análisis de código
- Build y deploy automático
- Notificaciones de Slack/Teams

### Fastlane (Configuración futura)
- Deploy automático a stores
- Manejo de certificados
- Screenshots automáticos
- Metadata de stores

## 📚 Documentación Adicional

- [Guía de Contribución](CONTRIBUTING.md)
- [Código de Conducta](CODE_OF_CONDUCT.md)
- [Changelog](CHANGELOG.md)
- [Licencia](LICENSE)

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📝 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo [LICENSE](LICENSE) para más detalles.

## 👥 Equipo

- **Desarrollador Principal**: Tu Nombre
- **Arquitecto de Software**: Nombre
- **UI/UX Designer**: Nombre
- **DevOps Engineer**: Nombre

## 📞 Soporte

Para soporte técnico o preguntas:
- Email: soporte@skyangel.com
- Issues: [GitHub Issues](https://github.com/tu-usuario/skyangel-mobile/issues)
- Documentación: [Wiki](https://github.com/tu-usuario/skyangel-mobile/wiki)

---

**SkyAngel Mobile** - Haciendo el transporte más seguro en México 🇲🇽