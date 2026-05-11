package com.bleguard.scanner.utils

import android.content.Context
import android.content.SharedPreferences
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken

object PreferencesManager {
    private const val PREFS_NAME = "bleguard_prefs"
    private const val KEY_SOUND_ENABLED = "sound_enabled"
    private const val KEY_VIBRATION_ENABLED = "vibration_enabled"
    private const val KEY_VISUAL_ALERT_ENABLED = "visual_alert_enabled"
    private const val KEY_FLASHLIGHT_ENABLED = "flashlight_enabled"
    private const val KEY_RADAR_ANIMATION_ENABLED = "radar_animation_enabled"
    private const val KEY_MAP_ENABLED = "map_enabled"
    private const val KEY_AUTO_START_ON_BOOT = "auto_start_on_boot"
    private const val KEY_HIGH_ACCURACY_LOCATION = "high_accuracy_location"
    private const val KEY_SCAN_INTERVAL_MS = "scan_interval_ms"
    private const val KEY_MIN_RSSI_FILTER = "min_rssi_filter"
    private const val KEY_ALLOWLIST_JSON = "allowlist_json"
    
    private lateinit var prefs: SharedPreferences
    
    fun init(context: Context) {
        prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    }
    
    var soundEnabled: Boolean
        get() = prefs.getBoolean(KEY_SOUND_ENABLED, true)
        set(value) = prefs.edit().putBoolean(KEY_SOUND_ENABLED, value).apply()
    
    var vibrationEnabled: Boolean
        get() = prefs.getBoolean(KEY_VIBRATION_ENABLED, true)
        set(value) = prefs.edit().putBoolean(KEY_VIBRATION_ENABLED, value).apply()
    
    var visualAlertEnabled: Boolean
        get() = prefs.getBoolean(KEY_VISUAL_ALERT_ENABLED, true)
        set(value) = prefs.edit().putBoolean(KEY_VISUAL_ALERT_ENABLED, value).apply()
    
    var flashlightEnabled: Boolean
        get() = prefs.getBoolean(KEY_FLASHLIGHT_ENABLED, false)
        set(value) = prefs.edit().putBoolean(KEY_FLASHLIGHT_ENABLED, value).apply()
    
    var radarAnimationEnabled: Boolean
        get() = prefs.getBoolean(KEY_RADAR_ANIMATION_ENABLED, true)
        set(value) = prefs.edit().putBoolean(KEY_RADAR_ANIMATION_ENABLED, value).apply()
    
    var mapEnabled: Boolean
        get() = prefs.getBoolean(KEY_MAP_ENABLED, true)
        set(value) = prefs.edit().putBoolean(KEY_MAP_ENABLED, value).apply()
    
    var autoStartOnBoot: Boolean
        get() = prefs.getBoolean(KEY_AUTO_START_ON_BOOT, false)
        set(value) = prefs.edit().putBoolean(KEY_AUTO_START_ON_BOOT, value).apply()
    
    var highAccuracyLocation: Boolean
        get() = prefs.getBoolean(KEY_HIGH_ACCURACY_LOCATION, true)
        set(value) = prefs.edit().putBoolean(KEY_HIGH_ACCURACY_LOCATION, value).apply()
    
    var scanIntervalMs: Long
        get() = prefs.getLong(KEY_SCAN_INTERVAL_MS, 1000L)
        set(value) = prefs.edit().putLong(KEY_SCAN_INTERVAL_MS, value).apply()
    
    var minRssiFilter: Int
        get() = prefs.getInt(KEY_MIN_RSSI_FILTER, -100)
        set(value) = prefs.edit().putInt(KEY_MIN_RSSI_FILTER, value).apply()
    
    fun getAllowlist(): List<AllowlistEntryData> {
        val json = prefs.getString(KEY_ALLOWLIST_JSON, null) ?: return getDefaultAllowlist()
        return try {
            val type = object : TypeToken<List<AllowlistEntryData>>() {}.type
            Gson().fromJson(json, type) ?: getDefaultAllowlist()
        } catch (e: Exception) {
            getDefaultAllowlist()
        }
    }
    
    fun saveAllowlist(allowlist: List<AllowlistEntryData>) {
        prefs.edit().putString(KEY_ALLOWLIST_JSON, Gson().toJson(allowlist)).apply()
    }
    
    private fun getDefaultAllowlist(): List<AllowlistEntryData> {
        return listOf(
            // Example OUI prefixes (add real approved ones here)
            AllowlistEntryData("A4:C1:38", "OUI_PREFIX", "Apple Device", "PHONE", true),
            AllowlistEntryData("F0:D2:F1", "OUI_PREFIX", "Apple Device", "PHONE", true),
            AllowlistEntryData("00:1A:22", "OUI_PREFIX", "Apple Device", "PHONE", true),
        )
    }
}

data class AllowlistEntryData(
    val identifier: String,
    val identifierType: String,
    val alias: String,
    val deviceType: String,
    val isEnabled: Boolean = true,
    val notes: String? = null
)