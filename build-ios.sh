#!/bin/bash

# Script para generar IPA de iOS para una aplicación Ionic/Capacitor
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

# Verificar si xcodebuild está instalado
if ! command -v xcodebuild &> /dev/null; then
    echo "Error: xcodebuild no está instalado. Por favor, instale Xcode Command Line Tools."
    exit 1
fi

# Construir la aplicación web
echo "Construyendo la aplicación web..."
ionic build

# Copiar los archivos web a la plataforma iOS
echo "Sincronizando con la plataforma iOS..."
ionic capacitor sync ios

# Crear directorio para el IPA
mkdir -p build/ios

# Obtener el nombre del equipo de desarrollo de Apple
echo "Para generar un IPA necesitas un Team ID de Apple Developer."
read -p "Ingrese su Team ID de Apple Developer (ejemplo: A1B2C3D4E5): " TEAM_ID

if [ -z "$TEAM_ID" ]; then
    echo "Error: No se proporcionó un Team ID. No se puede generar el IPA."
    exit 1
fi

# Crear archivo exportOptions.plist
cat > build/ios/exportOptions.plist << EOL
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
EOL

# Actualizar los perfiles de aprovisionamiento automáticamente
echo "Actualizando perfiles de aprovisionamiento..."
cd ios/App
xcodebuild -workspace App.xcworkspace -scheme App -allowProvisioningUpdates -quiet
cd ../..

# Generar archivo IPA
echo "Generando IPA..."
cd ios/App
xcodebuild clean archive -workspace App.xcworkspace -scheme App -configuration Debug -archivePath ../../build/ios/App.xcarchive CODE_SIGN_IDENTITY="Apple Development" CODE_SIGN_STYLE=Automatic DEVELOPMENT_TEAM="${TEAM_ID}"
cd ../..

# Exportar IPA
echo "Exportando IPA..."
xcodebuild -exportArchive -archivePath build/ios/App.xcarchive -exportPath build/ios -exportOptionsPlist build/ios/exportOptions.plist

# Verificar si se generó el IPA
IPA_PATH="build/ios/App.ipa"
if [ -f "$IPA_PATH" ]; then
    echo "IPA generado exitosamente en: $IPA_PATH"
else
    echo "Error: No se pudo generar el IPA."
fi

echo ""
echo "Proceso completado!"
echo "Para instalar el IPA en un dispositivo iOS:"
echo "1. Conecte el dispositivo a su computadora"
echo "2. Abra iTunes y seleccione su dispositivo"
echo "3. Arrastre el archivo IPA a la sección de Aplicaciones"
echo "4. Sincronice su dispositivo"
echo "" 