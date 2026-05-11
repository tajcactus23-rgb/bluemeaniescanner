package com.jackscanner.ui.components

import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.jackscanner.ui.theme.*

@Composable
fun HolographicCard(
    modifier: Modifier = Modifier,
    borderColor: Color = CyanPrimary,
    glowIntensity: Float = 0.3f,
    content: @Composable ColumnScope.() -> Unit
) {
    val animatedGlow by animateFloatAsState(
        targetValue = if (glowIntensity > 0) 1f else 0f,
        animationSpec = tween(1000),
        label = "glow"
    )
    
    Box(
        modifier = modifier
            .clip(RoundedCornerShape(20.dp))
            .background(
                Brush.verticalGradient(
                    colors = listOf(
                        GlassBackground,
                        BackgroundCard.copy(alpha = 0.9f),
                        GlassBackground
                    )
                )
            )
    ) {
        // Border glow
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(
                    Brush.linearGradient(
                        colors = listOf(
                            borderColor.copy(alpha = animatedGlow * 0.5f),
                            Color.Transparent,
                            borderColor.copy(alpha = animatedGlow * 0.2f)
                        )
                    ),
                    alpha = 0.1f
                )
        )
        
        // Content
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            content = content
        )
    }
}

@Composable
fun StatCard(
    modifier: Modifier = Modifier,
    value: String,
    label: String,
    accentColor: Color = CyanPrimary
) {
    HolographicCard(
        modifier = modifier,
        borderColor = accentColor
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Text(
                text = value,
                style = MaterialTheme.typography.headlineLarge,
                color = accentColor
            )
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                text = label,
                style = MaterialTheme.typography.labelSmall,
                color = TextTertiary
            )
        }
    }
}

@Composable
fun ScanButton(
    modifier: Modifier = Modifier,
    isScanning: Boolean,
    onClick: () -> Unit
) {
    val infiniteTransition = rememberInfiniteTransition(label = "scanBtn")
    val glowAlpha by infiniteTransition.animateFloat(
        initialValue = 0.3f,
        targetValue = 0.8f,
        animationSpec = infiniteRepeatable(
            animation = tween(1000),
            repeatMode = RepeatMode.Reverse
        ),
        label = "glowAlpha"
    )
    
    Button(
        onClick = onClick,
        modifier = modifier
            .height(60.dp)
            .fillMaxWidth(),
        colors = ButtonDefaults.buttonColors(
            containerColor = if (isScanning) Danger else CyanPrimary,
            contentColor = if (isScanning) Color.White else BackgroundDeep
        ),
        shape = RoundedCornerShape(16.dp)
    ) {
        Text(
            text = if (isScanning) "STOP SCAN" else "START SCAN",
            style = MaterialTheme.typography.titleMedium
        )
    }
}

@Composable
fun DetectionAlertCard(
    modifier: Modifier = Modifier,
    deviceName: String,
    macAddress: String,
    rssi: Int,
    deviceType: String,
    timestamp: String
) {
    var visible by remember { mutableStateOf(true) }
    
    if (visible) {
        HolographicCard(
            modifier = modifier,
            borderColor = Danger,
            glowIntensity = 1f
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "⚠️",
                    style = MaterialTheme.typography.headlineMedium
                )
                Spacer(modifier = Modifier.width(12.dp))
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = deviceName,
                        style = MaterialTheme.typography.titleMedium,
                        color = Danger
                    )
                    Text(
                        text = macAddress,
                        style = MaterialTheme.typography.bodySmall,
                        color = Warning
                    )
                }
            }
            
            Spacer(modifier = Modifier.height(12.dp))
            
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(rssi.toString(), style = MaterialTheme.typography.titleMedium, color = Warning)
                    Text("dBm", style = MaterialTheme.typography.labelSmall, color = TextTertiary)
                }
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(deviceType, style = MaterialTheme.typography.titleMedium, color = CyanSecondary)
                    Text("TYPE", style = MaterialTheme.typography.labelSmall, color = TextTertiary)
                }
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(timestamp, style = MaterialTheme.typography.titleMedium, color = TextPrimary)
                    Text("TIME", style = MaterialTheme.typography.labelSmall, color = TextTertiary)
                }
            }
        }
    }
}