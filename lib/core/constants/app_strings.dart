/// App strings and constants
class AppStrings {
  AppStrings._();

  // App info
  static const String appName = 'BlueMeanie Scanner';
  static const String appVersion = '1.0.0';
  
  // Navigation labels
  static const String dashboard = 'Dashboard';
  static const String detectionLog = 'Log';
  static const String summary = 'Summary';
  static const String scoreboard = 'Scoreboard';
  static const String settings = 'Settings';

  // Dashboard
  static const String scanning = 'SCANNING';
  static const String idle = 'IDLE';
  static const String devicesFound = 'Devices Found';
  static const String lastDetection = 'Last Detection';
  static const String strongestSignal = 'Strongest Signal';
  static const String scanDuration = 'Scan Duration';
  static const String startScan = 'Start Scan';
  static const String stopScan = 'Stop Scan';

  // Detection
  static const String detectionLogEmpty = 'No detections yet';
  static const String rssi = 'RSSI';
  static const String distance = 'Distance';
  static const String direction = 'Direction';
  static const String deviceId = 'Device ID';

  // Settings
  static const String calibrate = 'Calibrate';
  static const String exportLogs = 'Export Logs';
  static const String themes = 'Themes';
  static const String about = 'About';
  static const String audioAlerts = 'Audio Alerts';
  static const String resetData = 'Reset All Data';

  // Calibration
  static const String calibrationTitle = 'Distance Calibration';
  static const String calibrationStep1 = 'Step 1: Place beacon at 1 meter';
  static const String calibrationStep2 = 'Step 2: Place beacon at 5 meters';
  static const String calibrationStep3 = 'Step 3: Place beacon at 10 meters';
  static const String startSampling = 'Start Sampling';
  static const String saveCalibration = 'Save Calibration';
  static const String calibrationComplete = 'Calibration Complete';

  // Scoreboard
  static const String longestSession = 'Longest Session';
  static const String beaconsDetected = 'Beacons Detected';
  static const String calibrationAccuracy = 'Calibration Accuracy';
  static const String totalDetections = 'Total Detections';

  // Achievements
  static const String firstDetection = 'First Detection';
  static const String centuryClub = 'Century Club';
  static const String longWatch = 'Long Watch';
  static const String perfectCalibration = 'Perfect Calibration';
  static const String signalHunter = 'Signal Hunter';

  // Notifications
  static const String notificationChannel = 'ble_scanner';
  static const String notificationTitle = 'Axon Scout Active';
  static const String notificationScanning = 'Scanning for team beacons...';
  static const String notificationIdle = 'Scanner idle';

  // About
  static const String aboutTitle = 'About Axon Scout';
  static const String authorizedUse = '''This application is designed for '
' 'internal private security team coordination only. '
' '
'Only detect devices your team owns/operates. '
'Do not use for targeting law enforcement or "
'other unauthorized personnel. '
' '
'Follow your organization\'s policies and '
'applicable laws.'''
;

  // Errors
  static const String bleNotAvailable = 'BLE not available on this device';
  static const String bleNotEnabled = 'Please enable Bluetooth';
  static const String locationRequired = 'Location permission required';
  static const String scanFailed = 'Scan failed to start';
}