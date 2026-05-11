package com.jackscanner

import android.Manifest
import android.bluetooth.BluetoothManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.jackscanner.service.BleScanService

class MainActivity : AppCompatActivity() {
    
    private lateinit var btnScan: Button
    private lateinit var tvStatus: TextView
    private lateinit var tvDetections: TextView
    
    private var isScanning = false
    
    companion object {
        const val PERMISSION_REQUEST_CODE = 1001
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        btnScan = findViewById(R.id.btnScan)
        tvStatus = findViewById(R.id.tvStatus)
        tvDetections = findViewById(R.id.tvDetections)
        
        btnScan.setOnClickListener {
            if (checkPermissions()) {
                toggleScan()
            }
        }
        
        updateUI()
    }
    
    private fun checkPermissions(): Boolean {
        val permissions = mutableListOf<String>()
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_SCAN) != PackageManager.PERMISSION_GRANTED) {
                permissions.add(Manifest.permission.BLUETOOTH_SCAN)
            }
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED) {
                permissions.add(Manifest.permission.BLUETOOTH_CONNECT)
            }
        }
        
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            permissions.add(Manifest.permission.ACCESS_FINE_LOCATION)
        }
        
        if (permissions.isNotEmpty()) {
            ActivityCompat.requestPermissions(this, permissions.toTypedArray(), PERMISSION_REQUEST_CODE)
            return false
        }
        
        return true
    }
    
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == PERMISSION_REQUEST_CODE) {
            toggleScan()
        }
    }
    
    private fun toggleScan() {
        isScanning = !isScanning
        
        val intent = Intent(this, BleScanService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
        
        updateUI()
    }
    
    private fun updateUI() {
        btnScan.text = if (isScanning) "STOP SCAN" else "START SCAN"
        tvStatus.text = if (isScanning) "Scanning..." else "Idle"
    }
}