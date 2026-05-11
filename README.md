# BLE Guard - Passive BLE Detection Logger

Android-compatible passive BLE detection logger for authorized event-security use.

## CORE PURPOSE

**Passive BLE Scanning**: The app runs in the background, passively detects approved BLE device identifiers, logs detections, and displays them on a realtime map.

**LEGAL & COMPLIANT**: This application is designed for:
- Authorized event-security personnel
- Personal device auditing
- Security research with proper authorization
- Compliance with local regulations

## FEATURES

### Scanner
- Passive BLE device scanning (no spoofing, no injection)
- Foreground service with persistent notification
- Radar animation display
- Live device feed with RSSI indicators
- Configurable scan filters

### Detection Logging
- Timestamp
- Device type/category
- Device alias
- Matched identifier / OUI / prefix
- RSSI and estimated range
- Confidence level
- GPS coordinates at detection time
- Session ID

### Map Display
- Automatic pin drop on detection
- Pin details popup
- Device alias, RSSI, range, timestamp
- Coordinates display
- Detection count at location
- Marker clustering
- Session trail
- Export map log

### Alerts (Configurable)
- Sound cue
- Vibration pulse
- Visual flash/banner
- Neon radar pulse
- Map pin animation
- Detection card slide-in
- Flashlight blink (optional, permission required)

### Allowlist Management
- Add approved OUI/prefix
- Add exact identifier
- Add device alias
- Add device type
- Import/export allowlist
- Enable/disable entries

### System Status Display
- BLE scan state
- CPU, RAM, battery
- Storage
- Active detections
- Scan uptime

## UI STYLE

**Cyberpunk Private Investigator Dashboard**:
- Dark noir theme (#0D0D0D base)
- Neon cyan (#00FFFF), purple (#9D00FF), blue (#0066FF)
- Glowing pins and radar sweep
- Glass cards with animations
- Responsive Android UI

## BUILD

```bash
# Prerequisites
- Android Studio (latest) or Gradle 8.x
- JDK 17
- Android SDK 34

# Build debug APK
./gradlew assembleDebug

# Build release APK
./gradlew assembleRelease
```

## PERMISSIONS REQUIRED

```xml
<!-- Bluetooth -->
BLUETOOTH_SCAN (Android 12+)
BLUETOOTH_CONNECT (Android 12+)
BLUETOOTH (deprecated)
BLUETOOTH_ADMIN (deprecated)

<!-- Location -->
ACCESS_FINE_LOCATION
ACCESS_COARSE_LOCATION

<!-- Foreground Service -->
FOREGROUND_SERVICE
FOREGROUND_SERVICE_TYPE_LOCATION

<!-- Alerts -->
VIBRATE
FLASHLIGHT

<!-- Notifications -->
POST_NOTIFICATIONS (Android 13+)
```

## PROJECT STRUCTURE

```
BLEGuard/
├── app/
│   ├── src/main/
│   │   ├── java/com/bleguard/scanner/
│   │   │   ├── ui/           # Compose UI screens
│   │   │   ├── service/      # BLE scanner service
│   │   │   ├── model/        # Data models
│   │   │   ├── data/         # Room database
│   │   │   ├── utils/        # Utilities
│   │   │   └── receiver/     # Broadcast receivers
│   │   └── res/             # Resources
│   └── build.gradle
├── build.gradle
├── settings.gradle
└── gradle.properties
```

## USAGE

1. **Start Scanning**: Tap "START SCAN" button
2. **View Detections**: Switch to Detections tab
3. **View Map**: Switch to Map tab to see pin drops
4. **Configure**: Tap settings icon for alerts
5. **Add Allowlist**: Add approved device identifiers

## IMPORTANT NOTES

This application only:
- ✅ Passively listens for BLE signals
- ✅ Matches against user-approved allowlist
- ✅ Logs detections with GPS coordinates
- ✅ Shows pins on map
- ✅ Triggers user-configured alerts

This application does NOT:
- ❌ BLE spoofing or impersonation
- ❌ Beacon mode
- ❌ Packet injection
- ❌ Signal jamming
- ❌ Signal boosting
- ❌ Unauthorized tracking
- ❌ Exploitation

## SECURITY COMPLIANCE

- All detection is passive and transparent
- User-controlled allowlist only
- No background tracking without user consent
- Data stored locally (not transmitted)
- Proper permission requests

## LICENCE

For authorized use only. Ensure compliance with local laws and regulations.