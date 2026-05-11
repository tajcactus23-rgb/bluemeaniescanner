package com.bleguard.scanner.model

import androidx.room.Entity
import androidx.room.PrimaryKey

/**
 * Represents a detected BLE device
 */
data class BLEDevice(
    val deviceAddress: String,
    val deviceName: String?,
    val rssi: Int,
    val timestamp: Long,
    val txPower: Int?,
    val isConnectable: Boolean,
    val deviceType: DeviceType = DeviceType.UNKNOWN,
    val deviceAlias: String? = null,
    val matchedIdentifier: String? = null,
    val matchedType: MatchType = MatchType.NONE,
    val sessionId: String
)

/**
 * Device type categories
 */
enum class DeviceType {
    UNKNOWN,
    BEACON,
    TRACKER,
    SENSOR,
    WEARABLE,
    IOT_DEVICE,
    AUDIO_DEVICE,
    PHONE,
    TABLET,
    COMPUTER,
    VEHICLE,
    OTHER
}

/**
 * Type of identifier match
 */
enum class MatchType {
    NONE,
    EXACT,
    OUI_PREFIX,
    CUSTOM_PREFIX
}

/**
 * Detection log entry with location data
 */
@Entity(tableName = "detections")
data class DetectionLog(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0,
    val deviceAddress: String,
    val deviceName: String?,
    val deviceAlias: String?,
    val deviceType: String,
    val matchedIdentifier: String?,
    val matchType: String,
    val rssi: Int,
    val estimatedRange: String,
    val confidenceLevel: String,
    val latitude: Double,
    val longitude: Double,
    val altitude: Double?,
    val accuracy: Float?,
    val timestamp: Long,
    val sessionId: String,
    val notes: String?
)

/**
 * Allowlist entry for approved devices
 */
@Entity(tableName = "allowlist")
data class AllowlistEntry(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0,
    val identifier: String,
    val identifierType: String, // EXACT, OUI_PREFIX, CUSTOM_PREFIX
    val alias: String,
    val deviceType: String,
    val isEnabled: Boolean = true,
    val createdAt: Long = System.currentTimeMillis(),
    val notes: String?
)

/**
 * Scan session
 */
@Entity(tableName = "sessions")
data class ScanSession(
    @PrimaryKey
    val sessionId: String,
    val startTime: Long,
    val endTime: Long? = null,
    val isActive: Boolean = true,
    val totalDetections: Int = 0,
    val uniqueDevices: Int = 0
)

/**
 * App settings/configuration
 */
data class AppSettings(
    val soundEnabled: Boolean = true,
    val vibrationEnabled: Boolean = true,
    val visualAlertEnabled: Boolean = true,
    val flashlightEnabled: Boolean = false,
    val radarAnimationEnabled: Boolean = true,
    val mapEnabled: Boolean = true,
    val autoStartOnBoot: Boolean = false,
    val highAccuracyLocation: Boolean = true,
    val scanIntervalMs: Long = 1000L,
    val minRssiFilter: Int = -100
)

/**
 * System status info
 */
data class SystemStatus(
    val bleEnabled: Boolean = false,
    val locationEnabled: Boolean = false,
    val cpuUsage: Float = 0f,
    val memoryUsage: Float = 0f,
    val batteryLevel: Int = 0,
    val batteryCharging: Boolean = false,
    val storageAvailable: Long = 0L,
    val activeDetections: Int = 0,
    val scanUptime: Long = 0L
)