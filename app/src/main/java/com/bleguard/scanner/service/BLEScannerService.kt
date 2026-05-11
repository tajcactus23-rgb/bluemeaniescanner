package com.bleguard.scanner.service

import android.annotation.SuppressLint
import android.app.*
import android.bluetooth.*
import android.bluetooth.le.*
import android.content.*
import android.content.pm.ServiceInfo
import android.location.Location
import android.os.*
import android.os.PowerManager.WakeLock
import androidx.core.app.NotificationCompat
import androidx.lifecycle.LifecycleService
import androidx.lifecycle.MutableLiveData
import com.bleguard.scanner.R
import com.bleguard.scanner.model.*
import com.bleguard.scanner.utils.*
import com.google.android.gms.location.*
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.*

class BLEScannerService : LifecycleService() {
    
    companion object {
        const val CHANNEL_ID = "ble_scanner_channel"
        const val NOTIFICATION_ID = 1001
        const val ACTION_START_SCAN = "com.bleguard.ACTION_START_SCAN"
        const val ACTION_STOP_SCAN = "com.bleguard.ACTION_STOP_SCAN"
        const val ACTION_OPEN_APP = "com.bleguard.ACTION_OPEN_APP"
        
        val isScanning = MutableLiveData<Boolean>(false)
        val recentDetections = MutableLiveData<List<BLEDevice>>(emptyList())
        val currentSession = MutableLiveData<ScanSession?>(null)
        val systemStatus = MutableLiveData<SystemStatus>()
    }
    
    private lateinit var bluetoothManager: BluetoothManager
    private lateinit var bluetoothAdapter: BluetoothAdapter
    private lateinit var bluetoothLeScanner: BluetoothLeScanner
    private lateinit var locationClient: FusedLocationProviderClient
    
    private var wakeLock: WakeLock? = null
    private var locationCallback: LocationCallback? = null
    
    private var currentSessionId: String? = null
    private var scanStartTime: Long = 0L
    private var detectedDevices = mutableMapOf<String, BLEDevice>()
    private var alertHandler = Handler(Looper.getMainLooper())
    private var flashlightJob: Job? = null
    
    private val serviceScope = CoroutineScope(Dispatchers.Default + SupervisorJob())
    
