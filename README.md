# myIonicApp

Aplicación móvil híbrida desarrollada con Ionic, Angular y Capacitor.

## Versiones

- Ionic: 6.20.9
- Capacitor: 7.4.0
- Angular: 19.2.14

## Requisitos previos

- Node.js v18+ (recomendado v20)
- Java JDK 21 para Android
- Xcode 14+ para iOS
- Android Studio para Android
- Cocoapods para iOS

## Configuración del entorno

### Instalación de Node.js con NVM

```bash
# Instalar NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash

# Cargar NVM
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Instalar Node.js v20
nvm install 20
nvm use 20
```

### Instalación de dependencias del proyecto

```bash
# Instalar dependencias
npm install
```

## Estructura del proyecto

```
myIonicApp/
├── android/                # Proyecto Android generado por Capacitor
├── ios/                    # Proyecto iOS generado por Capacitor
├── src/                    # Código fuente de la aplicación Angular
│   ├── app/                # Componentes, servicios y módulos Angular
│   ├── assets/             # Recursos estáticos (imágenes, fuentes, etc.)
│   └── theme/              # Estilos globales y variables de tema
├── capacitor.config.ts     # Configuración de Capacitor
└── package.json            # Dependencias y scripts NPM
```

## Comandos disponibles

### Desarrollo

```bash
# Iniciar servidor de desarrollo
npm start

# Compilar la aplicación web
npm run build
```

### Capacitor

```bash
# Sincronizar cambios con proyectos nativos
npx cap sync

# Abrir proyecto en Android Studio
npx cap open android

# Abrir proyecto en Xcode
npx cap open ios
```

### Generación automática de APK e IPA

#### Android

Para generar automáticamente los archivos APK (debug y release):

```bash
./build-android-auto.sh
```

Los archivos generados se encontrarán en:
- Debug APK: `build/android/app-debug.apk`
- Release APK: `build/android/app-release.apk`

#### iOS

Para generar automáticamente los archivos IPA (debug y release):

```bash
./build-ios-auto.sh
```

Los archivos generados se encontrarán en:
- Debug IPA: `build/ios/debug/App.ipa`
- Release IPA: `build/ios/release/App.ipa`

## Configuración específica de plataformas

### Android

El proyecto está configurado para usar Java 21.

Archivos clave:
- `android/app/build.gradle`: Configuración de compilación de Android
- `android/app/capacitor.build.gradle`: Configuración de Capacitor para Android

### iOS

Requisitos:
- macOS
- Xcode 14+
- Cocoapods

Archivos clave:
- `ios/App/Podfile`: Configuración de dependencias iOS
- `ios/App/App/Info.plist`: Configuración de la aplicación iOS

## Solución de problemas comunes

### Error de versión de Java en Android

Si encuentras errores relacionados con la versión de Java al compilar para Android, asegúrate de:

1. Tener instalado Java JDK 21
2. Verificar que el archivo `android/app/capacitor.build.gradle` tenga configurado:
   ```gradle
   compileOptions {
       sourceCompatibility JavaVersion.VERSION_21
       targetCompatibility JavaVersion.VERSION_21
   }
   ```

### Errores de Cocoapods en iOS

Si encuentras errores al ejecutar `pod install` para iOS:

```bash
# Actualizar Cocoapods
sudo gem install cocoapods

# Limpiar caché de Cocoapods
pod cache clean --all

# Reinstalar dependencias
cd ios/App
pod install --repo-update
```

## Licencia

Este proyecto está licenciado bajo [insertar licencia aquí] 