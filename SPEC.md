# BLE Axon Scanner - Specification Document

## 1. Project Overview

**Project Name:** Axon Scout  
**Type:** Android BLE Device Scanner Application  
**Core Functionality:** Internal BLE scanner for private security teams to detect and coordinate with team members' Axon BLE devices during large events, using MAC OUI matching with calibrated RSSI distance estimation.

**Target Users:** Private security team members using Axon body-worn cameras and tasers

---

## 2. UI/UX Specification

### 2.1 Screen Structure

| Screen | Purpose |
|--------|---------|
| **Dashboard** | Main scan interface with radar, stats, and device cards |
| **Detection Log** | Scrollable timeline of all detections |
| **Summary** | Graphs showing detection statistics |
| **Scoreboard** | Team achievements and records |
| **Settings** | Calibration, themes, export, about |

### 2.2 Navigation

- Bottom navigation bar with 5 tabs
- Each tab has icon + label
- Active tab highlighted in primary neon cyan

### 2.3 Visual Design

#### Color Palette (Cyberpunk Theme)

| Role | Color | Hex |
|------|-------|-----|
| Background Dark | Deep Black | #0a0a0f |
| Background Card | Dark Gray | #12121a |
| Primary Neon | Cyber Cyan | #00f0ff |
| Secondary Neon | Hot Pink | #ff00aa |
| Accent | Electric Blue | #00aaff |
| Warning | Neon Orange | #ff8800 |
| Success | Neon Green | #00ff88 |
| Text Primary | White | #ffffff |
| Text Secondary | Gray | #8888aa |
| Glow Effect | Cyan 30% | #00f0ff30 |

#### Typography

- **Headlines:** Orbitron (futuristic, bold)
- **Body:** Roboto Mono (technical feel)
- **Stats/Numbers:** Orbitron (monospace-style for data)

#### Spacing System

- Base unit: 8px
- Card padding: 16px
- Section spacing: 24px
- Page margins: 16px

### 2.4 Dashboard Components

#### Animated Radar Dish
- Circular radar display with concentric rings
- Rotating sweep line (360° in 4 seconds)
- Ping animation when device detected
- Central icon indicates scanner state

#### Signal Strength Orbit Rings
- 3 concentric circles representing signal zones
- Inner ring: < 3m (Strong)
- Middle ring: 3-10m (Medium)  
- Outer ring: > 10m (Weak)

#### Device Cards
- Glow intensity based on RSSI (stronger = brighter)
- Shows: Device ID (MAC), RSSI, Distance estimate, Last seen
- Pulse animation for recent detections

#### Compass Heading Widget
- Circular compass showing device directions
- Auto-updates based on phone orientation
- Shows bearing to detected devices

#### Statistics Panel
- Current scan duration
- Devices found this session
- Strongest RSSI
- Last detection timestamp

#### Detection Confidence Meter
- Visual indicator showing distance accuracy confidence
- Based on calibration completeness

### 2.5 Detection Log Screen

- Timeline view with entries
- Each entry shows:
  - Timestamp
  - Device MAC (partial for privacy)
  - RSSI value
  - Estimated distance
  - Direction (if available)
- Pull-to-refresh
- Export button in app bar

### 2.6 Summary Screen

- Detection count by hour (bar chart)
- Distance distribution (pie chart)
- Session statistics cards
- Reset data button

### 2.7 Scoreboard Screen

- Longest scan session timer
- Most team beacons detected
- Best calibration accuracy
- Cleanest signal lock achievements

### 2.8 Settings Screen

- **Calibration Flow:**
  - Place test beacon at 1m, sample RSSI
  - Place test beacon at 5m, sample RSSI
  - Place test beacon at 10m, sample RSSI
  - Save calibration
- **Theme Selection:** List of pre-built themes
- **Export:** Export logs to TXT
- **About:** App version, authorized use warning

---

## 3. Functionality Specification

### 3.1 Core Features

#### BLE Scanning (Priority: Critical)
- Continuous BLE scan in foreground
- Filter by known Axon OUIs:
  - 00:25:df (Primary Axon OUI)
  - 00:58:28 (Axon Networks)
  - 00:C0:D4 (Axon Networks)
  - 84:70:03 (Axon Networks)
- Scan cycle: 10 seconds continuous, pause 2 seconds

#### Audible Alert (Priority: High)
- Play sound when Axon device detected
- Configurable on/off in settings
- Different sound for strong/weak signal

#### Persistent Notification (Priority: Critical)
- Shows scan state (Scanning/Idle)
- Number of devices found in session
- Last detection timestamp
- Strongest RSSI value
- Tap to open app

#### Detection Log (Priority: High)
- Store all detections in local database
- Fields: timestamp, MAC, RSSI, distance, direction
- Query and display with filtering
- Clear log option