    private val bluetoothReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            when (intent?.action) {
                BluetoothAdapter.ACTION_STATE_CHANGED -> {
                    val state = intent.getIntExtra(BluetoothAdapter.EXTRA_STATE, BluetoothAdapter.ERROR)
                    updateSystemStatus(bleEnabled = state == BluetoothAdapter.STATE_ON)
                }
            }
        }
    }
    
    override fun onCreate() {
        super.onCreate()
        log("BLE Scanner Service created")
        
        bluetoothManager = getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        bluetoothAdapter = bluetoothManager.adapter
        bluetoothLeScanner = bluetoothAdapter.bluetoothLeScanner
        
        locationClient = LocationServices.getFusedLocationProviderClient(this)
        
        PreferencesManager.init(this)
        
        createNotificationChannel()
        registerBluetoothReceiver()
        registerLocationCallback()
        acquireWakeLock()
        
        updateSystemStatus()
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        super.onStartCommand(intent, flags, startId)
        
        when (intent?.action) {
            ACTION_START_SCAN -> startScan()
            ACTION_STOP_SCAN -> stopScan()
            ACTION_OPEN_APP -> openApp()
        }
        
        return START_STICKY
    }
    
    override fun onDestroy() {
        super.onDestroy()
        stopScan()
        unregisterReceiver(bluetoothReceiver)
        releaseWakeLock()
        locationCallback?.let { locationClient.removeLocationUpdates(it) }
        serviceScope.cancel()
        log("BLE Scanner Service destroyed")
    }
    
    @SuppressLint("MissingPermission")
    private fun startScan() {
        if (isScanning.value == true) {
            log("Scan already in progress")
            return
        }
        
        if (!BLEUtils.isBLEEnabled(this)) {
            log("BLE is not enabled")
            return
        }
        
        // Create new session
        currentSessionId = BLEUtils.generateSessionId()
        scanStartTime = System.currentTimeMillis()
        detectedDevices.clear()
        
        val session = ScanSession(
            sessionId = currentSessionId!!,
            startTime = scanStartTime,
            isActive = true
        )
        currentSession.value = session
        
        // Start foreground service
        startForegroundNotification("Scanning...", 0)
        
        // Start BLE scan
        try {
            val scanSettings = BLEUtils.getScanFilters()
            val scanFilters = BLEUtils.getScanSettings()
            
            bluetoothLeScanner.startScan(null, scanSettings, scanCallback)
            isScanning.value = true
            
            log("BLE scan started - Session: $currentSessionId")
            
            // Update notification periodically
            startNotificationUpdateTask()
            
        } catch (e: Exception) {
            log("Failed to start scan: ${e.message}")
        }
    }
    
    @SuppressLint("MissingPermission")
    private fun stopScan() {
        try {
            bluetoothLeScanner.stopScan(scanCallback)
        } catch (e: Exception) {
            log("Error stopping scan: ${e.message}")
        }
        
        isScanning.value = false
        
        // Update session
        currentSession.value = currentSession.value?.copy(
            endTime = System.currentTimeMillis(),
            isActive = false,
            totalDetections = detectedDevices.size,
            uniqueDevices = detectedDevices.keys.size
        )
        
        currentSessionId = null
        
        updateNotification("Scan stopped", 0)
        
        log("BLE scan stopped - Total detections: ${detectedDevices.size}")
    }
    
    private val scanCallback = object : ScanCallback() {
        @SuppressLint("MissingPermission")
        override fun onScanResult(callbackType: Int, result: ScanResult) {
            val device = result.device
            val address = BLEUtils.formatMacAddress(device.address)
            val name = device.name
            val rssi = result.rssi
            val txPower = result.scanRecord?.txPowerLevel
            
            // Check RSSI filter
            if (rssi < PreferencesManager.minRssiFilter) return
            
            // Check allowlist match
            val allowlist = PreferencesManager.getAllowlist()
            val (matchEntry, matchType) = BLEUtils.checkAllowlistMatch(address, name, allowlist)
            
            // Only proceed if matched (or show all devices for debugging)
            if (matchType == MatchType.NONE) {
                // Optionally show non-matched devices in live feed
            }
            
            val bleDevice = BLEDevice(
                deviceAddress = address,
                deviceName = name,
                rssi = rssi,
                timestamp = System.currentTimeMillis(),
                txPower = txPower,
                isConnectable = result.isConnectable,
                deviceType = BLEUtils.determineDeviceType(name),
                deviceAlias = matchEntry?.alias,
                matchedIdentifier = matchEntry?.identifier,
                matchedType = matchType,
                sessionId = currentSessionId ?: ""
            )
            
            // Add to detected devices (latest per device)
            detectedDevices[address] = bleDevice
            
            // Update live data
            recentDetections.value = detectedDevices.values.toList()
                .sortedByDescending { it.timestamp }
                .take(50)
            
            // Log detection if matched
            if (matchType != MatchType.NONE) {
                logMatchedDevice(bleDevice)
            }
            
            // Update notification
            updateNotification(
                "Active: ${detectedDevices.size} | Last: ${matchEntry?.alias ?: name ?: address}",
                detectedDevices.size
            )
            
            // Update system status
            updateSystemStatus(activeDetections = detectedDevices.size)
            
            // Trigger alerts
            if (matchType != MatchType.NONE) {
                triggerAlerts(bleDevice)
            }
            
            // Insert to database
            serviceScope.launch {
                insertDetection(bleDevice)
            }
        }
        
        override fun onScanFailed(errorCode: Int) {
            log("Scan failed: $errorCode")
        }
    }
    
    private suspend fun insertDetection(device: BLEDevice) {
        // Get current location
        val location = getCurrentLocation()
        
        val detection = DetectionLog(
            deviceAddress = device.deviceAddress,
            deviceName = device.deviceName,
            deviceAlias = device.deviceAlias,
            deviceType = device.deviceType.name,
            matchedIdentifier = device.matchedIdentifier,
            matchType = device.matchedType.name,
            rssi = device.rssi,
            estimatedRange = BLEUtils.estimateRange(device.rssi, device.txPower ?: -59),
            confidenceLevel = BLEUtils.calculateConfidence(device.rssi),
            latitude = location?.latitude ?: 0.0,
            longitude = location?.longitude ?: 0.0,
            altitude = location?.altitude,
            accuracy = location?.accuracy,
            timestamp = device.timestamp,
            sessionId = device.sessionId,
            notes = null
        )
        
        // Note: In production, insert to Room database here
        log("Detection logged: ${device.deviceAlias ?: device.deviceAddress}")
    }
    
    @SuppressLint("MissingPermission")
    private fun getCurrentLocation(): Location? {
        return try {
            var location: Location? = null
            val looper = Looper.getMainLooper()
            val condition = ConditionVariable()
            
            locationClient.lastLocation.addOnSuccessListener { loc ->
                location = loc
                condition.open()
            }
            
            condition.block(5000)
            location
        } catch (e: Exception) {
            null
        }
    }
    
    private fun logMatchedDevice(device: BLEDevice) {
        log("MATCHED: ${device.deviceAlias} (${device.deviceAddress}) RSSI: ${device.rssi}")
    }
    
    private fun triggerAlerts(device: BLEDevice) {
        // Sound alert
        if (PreferencesManager.soundEnabled) {
            playSoundAlert()
        }
        
        // Vibration alert
        if (PreferencesManager.vibrationEnabled) {
            vibrateAlert()
        }
        
        // Visual alert (handled in UI)
        if (PreferencesManager.visualAlertEnabled) {
            // Post to UI for visual effects
        }
        
        // Flashlight alert (if enabled and permitted)
        if (PreferencesManager.flashlightEnabled) {
            triggerFlashlightAlert()
        }
    }
    
    private fun playSoundAlert() {
        try {
            val notification = NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle("BLE Detection")
                .setContentText("Alert sound played")
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .build()
                
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.notify(1002, notification)
        } catch (e: Exception) {
            log("Sound error: ${e.message}")
        }
    }
    
    private fun vibrateAlert() {
        try {
            val vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val manager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
                manager.defaultVibrator
            } else {
                @Suppress("DEPRECATION")
                getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
            }
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                vibrator.vibrate(VibrationEffect.createOneShot(200, VibrationEffect.DEFAULT_AMPLITUDE))
            } else {
                @Suppress("DEPRECATION")
                vibrator.vibrate(200)
            }
        } catch (e: Exception) {
            log("Vibrate error: ${e.message}")
        }
    }
    
    private fun triggerFlashlightAlert() {
        flashlightJob?.cancel()
        flashlightJob = serviceScope.launch {
            try {
                // Note: Camera permission needed for flashlight
                // In real implementation, use Camera2 API or camera manager
                repeat(3) {
                    // Toggle flashlight
                    delay(300)
                }
            } catch (e: Exception) {
                log("Flashlight error: ${e.message}")
            }
        }
    }
    
    private fun createNotificationChannel() {
        val channel = NotificationChannel(
            CHANNEL_ID,
            "BLE Scanner",
            NotificationManager.IMPORTANCE_LOW
        ).apply {
            description = "BLE Scanner notifications"
            setShowBadge(false)
        }
        
        val manager = getSystemService(NotificationManager::class.java)
        manager.createNotificationChannel(channel)
    }
    
    private fun startForegroundNotification(status: String, detectionCount: Int) {
        val notification = createNotification(status, detectionCount)
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_LOCATION
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }
    
    private fun updateNotification(status: String, detectionCount: Int) {
        val notification = createNotification(status, detectionCount)
        val manager = getSystemService(NotificationManager::class.java)
        manager.notify(NOTIFICATION_ID, notification)
    }
    
    private fun createNotification(status: String, detectionCount: Int): Notification {
        val lastDevice = recentDetections.value?.firstOrNull()
        
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("BLE Scanner Active")
            .setContentText("$status | Detections: $detectionCount")
            .setStyle(NotificationCompat.BigTextStyle()
                .bigText("$status\nDetected: ${detectionCount} devices\nLast: ${lastDevice?.deviceAlias ?: lastDevice?.deviceName ?: "Unknown"}"))
            .setSmallIcon(R.drawable.ic_ble_scanner)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setContentIntent(createOpenAppIntent())
            .addAction(R.drawable.ic_stop, "Stop", createStopIntent())
            .addAction(R.drawable.ic_open, "Open App", createOpenAppIntent())
            .build()
    }
    
    private fun createOpenAppIntent(): PendingIntent {
        val intent = Intent(this, com.bleguard.scanner.ui.MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        return PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_IMMUTABLE)
    }
    
    private fun createStopIntent(): PendingIntent {
        val intent = Intent(this, BLEScannerService::class.java).apply {
            action = ACTION_STOP_SCAN
        }
        return PendingIntent.getService(this, 1, intent, PendingIntent.FLAG_IMMUTABLE)
    }
    
    private fun openApp() {
        val intent = Intent(this, com.bleguard.scanner.ui.MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        startActivity(intent)
    }
    
    private fun startNotificationUpdateTask() {
        alertHandler.postDelayed(object : Runnable {
            override fun run() {
                if (isScanning.value == true) {
                    val uptime = System.currentTimeMillis() - scanStartTime
                    updateNotification(
                        "Scanning ${formatUptime(uptime)} | ${detectedDevices.size} devices",
                        detectedDevices.size
                    )
                    alertHandler.postDelayed(this, 5000)
                }
            }
        }, 5000)
    }
    
    private fun formatUptime(millis: Long): String {
        val seconds = millis / 1000
        val minutes = seconds / 60
        val hours = minutes / 60
        return when {
            hours > 0 -> "${hours}h ${minutes % 60}m"
            minutes > 0 -> "${minutes}m ${seconds % 60}s"
            else -> "${seconds}s"
        }
    }
    
    @SuppressLint("MissingPermission")
    private fun registerBluetoothReceiver() {
        val filter = IntentFilter(BluetoothAdapter.ACTION_STATE_CHANGED)
        registerReceiver(bluetoothReceiver, filter)
    }
    
    @SuppressLint("MissingPermission")
    private fun registerLocationCallback() {
        val locationRequest = LocationRequest.Builder(
            Priority.PRIORITY_HIGH_ACCURACY,
            10000L
        ).apply {
            setMinUpdateIntervalMillis(5000L)
        }.build()
        
        locationCallback = object : LocationCallback() {
            override fun onLocationResult(result: LocationResult) {
                result.lastLocation?.let { location ->
                    updateSystemStatus()
                }
            }
        }
        
        try {
            locationClient.requestLocationUpdates(locationRequest, locationCallback!!, Looper.getMainLooper())
        } catch (e: Exception) {
            log("Location callback error: ${e.message}")
        }
    }
    
    @SuppressLint("WakelockTimeout")
    private fun acquireWakeLock() {
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "BLEGuard::ScanWakeLock"
        ).apply {
            acquire()
        }
    }
    
    private fun releaseWakeLock() {
        wakeLock?.release()
        wakeLock = null
    }
    
    private fun updateSystemStatus(
        bleEnabled: Boolean = BLEUtils.isBLEEnabled(this),
        activeDetections: Int = detectedDevices.size
    ) {
        val batteryIntent = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
        val batteryLevel = batteryIntent?.getIntExtra(Intent.EXTRA_LEVEL, -1) ?: 0
        val batteryStatus = batteryIntent?.getIntExtra(Intent.EXTRA_STATUS, -1) ?: -1
        val isCharging = batteryStatus == Intent.BATTERY_STATUS_CHARGING
        
        val uptime = if (isScanning.value == true) {
            System.currentTimeMillis() - scanStartTime
        } else 0L
        
        systemStatus.value = SystemStatus(
            bleEnabled = bleEnabled,
            locationEnabled = BLEUtils.isLocationEnabled(this),
            cpuUsage = 0f, // Would need ActivityManager
            memoryUsage = 0f,
            batteryLevel = batteryLevel,
            batteryCharging = isCharging,
            storageAvailable = 0L, // Would need StatFs
            activeDetections = activeDetections,
            scanUptime = uptime
        )
    }
    
    private fun log(message: String) {
        android.util.Log.d("BLEGuard", message)
    }
}