package com.bleguard.scanner.ui

import android.Manifest
import android.content.Intent
import android.os.Build
import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.rotate
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.bleguard.scanner.model.*
import com.bleguard.scanner.service.BLEScannerService
import com.bleguard.scanner.utils.BLEUtils
import com.bleguard.scanner.utils.PreferencesManager
import kotlinx.coroutines.delay
import kotlin.math.*

// Color definitions
val NeonCyan = Color(0xFF00FFFF)
val NeonPurple = Color(0xFF9D00FF)
val NeonBlue = Color(0xFF0066FF)
val NeonGreen = Color(0xFF00FF66)
val NeonPink = Color(0xFFFF00AA)
val NeonOrange = Color(0xFFFF6600)
val NeonRed = Color(0xFFFF0044)
val BlackPrimary = Color(0xFF0D0D0D)
val BlackSecondary = Color(0xFF1A1A1A)
val BlackSurface = Color(0xFF242424)
val BlackCard = Color(0xFF2D2D2D)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MainScreen() {
    var isScanning by remember { mutableStateOf(false) }
    var selectedTab by remember { mutableIntStateOf(0) }
    var showSettings by remember { mutableStateOf(false) }
    
    val isBluetoothEnabled = remember { BLEUtils.isBLEEnabled(LocalContext.current) }
    val isLocationEnabled = remember { BLEUtils.isLocationEnabled(LocalContext.current) }
    val hasPermissions = remember { BLEUtils.hasRequiredPermissions(LocalContext.current) }
    
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(BlackPrimary)
    ) {
        Column(
            modifier = Modifier.fillMaxSize()
        ) {
            // Top Bar
            TopBar(
                isScanning = isScanning,
                onSettingsClick = { showSettings = true }
            )
            
            // Tab Row
            TabRow(
                selectedTabIndex = selectedTab,
                containerColor = BlackSecondary,
                contentColor = NeonCyan
            ) {
                TabItem(0, "Scanner", Icons.Default.radar)
                TabItem(1, "Detections", Icons.Default.bluetooth_searching)
                TabItem(2, "Map", Icons.Default.map)
                TabItem(3, "Status", Icons.Default.analytics)
            }
            
            // Content
            when (selectedTab) {
                0 -> ScannerTab(
                    isScanning = isScanning,
                    onToggleScan = { 
                        isScanning = !isScanning
                        startScanService(isScanning)
                    },
                    bluetoothEnabled = isBluetoothEnabled,
                    locationEnabled = isLocationEnabled,
                    hasPermissions = hasPermissions
                )
                1 -> DetectionsTab()
                2 -> MapTab()
                3 -> StatusTab()
            }
        }
        
        // Settings Modal
        if (showSettings) {
            SettingsModal(onDismiss = { showSettings = false })
        }
    }
}

@Composable
fun TopBar(isScanning: Boolean, onSettingsClick: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(BlackSecondary)
            .padding(horizontal = 16.dp, vertical = 12.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column {
            Text(
                text = "BLE GUARD",
                color = NeonCyan,
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold,
                letterSpacing = 2.sp
            )
            Text(
                text = if (isScanning) "ACTIVE SCAN" else "IDLE",
                color = if (isScanning) NeonGreen else Color.Gray,
                fontSize = 12.sp
            )
        }
        
        Row {
            // Pulsing indicator when scanning
            if (isScanning) {
                Box(
                    modifier = Modifier
                        .size(8.dp)
                        .clip(CircleShape)
                        .background(NeonCyan)
                )
                Spacer(modifier = Modifier.width(8.dp))
            }
            
            IconButton(onClick = onSettingsClick) {
                Icon(
                    imageVector = Icons.Default.settings,
                    contentDescription = "Settings",
                    tint = Color.White
                )
            }
        }
    }
}

@Composable
fun TabItem(index: Int, label: String, icon: ImageVector) {
    Tab(
        selectedContentColor = NeonCyan,
        unselectedContentColor = Color.Gray,
        icon = {
            Icon(imageVector = icon, contentDescription = label)
        },
        text = {
            Text(label, fontSize = 10.sp)
        }
    )
}

