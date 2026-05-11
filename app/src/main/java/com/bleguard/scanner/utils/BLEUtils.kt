package com.bleguard.scanner.utils

import android.Manifest
import android.bluetooth.*
import android.bluetooth.le.*
import android.content.Context
import android.content.pm.PackageManager
import android.location.LocationManager
import android.os.Build
import androidx.core.content.ContextCompat
import com.bleguard.scanner.model.*
import java.util.*

object BLEUtils {
    
    /**
     * Check if Bluetooth LE is available and enabled
     */
    fun isBLEAvailable(context: Context): Boolean {
        val bluetoothManager = context.getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager
        return bluetoothManager?.adapter != null
    }
    
    fun isBLEEnabled(context: Context): Boolean {
        val bluetoothManager = context.getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager
        return bluetoothManager?.adapter?.isEnabled == true
    }
    
    fun isLocationEnabled(context: Context): Boolean {
        val locationManager = context.getSystemService(Context.LOCATION_SERVICE) as? LocationManager
        return locationManager?.isProviderEnabled(LocationManager.GPS_PROVIDER) == true ||
               locationManager?.isProviderEnabled(LocationManager.NETWORK_PROVIDER) == true
    }
    
    fun hasRequiredPermissions(context: Context): Boolean {
        val permissions = getRequiredPermissions()
        return permissions.all { 
            ContextCompat.checkSelfPermission(context, it) == PackageManager.PERMISSION_GRANTED
        }
    }
    
    fun getRequiredPermissions(): List<String> {
        return buildList {
            add(Manifest.permission.ACCESS_FINE_LOCATION)
            add(Manifest.permission.ACCESS_COARSE_LOCATION)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                add(Manifest.permission.BLUETOOTH_SCAN)
                add(Manifest.permission.BLUETOOTH_CONNECT)
            }
            if (Build.VERSION_CODES.TIRAMISU < Build.VERSION.SDK_INT) {
                add(Manifest.permission.POST_NOTIFICATIONS)
            }
        }
    }
    
    /**
     * Extract OUI prefix from MAC address (first 3 octets)
     */
    fun getOUIPrefix(macAddress: String): String {
        val parts = macAddress.uppercase().split(":")
        return if (parts.size >= 3) {
            "${parts[0]}:${parts[1]}:${parts[2]}"
        } else {
            macAddress.take(8).uppercase()
        }
    }
    
    /**
     * Estimate distance from RSSI using path loss model
     * Returns estimated range in meters
     */
    fun estimateRange(rssi: Int, txPower: Int = -59): String {
        val distance = kotlin.math.pow(10.0, (txPower - rssi) / 20.0)
        return when {
            distance < 1 -> "<1m"
            distance < 10 -> "<10m"
            distance < 50 -> "<50m"
            distance < 100 -> "<100m"
            distance < 500 -> "<500m"
            else -> ">500m"
        }
    }
    
    /**
     * Calculate confidence level based on RSSI and stability
     */
    fun calculateConfidence(rssi: Int): String {
        return when {
            rssi >= -50 -> "HIGH"
            rssi >= -70 -> "MEDIUM"
            rssi >= -85 -> "LOW"
            else -> "MINIMAL"
        }
    }
    
    /**
     * Determine device type from advertised name
     */
    fun determineDeviceType(deviceName: String?): DeviceType {
        val name = deviceName?.lowercase() ?: return DeviceType.UNKNOWN
        return when {
            name.contains("beacon") || name.contains("ibeacon") -> DeviceType.BEACON
            name.contains("airtag") || name.contains("tile") || name.contains("tracker") -> DeviceType.TRACKER
            name.contains("sensor") || name.contains("tag") -> DeviceType.SENSOR
            name.contains("watch") || name.contains("fit") || name.contains("band") -> DeviceType.WEARABLE
            name.contains("speaker") || name.contains("audio") || name.contains("headphone") -> DeviceType.AUDIO_DEVICE
            name.contains("phone") || name.contains("iphone") || name.contains("pixel") -> DeviceType.PHONE
            name.contains("tablet") || name.contains("ipad") -> DeviceType.TABLET
            name.contains("laptop") || name.contains("macbook") || name.contains("pc") -> DeviceType.COMPUTER
            name.contains("car") || name.contains("tesla") || name.contains("vehicle") -> DeviceType.VEHICLE
            name.contains("home") || name.contains("smart") || name.contains("iot") -> DeviceType.IOT_DEVICE
            else -> DeviceType.OTHER
        }
    }
    
    /**
     * Check if device matches any allowlist entry
     */
    fun checkAllowlistMatch(
        deviceAddress: String,
        deviceName: String?,
        allowlist: List<AllowlistEntryData>
    ): Pair<AllowlistEntryData?, MatchType> {
        val ouiPrefix = getOUIPrefix(deviceAddress)
        val upperAddress = deviceAddress.uppercase().replace("-", ":")
        
        for (entry in allowlist) {
            if (!entry.isEnabled) continue
            
            val identifier = entry.identifier.uppercase().replace("-", ":")
            
            // Check exact match
            if (upperAddress == identifier || deviceName?.uppercase()?.contains(identifier) == true) {
                return entry to MatchType.EXACT
            }
            
            // Check OUI prefix match
            if (entry.identifierType == "OUI_PREFIX" && upperAddress.startsWith(identifier)) {
                return entry to MatchType.OUI_PREFIX
            }
            
            // Check custom prefix match
            if (entry.identifierType == "CUSTOM_PREFIX" && upperAddress.startsWith(identifier)) {
                return entry to MatchType.CUSTOM_PREFIX
            }
        }
        
        return null to MatchType.NONE
    }
    
    /**
     * Get Bluetooth scan settings
     */
    fun getScanSettings(): ScanSettings {
        return ScanSettings.Builder()
            .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY)
            .setReportDelay(0)
            .setKeepWifiScanAlive(true)
            .build()
    }
    
    /**
     * Get scan filters (none for passive scanning)
     */
    fun getScanFilters(): List<ScanFilter> {
        // No filters = scan all devices (passive mode)
        return emptyList()
    }
    
    /**
     * Format MAC address consistently
     */
    fun formatMacAddress(address: String): String {
        return address.uppercase().replace("-", ":")
    }
    
    /**
     * Generate unique session ID
     */
    fun generateSessionId(): String {
        return "scan_${System.currentTimeMillis()}_${UUID.randomUUID().toString().take(8)}"
    }
}