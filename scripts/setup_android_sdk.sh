#!/bin/bash

# Script to configure Android SDK for Flutter development on Mac M1
# This script should be run after Android Studio is installed

echo "🔧 Configurando Android SDK para Flutter en Mac M1..."

# Common Android SDK paths on Mac
ANDROID_HOME_PATHS=(
    "$HOME/Library/Android/sdk"
    "$HOME/Android/Sdk"
    "/usr/local/share/android-sdk"
    "/opt/android-sdk"
)

# Try to find Android SDK
ANDROID_SDK_ROOT=""
for path in "${ANDROID_HOME_PATHS[@]}"; do
    if [ -d "$path" ]; then
        ANDROID_SDK_ROOT="$path"
        echo "✅ Android SDK encontrado en: $ANDROID_SDK_ROOT"
        break
    fi
done

if [ -z "$ANDROID_SDK_ROOT" ]; then
    echo "❌ No se encontró Android SDK. Por favor:"
    echo "   1. Instala Android Studio"
    echo "   2. Ejecuta Android Studio y completa la configuración inicial"
    echo "   3. Vuelve a ejecutar este script"
    exit 1
fi

# Configure Flutter to use Android SDK
echo "🔧 Configurando Flutter para usar Android SDK..."
flutter config --android-sdk "$ANDROID_SDK_ROOT"

# Update local.properties
LOCAL_PROPERTIES="android/local.properties"
if [ -f "$LOCAL_PROPERTIES" ]; then
    # Remove existing sdk.dir line
    sed -i '' '/^sdk.dir=/d' "$LOCAL_PROPERTIES"
fi

# Add Android SDK path to local.properties
echo "sdk.dir=$ANDROID_SDK_ROOT" >> "$LOCAL_PROPERTIES"
echo "✅ Actualizado android/local.properties"

# Set environment variables
echo "🔧 Configurando variables de entorno..."

# Check if zsh is being used (default on macOS)
if [ "$SHELL" = "/bin/zsh" ]; then
    SHELL_RC="$HOME/.zshrc"
else
    SHELL_RC="$HOME/.bashrc"
fi

# Add Android SDK to PATH and set environment variables
{
    echo ""
    echo "# Android SDK configuration"
    echo "export ANDROID_HOME=\"$ANDROID_SDK_ROOT\""
    echo "export ANDROID_SDK_ROOT=\"$ANDROID_SDK_ROOT\""
    echo "export PATH=\"\$PATH:\$ANDROID_HOME/cmdline-tools/latest/bin\""
    echo "export PATH=\"\$PATH:\$ANDROID_HOME/platform-tools\""
    echo "export PATH=\"\$PATH:\$ANDROID_HOME/tools\""
    echo "export PATH=\"\$PATH:\$ANDROID_HOME/tools/bin\""
    echo "export PATH=\"\$PATH:\$ANDROID_HOME/emulator\""
} >> "$SHELL_RC"

echo "✅ Variables de entorno agregadas a $SHELL_RC"

# Source the shell configuration
source "$SHELL_RC"

# Accept Android licenses
echo "🔧 Aceptando licencias de Android..."
yes | "$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager" --licenses 2>/dev/null || true

# Install required Android SDK components
echo "🔧 Instalando componentes necesarios del Android SDK..."
"$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager" "platform-tools" "platforms;android-34" "build-tools;34.0.0" "emulator" "system-images;android-34;google_apis;arm64-v8a"

echo "✅ Configuración de Android SDK completada!"
echo ""
echo "🔄 Por favor, reinicia tu terminal y ejecuta:"
echo "   source $SHELL_RC"
echo "   flutter doctor"
echo ""
echo "📱 Para crear un emulador Android, ejecuta:"
echo "   flutter emulator --create"