@Composable
fun ScannerTab(
    isScanning: Boolean,
    onToggleScan: () -> Unit,
    bluetoothEnabled: Boolean,
    locationEnabled: Boolean,
    hasPermissions: Boolean
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // Radar Animation
        Box(
            modifier = Modifier
                .weight(1f)
                .fillMaxWidth(),
            contentAlignment = Alignment.Center
        ) {
            RadarAnimation(isScanning = isScanning)
        }
        
        // Status Info
        Card(
            modifier = Modifier.fillMaxWidth(),
            colors = CardDefaults.cardColors(containerColor = BlackCard)
        ) {
            Column(
                modifier = Modifier.padding(16.dp)
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceEvenly
                ) {
                    StatusIndicator(
                        label = "BLE",
                        isActive = bluetoothEnabled,
                        color = if (bluetoothEnabled) NeonGreen else NeonRed
                    )
                    StatusIndicator(
                        label = "GPS",
                        isActive = locationEnabled,
                        color = if (locationEnabled) NeonGreen else NeonRed
                    )
                    StatusIndicator(
                        label = "PERMS",
                        isActive = hasPermissions,
                        color = if (hasPermissions) NeonGreen else NeonRed
                    )
                }
            }
        }
        
        Spacer(modifier = Modifier.height(16.dp))
        
        // Action Button
        Button(
            onClick = onToggleScan,
            modifier = Modifier
                .fillMaxWidth()
                .height(56.dp),
            colors = ButtonDefaults.buttonColors(
                containerColor = if (isScanning) NeonRed else NeonCyan,
                contentColor = if (isScanning) Color.White else BlackPrimary
            ),
            enabled = bluetoothEnabled && locationEnabled && hasPermissions
        ) {
            Icon(
                imageVector = if (isScanning) Icons.Default.stop else Icons.Default.radar,
                contentDescription = null
            )
            Spacer(modifier = Modifier.width(8.dp))
            Text(
                text = if (isScanning) "STOP SCAN" else "START SCAN",
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold
            )
        }
    }
}

@Composable
fun RadarAnimation(isScanning: Boolean) {
    val infiniteTransition = rememberInfiniteTransition(label = "radar")
    val rotation by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 360f,
        animationSpec = infiniteRepeatable(
            animation = tween(3000, easing = LinearEasing),
            repeatMode = RepeatMode.Restart
        ),
        label = "rotation"
    )
    
    val pulseAnimation = rememberInfiniteTransition(label = "pulse")
    val pulseAlpha by pulseAnimation.animateFloat(
        initialValue = 0.3f,
        targetValue = 0.8f,
        animationSpec = infiniteRepeatable(
            animation = tween(1000, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "pulseAlpha"
    )
    
    Box(
        modifier = Modifier.size(250.dp),
        contentAlignment = Alignment.Center
    ) {
        // Radar grid circles
        for (i in 1..4) {
            Box(
                modifier = Modifier
                    .size((i * 50).dp)
                    .drawBehind {
                        drawCircle(
                            color = NeonCyan.copy(alpha = 0.1f),
                            style = Stroke(width = 1.dp.toPx())
                        )
                    }
            )
        }
        
        // Cross lines
        Box(
            modifier = Modifier
                .size(220.dp)
                .drawBehind {
                    drawLine(
                        color = NeonCyan.copy(alpha = 0.2f),
                        start = Offset(size.width / 2, 0f),
                        end = Offset(size.width / 2, size.height),
                        strokeWidth = 1.dp.toPx()
                    )
                    drawLine(
                        color = NeonCyan.copy(alpha = 0.2f),
                        start = Offset(0f, size.height / 2),
                        end = Offset(size.width, size.height / 2),
                        strokeWidth = 1.dp.toPx()
                    )
                }
        )
        
        // Sweep arm
        if (isScanning) {
            Box(
                modifier = Modifier
                    .size(200.dp)
                    .drawBehind {
                        rotate(rotation, pivot = center) {
                            drawLine(
                                color = NeonCyan.copy(alpha = 0.6f),
                                start = center,
                                end = Offset(size.width / 2, center.y),
                                strokeWidth = 3.dp.toPx(),
                                cap = StrokeCap.Round
                            )
                            drawArc(
                                brush = Brush.sweepGradient(
                                    colors = listOf(
                                        Color.Transparent,
                                        NeonCyan.copy(alpha = 0.3f),
                                        NeonCyan.copy(alpha = 0.5f)
                                    )
                                ),
                                startAngle = -30f,
                                sweepAngle = 60f,
                                useCenter = true
                            )
                        }
                    }
            )
        }
        
        // Center circle with glow
        Box(
            modifier = Modifier
                .size(30.dp)
                .clip(CircleShape)
                .background(
                    brush = Brush.radialGradient(
                        colors = listOf(
                            NeonCyan.copy(alpha = if (isScanning) pulseAlpha else 0.5f),
                            Color.Transparent
                        )
                    )
                )
        )
        
        // Center icon
        Icon(
            imageVector = Icons.Default.bluetooth_searching,
            contentDescription = "Scanner",
            tint = NeonCyan,
            modifier = Modifier.size(24.dp)
        )
    }
}

@Composable
fun StatusIndicator(label: String, isActive: Boolean, color: Color) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Box(
            modifier = Modifier
                .size(10.dp)
                .clip(CircleShape)
                .background(if (isActive) color else Color.Gray)
        )
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            text = label,
            color = if (isActive) color else Color.Gray,
            fontSize = 12.sp
        )
    }
}

