#!/bin/bash

# Script para generar automáticamente APKs para Android
# Autor: Equipo de Desarrollo
# Fecha: $(date +%Y-%m-%d)

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Iniciando generación automática de APK ===${NC}"

# Verificar si estamos en el directorio correcto
if [ ! -f "capacitor.config.ts" ]; then
    echo -e "${RED}Error: Este script debe ejecutarse desde el directorio raíz del proyecto${NC}"
    exit 1
fi

# Crear directorio de salida si no existe
mkdir -p build/android

# Compilar la aplicación web
echo -e "${YELLOW}Compilando aplicación web...${NC}"
npm run build

# Sincronizar con Capacitor
echo -e "${YELLOW}Sincronizando con Capacitor...${NC}"
npx cap sync android

# Verificar si Gradle está disponible
cd android
if ! ./gradlew -v > /dev/null 2>&1; then
    echo -e "${RED}Error: Gradle no está disponible. Asegúrate de tener Android Studio instalado correctamente.${NC}"
    exit 1
fi

# Generar APK de depuración
echo -e "${YELLOW}Generando APK de depuración...${NC}"
./gradlew assembleDebug

# Verificar si se generó correctamente
if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
    cp app/build/outputs/apk/debug/app-debug.apk ../build/android/
    echo -e "${GREEN}APK de depuración generado correctamente en build/android/app-debug.apk${NC}"
else
    echo -e "${RED}Error al generar APK de depuración${NC}"
fi

# Generar APK de release
echo -e "${YELLOW}Generando APK de release...${NC}"
./gradlew assembleRelease

# Verificar si se generó correctamente
if [ -f "app/build/outputs/apk/release/app-release-unsigned.apk" ]; then
    # Firmar APK (requiere configuración previa del keystore)
    if [ -f "app/my-release-key.keystore" ]; then
        echo -e "${YELLOW}Firmando APK de release...${NC}"
        
        # Verificar si las variables de entorno están configuradas
        if [ -z "$KEYSTORE_PASSWORD" ] || [ -z "$KEY_ALIAS" ] || [ -z "$KEY_PASSWORD" ]; then
            echo -e "${YELLOW}Variables de entorno para firma no configuradas. Usando valores predeterminados.${NC}"
            KEYSTORE_PASSWORD="android"
            KEY_ALIAS="key0"
            KEY_PASSWORD="android"
        fi
        
        # Firmar APK
        jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore app/my-release-key.keystore \
            -storepass "$KEYSTORE_PASSWORD" -keypass "$KEY_PASSWORD" \
            app/build/outputs/apk/release/app-release-unsigned.apk "$KEY_ALIAS"
        
        # Optimizar APK
        if command -v zipalign > /dev/null 2>&1; then
            echo -e "${YELLOW}Optimizando APK...${NC}"
            zipalign -v 4 app/build/outputs/apk/release/app-release-unsigned.apk ../build/android/app-release.apk
            echo -e "${GREEN}APK de release generado correctamente en build/android/app-release.apk${NC}"
        else
            echo -e "${YELLOW}zipalign no encontrado. Copiando APK sin optimizar.${NC}"
            cp app/build/outputs/apk/release/app-release-unsigned.apk ../build/android/app-release.apk
            echo -e "${GREEN}APK de release (sin optimizar) generado en build/android/app-release.apk${NC}"
        fi
    else
        echo -e "${YELLOW}Keystore no encontrado. Copiando APK sin firmar.${NC}"
        cp app/build/outputs/apk/release/app-release-unsigned.apk ../build/android/app-release-unsigned.apk
        echo -e "${GREEN}APK de release (sin firmar) generado en build/android/app-release-unsigned.apk${NC}"
    fi
else
    echo -e "${RED}Error al generar APK de release${NC}"
fi

# Volver al directorio raíz
cd ..

echo -e "${GREEN}=== Proceso de generación de APK completado ===${NC}"
echo -e "${YELLOW}APKs disponibles en:${NC}"
echo -e "  - Debug: ${GREEN}build/android/app-debug.apk${NC}"
echo -e "  - Release: ${GREEN}build/android/app-release.apk${NC}"

exit 0 