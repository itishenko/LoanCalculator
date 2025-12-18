package com.loancalculator.ui.components

import android.annotation.SuppressLint
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.gestures.detectDragGestures
import androidx.compose.foundation.layout.*
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import kotlin.math.max
import kotlin.math.min

@SuppressLint("UnusedBoxWithConstraintsScope")
@Composable
fun CustomSlider(
    value: Float,
    onValueChange: (Float) -> Unit,
    valueRange: ClosedFloatingPointRange<Float>,
    modifier: Modifier = Modifier,
    trackColor: Color = MaterialTheme.colorScheme.primary,
    trackHeight: Dp = 20.dp,
    thumbSize: Dp = 52.dp,
    enabled: Boolean = true
) {
    var isDragging by remember { mutableStateOf(false) }
    val animatedValue by animateFloatAsState(
        targetValue = value,
        animationSpec = spring(),
        label = "slider_value"
    )
    
    val density = LocalDensity.current
    
    BoxWithConstraints(
        modifier = modifier
            .fillMaxWidth()
            .height(thumbSize + 16.dp)
    ) {
        val trackHeightPx = with(density) { trackHeight.toPx() }
        val thumbSizePx = with(density) { thumbSize.toPx() }
        val width = constraints.maxWidth.toFloat()
        
        val progress = (animatedValue - valueRange.start) / (valueRange.endInclusive - valueRange.start)
        val thumbX = progress * width
        
        // Pre-calculate Dp to Px conversions for Canvas
        val dp8Px = with(density) { 8.dp.toPx() }
        val dp12Px = with(density) { 12.dp.toPx() }
        val dp1_5Px = with(density) { 1.5.dp.toPx() }
        
        Canvas(
            modifier = Modifier
                .fillMaxSize()
                .pointerInput(enabled) {
                    if (!enabled) return@pointerInput
                    
                    detectDragGestures(
                        onDragStart = { isDragging = true },
                        onDragEnd = { isDragging = false },
                        onDrag = { change, _ ->
                            val newX = change.position.x.coerceIn(0f, width)
                            val newProgress = newX / width
                            val newValue = valueRange.start + 
                                (valueRange.endInclusive - valueRange.start) * newProgress
                            onValueChange(newValue.coerceIn(valueRange))
                        }
                    )
                }
        ) {
            val centerY = size.height / 2
            val trackTop = centerY - trackHeightPx / 2
            
            // Background track with diagonal stripes
            drawRoundRect(
                brush = Brush.verticalGradient(
                    colors = listOf(
                        Color.Gray.copy(alpha = 0.12f),
                        Color.Gray.copy(alpha = 0.18f)
                    )
                ),
                topLeft = Offset(0f, trackTop),
                size = Size(width, trackHeightPx),
                cornerRadius = CornerRadius(trackHeightPx / 2)
            )
            
            // Filled track
            val fillWidth = max(trackHeightPx, thumbX)
            drawRoundRect(
                brush = Brush.horizontalGradient(
                    colors = listOf(
                        trackColor.copy(alpha = 0.75f),
                        trackColor.copy(alpha = 0.9f),
                        trackColor,
                        trackColor.copy(alpha = 0.95f)
                    )
                ),
                topLeft = Offset(0f, trackTop),
                size = Size(fillWidth, trackHeightPx),
                cornerRadius = CornerRadius(trackHeightPx / 2)
            )
            
            // Thumb
            val thumbCenterY = centerY
            val thumbScale = if (isDragging) 1.1f else 1.0f
            val scaledThumbSize = thumbSizePx * thumbScale
            
            // Outer glow
            drawCircle(
                brush = Brush.radialGradient(
                    colors = listOf(
                        trackColor.copy(alpha = 0.4f),
                        trackColor.copy(alpha = 0.2f),
                        Color.Transparent
                    ),
                    center = Offset(thumbX, thumbCenterY),
                    radius = scaledThumbSize / 2 + dp12Px
                ),
                center = Offset(thumbX, thumbCenterY),
                radius = scaledThumbSize / 2 + dp12Px
            )
            
            // Main sphere with vertical gradient
            drawCircle(
                brush = Brush.verticalGradient(
                    colors = listOf(
                        trackColor.copy(alpha = 0.6f),
                        trackColor.copy(alpha = 0.8f),
                        trackColor,
                        trackColor.copy(alpha = 0.95f),
                        trackColor.copy(alpha = 0.85f)
                    ),
                    startY = thumbCenterY - scaledThumbSize / 2,
                    endY = thumbCenterY + scaledThumbSize / 2
                ),
                center = Offset(thumbX, thumbCenterY),
                radius = scaledThumbSize / 2
            )
            
            // Top highlight (bright spot)
            drawCircle(
                brush = Brush.radialGradient(
                    colors = listOf(
                        Color.White.copy(alpha = 0.6f),
                        Color.White.copy(alpha = 0.3f),
                        Color.Transparent
                    ),
                    center = Offset(thumbX, thumbCenterY - scaledThumbSize / 4),
                    radius = scaledThumbSize / 3
                ),
                center = Offset(thumbX, thumbCenterY),
                radius = scaledThumbSize / 2
            )
            
            // Inner ring
            drawCircle(
                color = Color.Black.copy(alpha = 0.2f),
                center = Offset(thumbX, thumbCenterY),
                radius = scaledThumbSize * 0.36f,
                style = Stroke(width = dp1_5Px)
            )
            
            // Inner depression
            drawCircle(
                brush = Brush.radialGradient(
                    colors = listOf(
                        Color.Transparent,
                        Color.Black.copy(alpha = 0.15f),
                        Color.Transparent
                    ),
                    center = Offset(thumbX, thumbCenterY),
                    radius = scaledThumbSize * 0.6f
                ),
                center = Offset(thumbX, thumbCenterY),
                radius = scaledThumbSize * 0.55f
            )
        }
    }
}