@Composable
fun DetectionsTab() {
    var detections by remember { mutableStateOf<List<BLEDevice>>(emptyList()) }
    
    LaunchedEffect(Unit) {
        // Update from service
    }
    
    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .background(BlackPrimary)
            .padding(horizontal = 16.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        item {
            Text(
                text = "DETECTED DEVICES",
                color = NeonCyan,
                fontSize = 14.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.padding(vertical = 8.dp)
            )
        }
        
        if (detections.isEmpty()) {
            item {
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(containerColor = BlackCard)
                ) {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(32.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = "No devices detected",
                            color = Color.Gray
                        )
                    }
                }
            }
        } else {
            items(detections) { device ->
                DetectionCard(device = device)
            }
        }
    }
}

@Composable
fun DetectionCard(device: BLEDevice) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = BlackCard),
        border = BorderStroke(1.dp, NeonCyan.copy(alpha = 0.3f))
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(12.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = device.deviceAlias ?: device.deviceName ?: device.deviceAddress,
                    color = NeonCyan,
                    fontWeight = FontWeight.Bold
                )
                Text(
                    text = device.matchedIdentifier ?: device.deviceAddress,
                    color = Color.Gray,
                    fontSize = 10.sp
                )
                Text(
                    text = device.deviceType.name,
                    color = NeonPurple,
                    fontSize = 10.sp
                )
            }
            
            Column(horizontalAlignment = Alignment.End) {
                Text(
                    text = "${device.rssi} dBm",
                    color = when {
                        device.rssi >= -50 -> NeonGreen
                        device.rssi >= -70 -> NeonOrange
                        else -> NeonRed
                    },
                    fontWeight = FontWeight.Bold
                )
                Text(
                    text = BLEUtils.estimateRange(device.rssi),
                    color = Color.Gray,
                    fontSize = 10.sp
                )
            }
        }
    }
}

@Composable
fun MapTab() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(BlackPrimary)
    ) {
        // Map placeholder with dark styling
        Box(
            modifier = Modifier
                .weight(1f)
                .fillMaxWidth()
                .background(BlackSecondary),
            contentAlignment = Alignment.Center
        ) {
            Column(
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Icon(
                    imageVector = Icons.Default.map,
                    contentDescription = "Map",
                    tint = NeonCyan,
                    modifier = Modifier.size(64.dp)
                )
                Spacer(modifier = Modifier.height(16.dp))
                Text(
                    text = "Realtime Map",
                    color = NeonCyan,
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold
                )
                Text(
                    text = "Pin drops on detection",
                    color = Color.Gray
                )
            }
        }
        
        // Map controls
        Card(
            modifier = Modifier.fillMaxWidth(),
            colors = CardDefaults.cardColors(containerColor = BlackCard)
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                MapButton(icon = Icons.Default.my_location, label = "Location")
                MapButton(icon = Icons.Default.layers, label = "Cluster")
                MapButton(icon = Icons.Default.share, label = "Export")
                MapButton(icon = Icons.Default.delete_outline, label = "Clear")
            }
        }
    }
}

