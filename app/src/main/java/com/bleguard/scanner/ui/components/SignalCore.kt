package com.bleguard.scanner.ui.components

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import androidx.compose.animation.core.*
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.rotate
import androidx.compose.ui.unit.dp

/**
 * Signal Core - Main visual centrepiece animation
 */
@Composable
fun SignalCore(
    isScanning: Boolean,
    isDetecting: Boolean,
    rssi: Int = -100,
    confidence: Float = 0f,
    modifier: Modifier = Modifier
) {
    val infiniteTransition = rememberInfiniteTransition(label = "signal_core")
    
    // Pulse animation
    val pulseScale by infiniteTransition.animateFloat(
        initialValue = 0.85f,
        targetValue = 1.15f,
        animationSpec = infiniteRepeatable(
            animation = tween(2000, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "pulse"
    )
    
    // Radar sweep rotation
    val rotation by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 360f,
        animationSpec = infiniteRepeatable(
            animation = tween(4000, easing = LinearEasing),
            repeatMode = RepeatMode.Restart
        ),
        label = "rotation"
    )
    
    // Alpha breathing
    val alpha by infiniteTransition.animateFloat(
        initialValue = 0.3f,
        targetValue = 0.9f,
        animationSpec = infiniteRepeatable(
            animation = tween(1500, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "alpha"
    )
    
    // Detection flash
    val detectionFlash by animateFloatAsState(
        targetValue = if (isDetecting) 1f else 0f,
        animationSpec = tween(300),
        label = "flash"
    )
    
    // Color palette based on state
    val coreColors = when {
        isDetecting -> listOf(Color(0xFFFF0044), Color(0xFFFF00FF), Color(0xFFFF6B35))
        isScanning -> listOf(Color(0xFF00FFFF), Color(0xFF00FF88), Color(0xFF00AAFF))
        else -> listOf(Color(0xFF4A5568), Color(0xFF2D3748), Color(0xFF1A202C))
    }
    
    Box(
        contentAlignment = Alignment.Center,
        modifier = modifier
    ) {
        Canvas(
            modifier = Modifier.fillMaxSize()
        ) {
            val centerX = size.width / 2
            val centerY = size.height / 2
            val baseRadius = minOf(size.width, size.height) / 2
            
            // Radar sweep when scanning
            if (isScanning) {
                rotate(rotation, pivot = Offset(centerX, centerY)) {
                    drawArc(
                        brush = Brush.sweepGradient(
                            colors = listOf(
                                coreColors[0].copy(alpha = 0.6f),
                                coreColors[1].copy(alpha = 0.3f),
                                coreColors[0].copy(alpha = 0.1f)
                            ),
                            center = Offset(centerX, centerY)
                        ),
                        startAngle = 0f,
                        sweepAngle = 120f,
                        useCenter = true,
                        topLeft = Offset(centerX - baseRadius * pulseScale, centerY - baseRadius * pulseScale),
                        size = androidx.compose.ui.geometry.Size(baseRadius * 2 * pulseScale, baseRadius * 2 * pulseScale)
                    )
                }
            }
            
            // Outer glow rings
            repeat(3) { i ->
                val ringScale = 0.25f + (i * 0.22f)
                val ringAlpha = (alpha - (i * 0.25f)).coerceIn(0.1f, 0.8f)
                
                drawCircle(
                    color = coreColors[0].copy(alpha = ringAlpha),
                    radius = baseRadius * ringScale,
                    center = Offset(centerX, centerY)
                )
            }
            
            // Detection flash effect
            if (detectionFlash > 0) {
                drawCircle(
                    color = Color(0xFFFF0044).copy(alpha = detectionFlash * 0.5f),
                    radius = baseRadius * 1.5f,
                    center = Offset(centerX, centerY)
                )
            }
            
            // Inner core
            drawCircle(
                brush = Brush.radialGradient(
                    colors = if (isDetecting) listOf(Color.White, Color(0xFFFF00FF))
                    else if (isScanning) listOf(Color.White, coreColors[0])
                    else listOf(Color.Gray, Color(0xFF2D3748)),
                    center = Offset(centerX, centerY),
                    radius = baseRadius * 0.2f
                ),
                radius = baseRadius * 0.2f,
                center = Offset(centerX, centerY)
            )
        }
    }
}

/**
 * Vibration Patterns Manager
 */
object VibrationPatterns {
    val patterns = mapOf(
        "pulse_ladder" to longArrayOf(0, 100, 100, 100, 100, 400),
        "heartbeat_split" to longArrayOf(0, 200, 200, 100, 100, 100, 400),
        "radar_knock" to longArrayOf(0, 100, 100, 100, 100, 200, 100, 100, 100, 400),
        "triple_surge" to longArrayOf(0, 100, 100, 100, 100, 400),
        "morse_storm" to longArrayOf(0, 100, 100, 200, 100, 200, 300),
        "reactor_wake" to longArrayOf(0, 500, 100, 100, 200),
        "signal_bite" to longArrayOf(0, 100, 200, 100, 400),
        "urgent_ripple" to longArrayOf(0, 100, 100, 100, 100, 200, 100, 100, 400),
        "deep_beacon" to longArrayOf(0, 500, 200, 500, 200, 200),
        "static_burst" to longArrayOf(0, 50, 50, 50, 50, 50, 50, 50, 50, 400)
    )
    
    fun playPattern(pattern: String, context: Context) {
        val vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val vm = context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
            vm.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }
        
        patterns[pattern]?.let {
            vibrator.vibrate(VibrationEffect.createWaveform(it, -1))
        }
    }
    
    val patternNames = listOf(
        "Pulse Ladder" to "pulse_ladder",
        "Heartbeat Split" to "heartbeat_split",
        "Radar Knock" to "radar_knock",
        "Triple Surge" to "triple_surge",
        "Morse Storm" to "morse_storm",
        "Reactor Wake" to "reactor_wake",
        "Signal Bite" to "signal_bite",
        "Urgent Ripple" to "urgent_ripple",
        "Deep Beacon" to "deep_beacon",
        "Static Burst" to "static_burst"
    )
}

/**
 * Theme Engine
 */
class ThemeEngine {
    private var seed: Long = 0xDEAD
    private val colors = mutableListOf<Color>()
    
    val primary: Color get() = colors.getOrElse(0) { Color(0xFF00FFFF) }
    val secondary: Color get() = colors.getOrElse(1) { Color(0xFFFF00FF) }
    val accent: Color get() = colors.getOrElse(2) { Color(0xFF00FF88) }
    val background: Color get() = Color(0xFF0A0E17)
    val surface: Color get() = Color(0xFF121A2E)
    val error: Color get() = Color(0xFFFF0044)
    val success: Color get() = Color(0xFF00FF88)
    val warning: Color get() = Color(0xFFFF6B35)
    val textPrimary: Color get() = Color.White
    val textSecondary: Color get() = Color(0xFF8892A8)
    val textMuted: Color get() = Color(0xFF4A5568)
    
    fun generateRandom() {
        seed = (0..0xFFFFFF).random().toLong()
    }
    
    fun generateFromSeed(s: Long) {
        seed = s
    }
    
    fun getRandomThemeName(): String {
        val themes = listOf("Cyber Blue", "Neon Magenta", "Toxic Green", "Plasma Orange", "Void Purple", "Matrix Red")
        return themes[(seed % themes.size).toInt()]
    }
}

val CurrentTheme = ThemeEngine()