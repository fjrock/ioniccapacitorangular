#!/bin/bash

# Script para generar IPA de iOS para una aplicación Ionic/Capacitor (Completamente automatizado)
# Autor: Claude
# Fecha: 2025-06-24

# Asegurarse de que estamos usando Node.js v20
echo "Activando Node.js v20..."
source ~/.nvm/nvm.sh
nvm use 20

# Configurar Java 23
echo "Configurando Java 23..."
export JAVA_HOME=/Library/Java/JavaVirtualMachines/temurin-23.jdk/Contents/Home
export PATH=$JAVA_HOME/bin:$PATH

# Verificar la versión de Java
java -version

# Verificar si estamos en el directorio correcto
if [ ! -f "ionic.config.json" ]; then
    echo "Error: No se encuentra ionic.config.json. Por favor, ejecute este script desde el directorio raíz del proyecto Ionic."
    exit 1
fi

# Verificar si xcodebuild está instalado
if ! command -v xcodebuild &> /dev/null; then
    echo "Error: xcodebuild no está instalado. Por favor, instale Xcode Command Line Tools."
    exit 1
fi

# Construir la aplicación web
echo "Construyendo la aplicación web..."
ionic build --prod

# Copiar los archivos web a la plataforma iOS
echo "Sincronizando con la plataforma iOS..."
ionic capacitor sync ios

# Crear directorios para los IPAs
mkdir -p build/ios/debug
mkdir -p build/ios/release

# Obtener el nombre del equipo de desarrollo de Apple
echo "Para generar IPAs necesitas un Team ID de Apple Developer."
read -p "Ingrese su Team ID de Apple Developer (ejemplo: A1B2C3D4E5): " TEAM_ID

if [ -z "$TEAM_ID" ]; then
    echo "Error: No se proporcionó un Team ID. No se pueden generar los IPAs."
    exit 1
fi

# Crear archivo exportOptions-debug.plist
cat > build/ios/debug/exportOptions.plist << EOLINNER
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>teamID</key>
    <string>${TEAM_ID}</string>
    <key>compileBitcode</key>
    <false/>
</dict>
</plist>
EOLINNER

# Crear archivo exportOptions-release.plist
cat > build/ios/release/exportOptions.plist << EOLINNER
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>${TEAM_ID}</string>
    <key>compileBitcode</key>
    <true/>
</dict>
</plist>
EOLINNER

# Actualizar los perfiles de aprovisionamiento automáticamente
echo "Actualizando perfiles de aprovisionamiento..."
cd ios/App
xcodebuild -workspace App.xcworkspace -scheme App -allowProvisioningUpdates -quiet
cd ../..

# Generar archivo IPA de debug
echo "Generando IPA de debug..."
cd ios/App
xcodebuild clean archive -workspace App.xcworkspace -scheme App -configuration Debug -archivePath ../../build/ios/debug/App.xcarchive CODE_SIGN_IDENTITY="Apple Development" CODE_SIGN_STYLE=Automatic DEVELOPMENT_TEAM="${TEAM_ID}"
cd ../..

# Exportar IPA de debug
echo "Exportando IPA de debug..."
xcodebuild -exportArchive -archivePath build/ios/debug/App.xcarchive -exportPath build/ios/debug -exportOptionsPlist build/ios/debug/exportOptions.plist

# Generar archivo IPA de release
echo "Generando IPA de release..."
cd ios/App
xcodebuild clean archive -workspace App.xcworkspace -scheme App -configuration Release -archivePath ../../build/ios/release/App.xcarchive CODE_SIGN_IDENTITY="Apple Distribution" CODE_SIGN_STYLE=Automatic DEVELOPMENT_TEAM="${TEAM_ID}"
cd ../..

# Exportar IPA de release
echo "Exportando IPA de release..."
xcodebuild -exportArchive -archivePath build/ios/release/App.xcarchive -exportPath build/ios/release -exportOptionsPlist build/ios/release/exportOptions.plist

# Verificar si se generaron los IPAs
DEBUG_IPA="build/ios/debug/App.ipa"
RELEASE_IPA="build/ios/release/App.ipa"

if [ -f "$DEBUG_IPA" ]; then
    echo "IPA de debug generado exitosamente en: $DEBUG_IPA"
else
    echo "Error: No se pudo generar el IPA de debug."
fi

if [ -f "$RELEASE_IPA" ]; then
    echo "IPA de release generado exitosamente en: $RELEASE_IPA"
else
    echo "Error: No se pudo generar el IPA de release."
fi

echo ""
echo "Proceso completado!"
echo "IPAs generados en:"
echo "- Debug: $DEBUG_IPA"
echo "- Release: $RELEASE_IPA"
echo ""
echo "NOTA: Si el proceso falló, es posible que necesites:"
echo "1. Configurar manualmente los perfiles de aprovisionamiento en Xcode"
echo "2. Asegurarte de que tienes los certificados necesarios instalados"
echo "" 