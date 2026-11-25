# SEPREC

Aplicación móvil de SEPREC desarrollada con Flutter. La aplicación consulta
servicios web de SEPREC, muestra información de trámites y empresas, permite
consultar ubicaciones en mapas y utiliza la cámara para leer códigos QR.

## Requerimientos

### Requerimientos generales

- Flutter en el canal `stable`.
- Dart SDK `>=3.5.4 <4.0.0` (definido en `pubspec.yaml`).
- Git.
- Conexión a Internet para descargar dependencias y consultar las APIs.

### Android

- Android Studio con el Android SDK instalado.
- Android SDK Platform 37 y herramientas de compilación compatibles.
- JDK 17. El proyecto configura Java y Kotlin con compatibilidad 17.
- Un emulador o dispositivo físico con Android API 29 o superior.
- El dispositivo debe tener arquitectura ARM64 (`arm64-v8a`).
- Licencias de Android SDK aceptadas.

La aplicación solicita permisos de cámara y ubicación. Para probar el lector
QR se necesita una cámara funcional; para consultar empresas cercanas se debe
conceder el permiso de ubicación.

### iOS (opcional)

- macOS.
- Xcode y sus herramientas de línea de comandos.
- CocoaPods.
- Un simulador o dispositivo iOS compatible.

## Instalación

1. Clonar el repositorio y entrar en la carpeta del proyecto:

   ```bash
   git clone <URL_DEL_REPOSITORIO>
   cd app-seprec
   ```

2. Comprobar que Flutter y las herramientas nativas estén disponibles:

   ```bash
   flutter doctor -v
   ```

   Resolver cualquier error indicado por `flutter doctor`. En versiones
   recientes de Flutter, la opción `--android-licenses` ya no es necesaria.
   Si Android Studio solicita licencias, aceptarlas desde **SDK Manager**.

3. Instalar las dependencias de Dart/Flutter:

   ```bash
   flutter pub get
   ```

4. Verificar los dispositivos disponibles:

   ```bash
   flutter devices
   ```

## Ejecutar en modo desarrollo

Con un dispositivo o emulador conectado:

```bash
flutter run
```

Para seleccionar un dispositivo específico:

```bash
flutter run -d <ID_DEL_DISPOSITIVO>
```

Ejemplo para un emulador Android:

```bash
flutter run -d emulator-5554
```

flutter run -d chrome

La aplicación está configurada para ejecutarse en orientación vertical.

## Pruebas y análisis

Ejecutar las pruebas automatizadas:

```bash
flutter test
```

Ejecutar el análisis estático:

```bash
flutter analyze
```

## Generar una aplicación Android

APK de release:

```bash
flutter build apk --release
```

El archivo se genera en:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Android App Bundle para publicar en Google Play:

```bash
flutter build appbundle --release
```

El archivo se genera en:

```text
build/app/outputs/bundle/release/app-release.aab
```

### Firma de release

Si no existe `android/key.properties`, el proyecto usa la firma debug para
facilitar las compilaciones locales. Esa APK no debe publicarse ni distribuirse
como versión oficial.

Para generar una versión firmada para distribución, configurar las credenciales
de firma en `android/key.properties` y el almacén de claves correspondiente. No
subir ese archivo ni las contraseñas al repositorio.

## Servicios utilizados

La aplicación consume principalmente los servicios de:

```text
https://servicios.seprec.gob.bo/api
```

También utiliza servicios externos para mapas y enlaces informativos. Si las
consultas no cargan, comprobar la conexión a Internet y la disponibilidad de
los servicios remotos.

## Solución de problemas

- **No se encuentra ningún dispositivo:** iniciar un emulador desde Android
  Studio o activar la depuración USB en un dispositivo Android.
- **Error de licencias:** abrir Android Studio, entrar a **SDK Manager** y
  aceptar las licencias o instalar los componentes solicitados. Después,
  comprobar nuevamente con `flutter doctor -v`.
- **Problemas de dependencias:** ejecutar `flutter clean` y después:

  ```bash
  flutter pub get
  ```

- **Cámara o ubicación no disponibles:** revisar los permisos de la aplicación
  en la configuración del dispositivo y concederlos nuevamente.
- **Error de Java/Gradle:** confirmar que Flutter esté usando JDK 17 y revisar
  la configuración de `JAVA_HOME` o de Android Studio.

## Estructura principal

```text
lib/       Código fuente de la aplicación
assets/    Imágenes y recursos gráficos
android/   Configuración y proyecto nativo Android
ios/       Configuración y proyecto nativo iOS
test/      Pruebas automatizadas
```
