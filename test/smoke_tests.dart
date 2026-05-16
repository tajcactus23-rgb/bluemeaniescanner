import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:axon_scout/core/constants/axon_ouis.dart';
import 'package:axon_scout/core/utils/distance_estimator.dart';
import 'package:axon_scout/data/models/detection.dart';
import 'package:axon_scout/data/models/theme_model.dart';

void main() {
  group('AxonOUI Tests', () {
    test('should identify Axon MAC addresses', () {
      expect(AxonOUI.isAxon('00:25:df:12:34:56'), isTrue);
      expect(AxonOUI.isAxon('00:58:28:AA:BB:CC'), isTrue);
      expect(AxonOUI.isAxon('00:C0:D4:11:22:33'), isTrue);
      expect(AxonOUI.isAxon('84:70:03:44:55:66'), isTrue);
    });

    test('should reject non-Axon MAC addresses', () {
      expect(AxonOUI.isAxon('AA:BB:CC:DD:EE:FF'), isFalse);
      expect(AxonOUI.isAxon('00:11:22:33:44:55'), isFalse);
    });

    test('should mask MAC addresses for privacy', () {
      expect(AxonOUI.maskMAC('00:25:df:12:34:56'), equals('00:25:DF:XX:XX:XX'));
      expect(AxonOUI.maskMAC('AA:BB:CC:DD:EE:FF'), equals('AA:BB:CC:XX:XX:XX'));
    });
  });

  group('DistanceEstimator Tests', () {
    test('should estimate distance from RSSI', () {
      // At -59 RSSI with default TxPower, should be ~1m
      final distance1m = DistanceEstimator.estimateDistance(rssi: -59);
      expect(distance1m, closeTo(1.0, 0.5));

      // At -80 RSSI, should be ~10m
      final distance10m = DistanceEstimator.estimateDistance(rssi: -80);
      expect(distance10m, closeTo(10.0, 5.0));
    });

    test('should categorize signal strength', () {
      expect(
        DistanceEstimator.getSignalStrength(2.0),
        equals(SignalStrength.strong),
      );
      expect(
        DistanceEstimator.getSignalStrength(5.0),
        equals(SignalStrength.medium),
      );
      expect(
        DistanceEstimator.getSignalStrength(15.0),
        equals(SignalStrength.weak),
      );
    });

    test('should format distance for display', () {
      expect(formatDistance(0.5), equals('50 cm'));
      expect(formatDistance(2.5), equals('2.5 m'));
      expect(formatDistance(15.0), equals('15 m'));
    });
  });

  group('Theme Tests', () {
    test('should have all predefined themes', () {
      expect(Themes.all.length, greaterThanOrEqualTo(8));
      expect(Themes.all.map((t) => t.id), contains('cyberpunk'));
      expect(Themes.all.map((t) => t.id), contains('matrix'));
    });

    test('should convert theme to ThemeData', () {
      final theme = Themes.cyberpunk;
      final themeData = theme.toThemeData();
      expect(themeData.brightness, equals(Brightness.dark));
    });

    test('should serialize and deserialize themes', () {
      final theme = Themes.cyberpunk;
      final json = theme.toJson();
      final restored = ThemeModel.fromJson(json);
      expect(restored.id, equals(theme.id));
      expect(restored.primaryColor, equals(theme.primaryColor));
    });
  });

  group('Detection Model Tests', () {
    test('should serialize detection to map', () {
      final detection = Detection(
        id: 1,
        deviceId: '00:25:DF:XX:XX:XX',
        rssi: -65,
        estimatedDistance: 2.5,
        timestamp: DateTime(2024, 1, 1, 12, 0, 0),
      );

      final map = detection.toMap();
      expect(map['device_id'], equals('00:25:DF:XX:XX:XX'));
      expect(map['rssi'], equals(-65));
      expect(map['estimated_distance'], equals(2.5));
    });

    test('should deserialize detection from map', () {
      final map = {
        'id': 1,
        'device_id': '00:25:DF:XX:XX:XX',
        'rssi': -65,
        'estimated_distance': 2.5,
        'bearing': 180,
        'timestamp': '2024-01-01T12:00:00.000',
        'device_label': null,
        'is_team_beacon': 1,
      };

      final detection = Detection.fromMap(map);
      expect(detection.deviceId, equals('00:25:DF:XX:XX:XX'));
      expect(detection.rssi, equals(-65));
      expect(detection.bearing, equals(180));
    });

    test('should export to text format', () {
      final detection = Detection(
        deviceId: '00:25:DF:XX:XX:XX',
        rssi: -65,
        estimatedDistance: 2.5,
        bearing: 180,
        timestamp: DateTime(2024, 1, 1, 12, 0, 0),
      );

      final export = detection.toExportFormat();
      expect(export, contains('00:25:DF:XX:XX:XX'));
      expect(export, contains('-65'));
      expect(export, contains('2.5m'));
    });
  });

  group('Calibration Tests', () {
    test('should create calibration data', () {
      final calibration = CalibrationData(
        rssi1m: -59,
        rssi5m: -75,
        rssi10m: -85,
      );

      expect(calibration.rssi1m, equals(-59));
      expect(calibration.rssi5m, equals(-75));
      expect(calibration.rssi10m, equals(-85));
    });

    test('should serialize calibration', () {
      final calibration = CalibrationData(
        rssi1m: -59,
        rssi5m: -75,
        rssi10m: -85,
        pathLossExponent: 2.5,
        calibratedAt: DateTime(2024, 1, 1),
      );

      final json = calibration.toJson();
      final restored = CalibrationData.fromJson(json);
      expect(restored.rssi1m, equals(-59));
      expect(restored.pathLossExponent, equals(2.5));
    });
  });
}