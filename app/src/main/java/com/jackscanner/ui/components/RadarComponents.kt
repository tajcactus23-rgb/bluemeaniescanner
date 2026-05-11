package com.jackscanner.ui.components

import androidx.compose.animation.core.*
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.rotate
import androidx.compose.ui.unit.dp
import com.jackscanner.ui.theme.*
import kotlin.math.cos
import kotlin.math.sin

@Composable
fun AnimatedRadar(
    modifier: Modifier = Modifier,
    isScanning: Boolean = false,
    detections: List<DetectionSignal> = emptyList()
) {
    val infiniteTransition = rememberInfiniteTransition(label = "radar")
    
    val sweepAngle by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 360f,
        animationSpec = infiniteRepeatable(
            animation = tween(3000, easing = LinearEasing),
            repeatMode = RepeatMode.Restart
        ),
        label = "sweep"
    )
    
    Box(
        modifier = modifier
            .aspectRatio(1f)
            .background(BackgroundCard)
            .padding(24.dp),
        contentAlignment = Alignment.Center
    ) {
        Canvas(
            modifier = Modifier.fillMaxSize()
        ) {
            val center = Offset(size.width / 2, size.height / 2)
            val maxRadius = minOf(size.width, size.height) / 2 - 20.dp.toPx()
            
            // Background rings
            drawRings(center, maxRadius)
            
            // Sweep line
            if (isScanning) {
                rotate(sweepAngle, center) {
                    drawSweepLine(center, maxRadius)
                }
            }
            
            // Detection dots
            detections.forEach { detection ->
                drawDetectionDot(center, maxRadius, detection)
            }
            
            // Center dot
            drawCircle(
                color = CyanPrimary,
                radius = 8.dp.toPx(),
                center = center
            )
        }
    }
}

private fun DrawScope.drawRings(center: Offset, maxRadius: Float) {
    val ringRadii = listOf(0.25f, 0.5f, 0.75f, 1f)
    ringRadii.forEach { fraction ->
        val radius = maxRadius * fraction
        drawCircle(
            color = BorderDim,
            radius = radius,
            center = center,
            style = Stroke(width = if (fraction == 1f) 2.dp.toPx() else 1.dp.toPx())
        )
    }
    
    // Cross lines
    drawLine(BorderDim, Offset(center.x, center.y - maxRadius), Offset(center.x, center.y + maxRadius), strokeWidth = 1.dp.toPx())
    drawLine(BorderDim, Offset(center.x - maxRadius, center.y), Offset(center.x + maxRadius, center.y), strokeWidth = 1.dp.toPx())
}

private fun DrawScope.drawSweepLine(center: Offset, maxRadius: Float) {
    drawLine(
        color = RadarSweep,
        start = center,
        end = Offset(center.x + maxRadius, center.y),
        strokeWidth = 3.dp.toPx()
    )
}

private fun DrawScope.drawDetectionDot(center: Offset, maxRadius: Float, detection: DetectionSignal) {
    val angle = Math.toRadians(detection.angle.toDouble())
    val distance = maxRadius * detection.distance
    val x = center.x + (distance * cos(angle)).toFloat()
    val y = center.y + (distance * sin(angle)).toFloat()
    
    drawCircle(
        color = Danger,
        radius = 12.dp.toPx(),
        center = Offset(x, y)
    )
}

data class DetectionSignal(
    val rssi: Int,
    val angle: Float = 0f,
    val distance: Float = 0.5f
)