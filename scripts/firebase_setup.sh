#!/bin/bash

echo "🔥 Configurando Firebase para SkyAngel Mobile..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar si Flutter está instalado
if ! command -v flutter &> /dev/null; then
    print_error "Flutter no está instalado o no está en el PATH"
    exit 1
fi

print_success "Flutter encontrado: $(flutter --version | head -n1)"

# Verificar si estamos en el directorio correcto
if [ ! -f "pubspec.yaml" ]; then
    print_error "No se encontró pubspec.yaml. Ejecuta este script desde la raíz del proyecto Flutter."
    exit 1
fi

print_status "Verificando estructura del proyecto..."

# Crear directorios necesarios si no existen
mkdir -p android/app
mkdir -p ios/Runner
mkdir -p lib/l10n

print_success "Estructura de directorios verificada"

# Verificar archivos de configuración de Firebase
print_status "Verificando archivos de configuración de Firebase..."

if [ -f "lib/firebase_options.dart" ]; then
    print_success "✅ firebase_options.dart encontrado"
else
    print_warning "❌ firebase_options.dart no encontrado"
fi

if [ -f "android/app/google-services.json" ]; then
    print_success "✅ google-services.json (Android) encontrado"
else
    print_warning "❌ google-services.json (Android) no encontrado"
fi

if [ -f "ios/Runner/GoogleService-Info.plist" ]; then
    print_success "✅ GoogleService-Info.plist (iOS) encontrado"
else
    print_warning "❌ GoogleService-Info.plist (iOS) no encontrado"
fi

# Obtener dependencias
print_status "Obteniendo dependencias de Flutter..."
if flutter pub get; then
    print_success "Dependencias obtenidas exitosamente"
else
    print_error "Error al obtener dependencias"
    exit 1
fi

# Verificar análisis de código
print_status "Ejecutando análisis de código..."
if flutter analyze --no-fatal-infos; then
    print_success "Análisis de código completado sin errores críticos"
else
    print_warning "Se encontraron algunos problemas en el análisis de código"
fi

print_status "Configuración básica completada"

echo ""
echo "🚀 Próximos pasos para completar la configuración de Firebase:"
echo ""
echo "1. Ve a la consola de Firebase: https://console.firebase.google.com/"
echo "2. Selecciona tu proyecto 'skyangermobile'"
echo "3. Agrega una app Android:"
echo "   - Package name: com.skyangel.mobile"
echo "   - Descarga el google-services.json y reemplaza el archivo existente"
echo ""
echo "4. Agrega una app iOS:"
echo "   - Bundle ID: com.skyangel.mobile"
echo "   - Descarga el GoogleService-Info.plist y reemplaza el archivo existente"
echo ""
echo "5. En la consola de Firebase, copia las claves de configuración y actualiza:"
echo "   - lib/firebase_options.dart"
echo ""
echo "6. Habilita los servicios necesarios:"
echo "   - Authentication (Email/Password, Google)"
echo "   - Cloud Firestore"
echo "   - Cloud Storage"
echo "   - Cloud Messaging"
echo "   - Analytics"
echo "   - Crashlytics"
echo ""
echo "7. Ejecuta el comando para probar la compilación:"
echo "   flutter build apk --debug"
echo ""
echo "📚 Documentación completa en README.md"

print_success "Script de configuración completado"