#### Export (Priority: Medium)
- Export detection log to TXT file
- Format: timestamp, MAC, RSSI, distance, direction
- Save to device Downloads folder

#### Calibration Flow (Priority: High)
- Guided 3-step calibration
- 1m, 5m, 10m distance samples
- Calculate path-loss exponent
- Save to local storage

#### RSSI Distance Estimation (Priority: High)
- Free-space path loss model
- d = 10^((TxPower - RSSI) / (10 * n))
- Default n = 2.5 (typical indoor)
- Calibrated n from user beacons

### 3.2 Gamification

#### Achievements
- First Detection: Detect your first team beacon
- Century Club: 100 total detections
- Long Watch: 1 hour continuous scan
- Perfect Calibration: Complete calibration
- Signal Hunter: 10 different devices detected

#### Scoreboard (Local Only)
- longest_scan_session (seconds)
- most_beacons_detected (count)
- best_calibration_accuracy (%)
- total_detection_count

### 3.3 Data Handling

- All data stored locally in SQLite (Room)
- No cloud upload
- No public sharing
- Export as plain text only
- User reset clears all data

---

## 4. Technical Specification

### 4.1 Technology Stack

- **Framework:** Flutter 3.x
- **Language:** Dart 3.x
- **State Management:** BLoC pattern
- **Local Database:** sqflite (SQLite)
- **BLE:** flutter_blue_plus
- **Charts:** fl_chart
- **Notifications:** flutter_local_notifications

### 4.2 Architecture

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   └── axe_ouis.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── theme_engine.dart
│   └── utils/
│       ├── distance_estimator.dart
│       └── logger.dart
├── data/
│   ├── database/
│   │   ├── database_helper.dart
│   │   └── tables/
│   │       ├── detection_table.dart
│   │       ├── achievement_table.dart
│   │       └── calibration_table.dart
│   ├── models/
│   │   ├── detection.dart
│   │   ├── achievement.dart
│   │   ├── calibration.dart
│   │   └── theme_model.dart
│   └── repositories/
│       ├── detection_repository.dart
│       ├── achievement_repository.dart
│       └── settings_repository.dart
├── services/
│   ├── ble/
│   │   ├── ble_scanner_service.dart
│   │   └── ble_parser.dart
│   └── notification/
│       └── notification_service.dart
└── ui/
    ├── screens/
    │   ├── dashboard/
    │   ├── detection_log/
    │   ├── summary/
    │   ├── scoreboard/
    │   └── settings/
    └── widgets/
        ├── radar/
        ├── device_card/
        ├── compass/
        ├── signal_rings/
        └── charts/
```

### 4.3 BLE Configuration

- **Scan Mode:** Low latency (for better detection)
- **Scan Windows:** 10000ms
- **Match Mode:** All matches (no filter for discovery)
- **Callback Type:** Earliest (faster notifications)

### 4.4 Permissions Required

- `android.permission.BLUETOOTH_SCAN`
- `android.permission.BLUETOOTH_CONNECT`
- `android.permission.ACCESS_FINE_LOCATION`
- `android.permission.ACCESS_COARSE_LOCATION`
- `android.permission.FOREGROUND_SERVICE`
- `android.permission.FOREGROUND_SERVICE_CONNECTED_DEVICE`
- `android.permission.POST_NOTIFICATIONS`
- `android.permission.VIBRATE` (for haptic feedback)

### 4.5Foreground Service

- Runs as foreground service with persistent notification
- Notification channel: "ble_scanner"
- Importance: HIGH
- Shows ongoing scan status

---

## 5. Device Identifiers

### Known Axon BLE OUIs (From Research)

| OUI | Vendor |
|-----|--------|
| 00:25:df | Axon (Primary) |
| 00:58:28 | Axon Networks |
| 00:C0:D4 | Axon Networks |
| 84:70:03 | Axon Networks |

### Detection Strategy

- Scan all BLE devices
- Filter by MAC OUI prefix match
- Log all matching devices
- Provide distance estimate

---

## 6. Authorized Use Notice

This application is designed for **internal private security team coordination only**. 

- Only detect devices your team owns/operates
- Do not use for targeting law enforcement
- Do not share detection data publicly
- Follow your organization's policies
- This tool is for authorized lab/testing environments

---

## 7. Build & Run Instructions

### Prerequisites
- Flutter 3.x SDK
- Android SDK 34+
- Android device with BLE support

### Build Commands
```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release
```

### Run Command
```bash
flutter run
```

### Smoke Tests
1. App launches without crash
2. BLE scanning starts/stops correctly
3. Detection log populates
4. Export creates file
5. Theme switching works

---

## 8. Privacy & Security

- All data stays on device
- No network calls (offline-only)
- MAC addresses partially masked in UI
- User reset removes all data
- No analytics or tracking
- Clear authorized use notice in settings