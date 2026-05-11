package com.bleguard.scanner.utils

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.Toast
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import java.io.BufferedReader
import java.io.InputStreamReader

object AllowlistManager {
    
    private const val EXPORT_MIME_TYPE = "application/json"
    private const val REQUEST_CODE_IMPORT = 1001
    private const val REQUEST_CODE_EXPORT = 1002
    
    /**
     * Export allowlist to file
     */
    fun exportAllowlist(context: Context, allowlist: List<AllowlistEntryData>): Intent {
        val json = Gson().toJson(allowlist)
        
        return Intent(Intent.ACTION_SEND).apply {
            type = EXPORT_MIME_TYPE
            putExtra(Intent.EXTRA_TEXT, json)
            putExtra(Intent.EXTRA_SUBJECT, "BLE Guard Allowlist Export")
        }
    }
    
    /**
     * Import allowlist from content URI
     */
    fun importAllowlist(context: Context, uri: Uri): List<AllowlistEntryData>? {
        return try {
            val inputStream = context.contentResolver.openInputStream(uri)
            val reader = BufferedReader(InputStreamReader(inputStream))
            val json = reader.readText()
            reader.close()
            
            val type = object : TypeToken<List<AllowlistEntryData>>() {}.type
            Gson().fromJson(json, type)
        } catch (e: Exception) {
            null
        }
    }
    
    /**
     * Create share intent for allowlist
     */
    fun createShareIntent(context: Context): Intent {
        val allowlist = PreferencesManager.getAllowlist()
        return exportAllowlist(context, allowlist)
    }
    
    /**
     * Validate identifier format
     */
    fun validateIdentifier(identifier: String): Boolean {
        // MAC address format: XX:XX:XX:XX:XX:XX or XX-XX-XX-XX-XX-XX
        val macPattern = Regex("^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$")
        
        // OUI prefix format: XX:XX:XX
        val ouiPattern = Regex("^([0-9A-Fa-f]{2}:){2}[0-9A-Fa-f]{2}$")
        
        return macPattern.matches(identifier) || ouiPattern.matches(identifier)
    }
    
    /**
     * Format identifier for storage
     */
    fun formatIdentifier(identifier: String): String {
        return identifier.uppercase().replace("-", ":")
    }
}

/**
 * Export detection logs to CSV/JSON
 */
object LogExporter {
    
    fun exportToJson(detections: List<Any>): String {
        return Gson().toJson(detections)
    }
    
    fun exportToCsv(detections: List<Any>): String {
        val sb = StringBuilder()
        sb.appendLine("timestamp,deviceAddress,deviceName,rssi,estimatedRange,latitude,longitude")
        
        for (detection in detections) {
            // Format fields
            sb.appendLine("...")
        }
        
        return sb.toString()
    }
    
    fun createShareIntent(context: Context, detections: List<Any>): Intent {
        val json = exportToJson(detections)
        
        return Intent(Intent.ACTION_SEND).apply {
            type = "application/json"
            putExtra(Intent.EXTRA_TEXT, json)
            putExtra(Intent.EXTRA_SUBJECT, "BLE Guard Detection Log")
        }
    }
}