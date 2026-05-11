package com.bleguard.scanner.ui

import android.Manifest
import android.content.Intent
import android.os.Build
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Surface
import androidx.compose.ui.Modifier
import androidx.core.view.WindowCompat
import com.bleguard.scanner.service.BLEScannerService
import com.bleguard.scanner.utils.BLEUtils

class MainActivity : ComponentActivity() {
    
    private val permissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { permissions ->
        val allGranted = permissions.values.all { it }
        if (!allGranted) {
            // Show permission rationale
        }
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Enable edge-to-edge
        WindowCompat.setDecorFitsSystemWindows(window, false)
        
        // Check and request permissions
        checkPermissions()
        
        setContent {
            Surface(modifier = Modifier.fillMaxSize()) {
                MainScreen()
            }
        }
    }
    
    private fun checkPermissions() {
        val permissions = mutableListOf<String>()
        
        // Location permissions
        permissions.add(Manifest.permission.ACCESS_FINE_LOCATION)
        permissions.add(Manifest.permission.ACCESS_COARSE_LOCATION)
        
        // Bluetooth permissions (Android 12+)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            permissions.add(Manifest.permission.BLUETOOTH_SCAN)
            permissions.add(Manifest.permission.BLUETOOTH_CONNECT)
        }
        
        // Notification permission (Android 13+)
        if (Build.VERSION_CODES.TIRAMISU < Build.VERSION.SDK_INT) {
            permissions.add(Manifest.permission.POST_NOTIFICATIONS)
        }
        
        // Request missing permissions
        val missingPermissions = permissions.filter {
            checkSelfPermission(it) != android.content.pm.PackageManager.PERMISSION_GRANTED
        }
        
        if (missingPermissions.isNotEmpty()) {
            permissionLauncher.launch(missingPermissions.toTypedArray())
        }
    }
    
    fun startScanService() {
        val intent = Intent(this, BLEScannerService::class.java).apply {
            action = BLEScannerService.ACTION_START_SCAN
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }
    
    fun stopScanService() {
        val intent = Intent(this, BLEScannerService::class.java).apply {
            action = BLEScannerService.ACTION_STOP_SCAN
        }
        startService(intent)
    }
}