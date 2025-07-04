# Guía de Configuración Android para Flutter en Mac M1

Esta guía te ayudará a configurar el desarrollo Android para tu proyecto Flutter SkyAngel en Mac M1.

## 📋 Requisitos Previos

- Mac con procesador M1
- Flutter ya instalado (✅ detectado en tu sistema)
- Conexión a internet

## 🔧 Paso 1: Instalación de Android Studio

### Opción A: Descarga Manual (Recomendado)
1. Ve a https://developer.android.com/studio
2. Descarga "Android Studio for Mac (Apple Silicon)"
3. Instala arrastrando a la carpeta Applications
4. Ejecuta Android Studio y completa la configuración inicial

### Opción B: Usando Homebrew
```bash
brew install --cask android-studio
```

## 🔧 Paso 2: Configuración Inicial de Android Studio

1. **Abre Android Studio** por primera vez
2. **Acepta las licencias** del SDK
3. **Selecciona "Standard"** en el tipo de instalación
4. **Elige tu tema** preferido
5. **Permite la descarga** de componentes del SDK (esto puede tardar varios minutos)

## 🔧 Paso 3: Configuración Automática del SDK

Una vez completada la instalación de Android Studio:

```bash
# Navega a tu proyecto
cd /Users/oscarvalois/Documents/GitHub/SkyAngelMobile

# Ejecuta el script de configuración
./scripts/setup_android_sdk.sh
```

Este script:
- ✅ Detecta automáticamente la ubicación del Android SDK
- ✅ Configura Flutter para usar el SDK
- ✅ Actualiza android/local.properties
- ✅ Configura variables de entorno
- ✅ Acepta licencias de Android
- ✅ Instala componentes necesarios del SDK

## 📱 Paso 4: Crear Emulador Android

```bash
# Ejecuta el script para crear AVD
./scripts/setup_android_emulator.sh
```

Este script crea un emulador Pixel 7 con Android 14 optimizado para Mac M1.

## 🔍 Paso 5: Verificación

```bash
# Verifica que todo esté configurado correctamente
flutter doctor

# Deberías ver algo así:
# [✓] Flutter (Channel stable, 3.32.5)
# [✓] Android toolchain - develop for Android devices (Android SDK version 34.0.0)
# [✓] Chrome - develop for the web
# [✓] Android Studio (version 2025.1)
# [✓] IntelliJ IDEA Ultimate Edition (version 2024.3.4.1)
# [✓] VS Code (version 1.101.2)
# [✓] Connected device (3 available)
# [✓] Network resources
```

## 📱 Paso 6: Iniciar Emulador

```bash
# Listar emuladores disponibles
flutter emulator

# Iniciar emulador específico
flutter emulator --launch SkyAngel_Pixel_7

# O usando directamente Android SDK
$ANDROID_HOME/emulator/emulator -avd SkyAngel_Pixel_7
```

## 🚀 Paso 7: Probar la Aplicación

```bash
# Asegúrate de que el emulador esté corriendo
flutter devices

# Ejecutar la aplicación en el emulador
flutter run -d android

# Para modo debug específico
flutter run -d android --flavor dev --debug
```

## 🔧 Configuración Adicional

### Variables de Entorno
El script agrega automáticamente estas variables a tu shell:

```bash
export ANDROID_HOME="$HOME/Library/Android/sdk"
export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
export PATH="$PATH:$ANDROID_HOME/tools"
export PATH="$PATH:$ANDROID_HOME/tools/bin"
export PATH="$PATH:$ANDROID_HOME/emulator"
```

### Componentes del SDK Instalados
- Platform Tools
- Android 14 (API 34)
- Build Tools 34.0.0
- Emulator
- System Images para ARM64 (M1 compatible)

## 🛠️ Solución de Problemas

### Error: "Unable to locate Android SDK"
```bash
# Ejecuta manualmente el script de configuración
./scripts/setup_android_sdk.sh
```

### Error: "Android licenses not accepted"
```bash
# Acepta licencias manualmente
flutter doctor --android-licenses
```

### Error: "No devices found"
```bash
# Verifica que el emulador esté corriendo
flutter devices

# Reinicia ADB si es necesario
adb kill-server
adb start-server
```

### Error: "Build failed"
```bash
# Limpia el proyecto
flutter clean
flutter pub get

# Reconstruye
flutter build apk --debug
```

## 📚 Comandos Útiles

```bash
# Ver información del SDK
flutter doctor -v

# Listar dispositivos conectados
flutter devices

# Listar emuladores
flutter emulator

# Limpiar proyecto
flutter clean

# Actualizar dependencias
flutter pub get

# Construir APK
flutter build apk --release --flavor prod

# Instalar APK en dispositivo
flutter install
```

## 🔗 Recursos Adicionales

- [Documentación oficial de Flutter](https://flutter.dev/docs)
- [Guía de Android Studio](https://developer.android.com/studio)
- [Configuración de Firebase](FIREBASE_SETUP_COMPLETE.md)

## 💡 Tips para Mac M1

1. **Usa siempre** system images ARM64 para mejor rendimiento
2. **Habilita** aceleración de hardware en el emulador
3. **Configura** memoria RAM adecuada (4-8GB) para el emulador
4. **Usa** Android Studio Arctic Fox o posterior para compatibilidad M1

---

Una vez completada la configuración, tu entorno estará listo para desarrollar la aplicación SkyAngel Mobile en Android! 🚀