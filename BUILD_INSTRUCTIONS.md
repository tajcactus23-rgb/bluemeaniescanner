# Build & Run Instructions for Axon Scout

## Prerequisites

1. **Flutter SDK** (3.x or later)
   - Install from: https://docs.flutter.dev/get-started/install
   - Verify: `flutter --version`

2. **Android SDK** (API 23+)
   - Install via Android Studio or command line tools
   - Set ANDROID_HOME environment variable

3. **Hardware Requirements**
   - Android device with BLE support
   - Android 6.0 (API 23) or later

## Build Commands

### Debug Build
```bash
cd axon_scout

# Get dependencies
flutter pub get

# Build debug APK
flutter build apk --debug

# Output: build/app/outputs/flutter-apk/app-debug.apk
```

### Release Build
```bash
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Install to Device
```bash
# Connect device via USB with developer mode enabled
flutter install

# Or manually install the APK
adb install build/app/outputs/flutter-apk/app-debug.apk
```

## Running the App

### Via Flutter
```bash
flutter run
```

### Via ADB (without IDE)
```bash
adb install build/app/outputs/flutter-apk/app-debug.apk
adb shell am start -n com.axon.axon_scout/com.axon.axon_scout.MainActivity
```

## Smoke Tests

1. **App Launch Test**
   - Launch app - should show dashboard with radar visualization
   - No crashes

2. **BLE Permission Test**
   - Grant Bluetooth and Location permissions
   - Scanner should respond to start/stop

3. **Navigation Test**
   - Tap each bottom nav tab
   - All screens should load

4. **Theme Test**
   - Go to Settings
   - Tap different theme colors
   - UI should update

5. **Export Test**
   - Go to Detection Log
   - Tap export button
   - File should be created

## Project Structure

```
axon_scout/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_strings.dart
│   │   │   └── axon_ouis.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   └── theme_engine.dart
│   │   └── utils/
│   │       └── distance_estimator.dart
│   ├── data/
│   │   ├── database/
│   │   │   └── database_helper.dart
│   │   ├── models/
│   │   │   ├── detection.dart
│   │   │   ├── achievement.dart
│   │   │   └── theme_model.dart
│   │   └── repositories/
│   ├── services/
│   │   ├── ble/
│   │   │   └── ble_scanner_service.dart
│   │   └── notification/
│   │       └── notification_service.dart
│   └── ui/
│       ├── screens/
│       ├── widgets/
│       └── bloc/
├── android/
├── assets/
│   ├── sounds/
│   └── fonts/
├── pubspec.yaml
└── README.md
```

## Known Issues

1. **BLE on Android 12+**
   - Requires BLUETOOTH_SCAN and BLUETOOTH_CONNECT permissions
   - Manifest already configured

2. **Location Permission**
   - Required for BLE scanning on Android 9-10
   - Android 11+ may not require but recommended

3. **Audio Assets**
   - Add detect_strong.mp3 and detect_weak.mp3 to assets/sounds/
   - Or remove audio code if not needed

## Support

- Authorized use only - internal security team coordination
- For bugs/issues in the app code itself