import 'dart:math';

/// RSSI-based distance estimation using path-loss model
class DistanceEstimator {
  DistanceEstimator._();

  /// Default path-loss exponent (free space = 2, indoor typical = 2.5-3)
  static const double defaultPathLossExponent = 2.5;

  /// Default Tx power at 1 meter (typical BLE beacon)
  static const int defaultTxPower = -59;

  /// Mobile device Tx power (depends on device)
  static const int mobileTxPower = -69;

  /// Calculate estimated distance from RSSI
  /// Uses log-distance path loss model: d = 10^((TxPower - RSSI) / (10 * n))
  static double estimateDistance({
    required int rssi,
    int txPower = defaultTxPower,
    double pathLossExponent = defaultPathLossExponent,
  }) {
    if (rssi >= 0) return 0; // Invalid RSSI
    
    final distance = pow(10, (txPower - rssi) / (10 * pathLossExponent));
    return distance.toDouble();
  }

  /// Get signal strength category based on distance
  static SignalStrength getSignalStrength(double distance) {
    if (distance < 3) return SignalStrength.strong;
    if (distance < 10) return SignalStrength.medium;
    return SignalStrength.weak;
  }

  /// Get confidence level based on calibration
  static CalibrationConfidence getCalibrationConfidence(CalibrationData? calibration) {
    if (calibration == null) return CalibrationConfidence.none;
    
    int points = 0;
    if (calibration.rssi1m != null) points++;
    if (calibration.rssi5m != null) points++;
    if (calibration.rssi10m != null) points++;
    
    if (points >= 3) return CalibrationConfidence.high;
    if (points >= 2) return CalibrationConfidence.medium;
    if (points >= 1) return CalibrationConfidence.low;
    return CalibrationConfidence.none;
  }

  /// Calculate path-loss exponent from calibration data
  static double? calculatePathLossExponent(CalibrationData calibration) {
    if (calibration.rssi1m == null || calibration.rssi5m == null) return null;
    
    // n = (TxPower1m - RSSI5m) / (10 * log10(5)) - (TxPower1m - RSSI1m) / (10 * log10(1))
    // Simplified: n = (RSSI1m - RSSI5m) / (10 * log10(5))
    final rssiDiff = calibration.rssi1m! - calibration.rssi5m!;
    final distanceRatio = log(5) / ln10 * 10;
    return rssiDiff / distanceRatio;
  }
}

/// Signal strength categories
enum SignalStrength {
  strong,
  medium,
  weak,
}

/// Calibration confidence levels
enum CalibrationConfidence {
  none,
  low,
  medium,
  high,
}

/// Calibration data from user beacons
class CalibrationData {
  final int? rssi1m;
  final int? rssi5m;
  final int? rssi10m;
  final double? pathLossExponent;
  final DateTime? calibratedAt;

  const CalibrationData({
    this.rssi1m,
    this.rssi5m,
    this.rssi10m,
    this.pathLossExponent,
    this.calibratedAt,
  });

  CalibrationData copyWith({
    int? rssi1m,
    int? rssi5m,
    int? rssi10m,
    double? pathLossExponent,
    DateTime? calibratedAt,
  }) {
    return CalibrationData(
      rssi1m: rssi1m ?? this.rssi1m,
      rssi5m: rssi5m ?? this.rssi5m,
      rssi10m: rssi10m ?? this.rssi10m,
      pathLossExponent: pathLossExponent ?? this.pathLossExponent,
      calibratedAt: calibratedAt ?? this.calibratedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'rssi1m': rssi1m,
    'rssi5m': rssi5m,
    'rssi10m': rssi10m,
    'pathLossExponent': pathLossExponent,
    'calibratedAt': calibratedAt?.toIso8601String(),
  };

  factory CalibrationData.fromJson(Map<String, dynamic> json) => CalibrationData(
    rssi1m: json['rssi1m'],
    rssi5m: json['rssi5m'],
    rssi10m: json['rssi10m'],
    pathLossExponent: json['pathLossExponent'],
    calibratedAt: json['calibratedAt'] != null 
      ? DateTime.parse(json['calibratedAt']) 
      : null,
  );
}

/// Helper to format distance for display
String formatDistance(double meters) {
  if (meters < 1) {
    return '${(meters * 100).toInt()} cm';
  } else if (meters < 10) {
    return '${meters.toStringAsFixed(1)} m';
  } else {
    return '${meters.toInt()} m';
  }
}