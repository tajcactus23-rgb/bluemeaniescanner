/// Detection model representing a detected BLE device
class Detection {
  final int? id;
  final String deviceId; // MAC address (partial for privacy)
  final int rssi;
  final double estimatedDistance;
  final int? bearing; // direction in degrees if available
  final DateTime timestamp;
  final String? deviceLabel;
  final bool isTeamBeacon;

  Detection({
    this.id,
    required this.deviceId,
    required this.rssi,
    required this.estimatedDistance,
    this.bearing,
    required this.timestamp,
    this.deviceLabel,
    this.isTeamBeacon = true,
  });

  Detection copyWith({
    int? id,
    String? deviceId,
    int? rssi,
    double? estimatedDistance,
    int? bearing,
    DateTime? timestamp,
    String? deviceLabel,
    bool? isTeamBeacon,
  }) {
    return Detection(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      rssi: rssi ?? this.rssi,
      estimatedDistance: estimatedDistance ?? this.estimatedDistance,
      bearing: bearing ?? this.bearing,
      timestamp: timestamp ?? this.timestamp,
      deviceLabel: deviceLabel ?? this.deviceLabel,
      isTeamBeacon: isTeamBeacon ?? this.isTeamBeacon,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'device_id': deviceId,
    'rssi': rssi,
    'estimated_distance': estimatedDistance,
    'bearing': bearing,
    'timestamp': timestamp.toIso8601String(),
    'device_label': deviceLabel,
    'is_team_beacon': isTeamBeacon ? 1 : 0,
  };

  factory Detection.fromMap(Map<String, dynamic> map) => Detection(
    id: map['id'],
    deviceId: map['device_id'],
    rssi: map['rssi'],
    estimatedDistance: map['estimated_distance'],
    bearing: map['bearing'],
    timestamp: DateTime.parse(map['timestamp']),
    deviceLabel: map['device_label'],
    isTeamBeacon: map['is_team_beacon'] == 1,
  );

  /// Export format for txt
  String toExportFormat() {
    return '${timestamp.toIso8601String()},$deviceId,$rssi,${estimatedDistance.toStringAsFixed(1)}m,${bearing ?? "N/A"}';
  }
}