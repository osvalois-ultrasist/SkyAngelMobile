#!/bin/bash

# Script to create Android Virtual Device (AVD) for Flutter development
# This script should be run after Android SDK is configured

echo "📱 Configurando Android Virtual Device (AVD) para Flutter..."

# Check if Android SDK is configured
if [ -z "$ANDROID_HOME" ]; then
    echo "❌ ANDROID_HOME no está configurado. Ejecuta setup_android_sdk.sh primero."
    exit 1
fi

# AVD configuration
AVD_NAME="SkyAngel_Pixel_7"
SYSTEM_IMAGE="system-images;android-34;google_apis;arm64-v8a"
DEVICE_TYPE="pixel_7"

echo "🔧 Creando AVD: $AVD_NAME"

# Create AVD
echo "no" | "$ANDROID_HOME/cmdline-tools/latest/bin/avdmanager" create avd \
    --name "$AVD_NAME" \
    --package "$SYSTEM_IMAGE" \
    --device "$DEVICE_TYPE"

if [ $? -eq 0 ]; then
    echo "✅ AVD '$AVD_NAME' creado exitosamente!"
    echo ""
    echo "📱 Para iniciar el emulador, usa:"
    echo "   flutter emulator --launch $AVD_NAME"
    echo "   o"
    echo "   \$ANDROID_HOME/emulator/emulator -avd $AVD_NAME"
else
    echo "❌ Error al crear AVD. Verifica que:"
    echo "   1. Android SDK esté instalado correctamente"
    echo "   2. La imagen del sistema esté descargada"
    echo "   3. Las variables de entorno estén configuradas"
fi

echo ""
echo "🔍 AVDs disponibles:"
"$ANDROID_HOME/cmdline-tools/latest/bin/avdmanager" list avd