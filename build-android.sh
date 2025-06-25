#!/bin/bash

# Script para generar APK de Android para una aplicación Ionic/Capacitor
# Autor: Claude
# Fecha: 2025-06-24

# Asegurarse de que estamos usando Node.js v20
echo "Activando Node.js v20..."
source ~/.nvm/nvm.sh
nvm use 20

# Verificar si estamos en el directorio correcto
if [ ! -f "ionic.config.json" ]; then
    echo "Error: No se encuentra ionic.config.json. Por favor, ejecute este script desde el directorio raíz del proyecto Ionic."
    exit 1
fi

# Construir la aplicación web
echo "Construyendo la aplicación web..."
ionic build

# Copiar los archivos web a la plataforma Android
echo "Sincronizando con la plataforma Android..."
ionic capacitor sync android

# Generar APK de debug
echo "Generando APK de debug..."
cd android
./gradlew assembleDebug
cd ..

# Verificar si se generó el APK
APK_PATH="android/app/build/outputs/apk/debug/app-debug.apk"
if [ -f "$APK_PATH" ]; then
    echo "APK generado exitosamente en: $APK_PATH"
    
    # Copiar a una ubicación más accesible
    mkdir -p build/android
    cp "$APK_PATH" build/android/
    echo "APK copiado a: build/android/app-debug.apk"
else
    echo "Error: No se pudo generar el APK."
fi

echo ""
echo "Proceso completado!"
echo "Para instalar el APK en un dispositivo Android:"
echo "1. Habilite el modo desarrollador en su dispositivo"
echo "2. Conecte el dispositivo a su computadora"
echo "3. Ejecute: adb install $APK_PATH"
echo "" 