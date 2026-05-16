/// Known Axon BLE MAC address OUIs
/// Sourced from public MAC lookup and research
class AxonOUI {
  AxonOUI._();

  /// Primary Axon OUI (from lookup.py research)
  static const String primary = '00:25:df';

  /// Additional Axon Networks OUIs (from research)
  static const List<String> all = [
    '00:25:df', // Primary Axon 
    '00:58:28', // Axon Networks
    '00:C0:D4', // Axon Networks
    '84:70:03', // Axon Networks
  ];

  /// Check if MAC address matches known Axon OUI
  static bool isAxon(String macAddress) {
    // Normalize MAC address to uppercase and remove separators
    final normalized = macAddress.toUpperCase().replaceAll(':', '').replaceAll('-', '');
    final oui = normalized.substring(0, 6);
    return all.any((o) => o.replaceAll(':', '').equalsIgnoreCase(oui));
  }

  /// Get partial MAC for display (privacy)
  static String maskMAC(String macAddress) {
    final parts = macAddress.toUpperCase().split(':');
    if (parts.length >= 6) {
      return '${parts[0]}:${parts[1]}:${parts[2]}:XX:XX:XX';
    }
    return 'XX:XX:XX:XX:XX:XX';
  }
}

/// BLE Service UUIDs commonly used by Axon devices
class AxonServiceUUIDs {
  AxonServiceUUIDs._();

  // Standard BLE service UUIDs
  static const String batteryService = '180f';
  static const String deviceInfo = '180a';
  static const String genericAccess = '1800';
  static const String genericAttribute = '1801';
}

/// BLE Characteristic UUIDs
class AxonCharacteristics {
  AxonCharacteristics._();

  static const String batteryLevel = '2a19';
  static const String manufacturerName = '2a29';
  static const String modelNumber = '2a24';
  static const String serialNumber = '2a25';
  static const String firmwareRevision = '2a26';
  static const String hardwareRevision = '2a27';
  static const String softwareRevision = '2a28';
}