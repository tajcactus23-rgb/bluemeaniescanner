import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../core/constants/axon_ouis.dart';
import '../../core/utils/distance_estimator.dart';
import '../models/detection.dart';

/// BLE Scanner service for Axon device detection
class BLEScannerService {
  static final BLEScannerService instance = BLEScannerService._init();
  
  final _detectionController = StreamController<Detection>.broadcast();
  final _scanStateController = StreamController<bool>.broadcast();
  
  Stream<Detection> get detectionStream => _detectionController.stream;
  Stream<bool> get scanStateStream => _scanStateController.stream;

  bool _isScanning = false;
  bool get isScanning => _isScanning;

  int _deviceCount = 0;
  int get deviceCount => _deviceCount;

  int _strongestRssi = -100;
  int get strongestRssi => _strongestRssi;

  DateTime? _lastDetection;
  DateTime? get lastDetection => _lastDetection;

  AudioPlayer? _audioPlayer;
  bool _soundEnabled = true;
  CalibrationData? _calibration;

  BLEScannerService._init();

  Future<void> init() async {
    _audioPlayer = AudioPlayer();
  }

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  void setCalibration(CalibrationData? calibration) {
    _calibration = calibration;
  }

  Future<bool> checkPermissions() async {
    // Check Bluetooth adapter
    if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
      return false;
    }
    return true;
  }

  Future<void> startScan() async {
    if (_isScanning) return;
    
    _isScanning = true;
    _deviceCount = 0;
    _strongestRssi = -100;
    _lastDetection = null;
    _scanStateController.add(true);

    // Start continuous scanning
    await _continuousScan();
  }

  Future<void> _continuousScan() async {
    while (_isScanning) {
      try {
        // Scan for 10 seconds
        final stream = FlutterBluePlus.scanResults;
        
        await FlutterBluePlus.startScan(
          timeout: const Duration(seconds: 10),
          continuousScan: true,
        );

        await for (final results in stream) {
          if (!_isScanning) break;
          
          for (final result in results) {
            _processDevice(result);
          }
        }
      } catch (e) {
        // Handle scan errors gracefully
      }
      
      // Pause for 2 seconds between scans
      if (_isScanning) {
        await Future.delayed(const Duration(seconds: 2));
      }
    }
  }

  void _processDevice(ScanResult result) {
    final device = result.device;
    final advertisementData = result.advertisementData;
    final rssi = result.rssi;
    final mac = device.remoteId.str;

    // Check if it's an Axon device
    if (!AxonOUI.isAxon(mac)) return;

    // Calculate distance
    final pathLoss = _calibration?.pathLossExponent ?? DistanceEstimator.defaultPathLossExponent;
    final txPower = _calibration?.rssi1m ?? DistanceEstimator.defaultTxPower;
    final distance = DistanceEstimator.estimateDistance(
      rssi: rssi,
      txPower: txPower,
      pathLossExponent: pathLoss,
    );

    // Update stats
    _deviceCount++;
    if (rssi > _strongestRssi) {
      _strongestRssi = rssi;
    }
    _lastDetection = DateTime.now();

    // Create detection
    final detection = Detection(
      deviceId: AxonOUI.maskMAC(mac),
      rssi: rssi,
      estimatedDistance: distance,
      timestamp: DateTime.now(),
    );

    // Emit detection
    _detectionController.add(detection);

    // Play sound if enabled
    if (_soundEnabled) {
      _playDetectionSound(rssi);
    }
  }

  Future<void> _playDetectionSound(int rssi) async {
    if (_audioPlayer == null) return;
    
    try {
      // Use different sound for strong vs weak signals
      if (rssi > -60) {
        await _audioPlayer!.play(AssetSource('sounds/detect_strong.mp3'));
      } else {
        await _audioPlayer!.play(AssetSource('sounds/detect_weak.mp3'));
      }
    } catch (e) {
      // Ignore audio errors
    }
  }

  Future<void> stopScan() async {
    if (!_isScanning) return;
    
    _isScanning = false;
    _scanStateController.add(false);
    
    try {
      await FlutterBluePlus.stopScan();
    } catch (e) {
      // Ignore stop errors
    }
  }

  void dispose() {
    stopScan();
    _detectionController.close();
    _scanStateController.close();
    _audioPlayer?.dispose();
  }
}

/// Update notification for foreground service
class ScannerNotificationService {
  static final ScannerNotificationService instance = 
      ScannerNotificationService._init();
  
  final _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  ScannerNotificationService._init();

  Future<void> init() async {
    if (_initialized) return;
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    
    await _notifications.initialize(initSettings);
    
    // Create notification channel
    const channel = AndroidNotificationChannel(
      'ble_scanner',
      'BLE Scanner',
      description: 'Shows when BLE scanner is active',
      importance: Importance.high,
    );
    
    _initialized = true;
  }

  Future<void> showScanningNotification({
    required int deviceCount,
    required int strongestRssi,
    DateTime? lastDetection,
  }) async {
    if (!_initialized) await init();

    final androidDetails = AndroidNotificationDetails(
      'ble_scanner',
      'BLE Scanner',
      channelDescription: 'Shows when BLE scanner is active',
      importance: Importance.high,
      ongoing: true,
      showWhen: false,
      playSound: false,
      enableVibration: false,
      contentInfo: '${deviceCount} devices found',
      subtitle: lastDetection != null 
        ? 'Last: ${_formatTime(lastDetection)} | RSSI: $strongestRssi dBm'
        : 'Scanning...',
    );

    await _notifications.show(
      1,
      'Axon Scout Active',
      deviceCount > 0 
        ? '$deviceCount team beacons detected' 
        : 'Scanning for team beacons...',
      androidDetails,
    );
  }

  Future<void> updateNotification({
    required bool isScanning,
    required int deviceCount,
    required int strongestRssi,
    DateTime? lastDetection,
  }) async {
    if (isScanning) {
      await showScanningNotification(
        deviceCount: deviceCount,
        strongestRssi: strongestRssi,
        lastDetection: lastDetection,
      );
    } else {
      await cancelNotification();
    }
  }

  Future<void> cancelNotification() async {
    await _notifications.cancel(1);
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}:'
        '${dt.second.toString().padLeft(2, '0')}';
  }
}