@Composable
fun MapButton(icon: ImageVector, label: String) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        IconButton(
            onClick = { /* Map action */ },
            modifier = Modifier
                .size(48.dp)
                .clip(CircleShape)
                .background(BlackSurface)
        ) {
            Icon(
                imageVector = icon,
                contentDescription = label,
                tint = NeonCyan
            )
        }
        Text(
            text = label,
            color = Color.Gray,
            fontSize = 10.sp
        )
    }
}

@Composable
fun StatusTab() {
    var systemStatus by remember { mutableStateOf<SystemStatus?>(null) }
    
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(BlackPrimary)
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Text(
            text = "SYSTEM STATUS",
            color = NeonCyan,
            fontSize = 14.sp,
            fontWeight = FontWeight.Bold
        )
        
        Card(
            modifier = Modifier.fillMaxWidth(),
            colors = CardDefaults.cardColors(containerColor = BlackCard)
        ) {
            Column(modifier = Modifier.padding(16.dp)) {
                StatusRow("BLE Scanner", "Active", NeonGreen)
                StatusRow("Location", "Enabled", NeonGreen)
                StatusRow("Battery", "85%", NeonCyan)
                StatusRow("CPU", "12%", NeonCyan)
                StatusRow("RAM", "45%", NeonCyan)
                StatusRow("Storage", "2.1GB", NeonCyan)
                StatusRow("Active Detections", "0", NeonGreen)
                StatusRow("Scan Uptime", "00:00:00", NeonGreen)
            }
        }
    }
}

@Composable
fun StatusRow(label: String, value: String, color: Color) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp),
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Text(text = label, color = Color.Gray)
        Text(text = value, color = color, fontWeight = FontWeight.Bold)
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsModal(onDismiss: () -> Unit) {
    val context = LocalContext.current
    
    AlertDialog(
        onDismissRequest = onDismiss,
        containerColor = BlackSecondary,
        title = {
            Text("SETTINGS", color = NeonCyan, fontWeight = FontWeight.Bold)
        },
        text = {
            Column(
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                SettingsSwitch(
                    label = "Sound Alerts",
                    checked = PreferencesManager.soundEnabled,
                    onCheckedChange = { PreferencesManager.soundEnabled = it }
                )
                SettingsSwitch(
                    label = "Vibration Alerts",
                    checked = PreferencesManager.vibrationEnabled,
                    onCheckedChange = { PreferencesManager.vibrationEnabled = it }
                )
                SettingsSwitch(
                    label = "Visual Alerts",
                    checked = PreferencesManager.visualAlertEnabled,
                    onCheckedChange = { PreferencesManager.visualAlertEnabled = it }
                )
                SettingsSwitch(
                    label = "Flashlight Alerts",
                    checked = PreferencesManager.flashlightEnabled,
                    onCheckedChange = { PreferencesManager.flashlightEnabled = it }
                )
                SettingsSwitch(
                    label = "Radar Animation",
                    checked = PreferencesManager.radarAnimationEnabled,
                    onCheckedChange = { PreferencesManager.radarAnimationEnabled = it }
                )
                SettingsSwitch(
                    label = "Map Display",
                    checked = PreferencesManager.mapEnabled,
                    onCheckedChange = { PreferencesManager.mapEnabled = it }
                )
                SettingsSwitch(
                    label = "Auto-start on Boot",
                    checked = PreferencesManager.autoStartOnBoot,
                    onCheckedChange = { PreferencesManager.autoStartOnBoot = it }
                )
            }
        },
        confirmButton = {
            TextButton(onClick = onDismiss) {
                Text("Done", color = NeonCyan)
            }
        }
    )
}

@Composable
fun SettingsSwitch(
    label: String,
    checked: Boolean,
    onCheckedChange: (Boolean) -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onCheckedChange(!checked) }
            .padding(vertical = 4.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(text = label, color = Color.White)
        Switch(
            checked = checked,
            onCheckedChange = onCheckedChange,
            colors = SwitchDefaults.colors(
                checkedThumbColor = NeonCyan,
                checkedTrackColor = NeonCyan.copy(alpha = 0.5f),
                uncheckedThumbColor = Color.Gray,
                uncheckedTrackColor = Color.Gray.copy(alpha = 0.5f)
            )
        )
    }
}

private fun startScanService(start: Boolean) {
    // Service start logic handled in MainActivity
}