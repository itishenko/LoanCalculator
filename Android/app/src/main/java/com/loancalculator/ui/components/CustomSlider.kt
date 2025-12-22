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
    trackColor1: Color = MaterialTheme.colorScheme.primary,
    trackColor2: Color = MaterialTheme.colorScheme.primary,
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
        val dp12Px = with(density) { 12.dp.toPx() }
        val dp2Px = with(density) { 2.dp.toPx() }
        
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
            
            // Filled track with bulge around thumb
            val fillWidth = max(trackHeightPx, thumbX)
            val radius = trackHeightPx / 2
            val thumbRadius = thumbSizePx / 2
            
            val trackPath = Path().apply {
                if (thumbX > thumbRadius + 50) {
                    // Left rounded cap
                    arcTo(
                        rect = androidx.compose.ui.geometry.Rect(
                            left = 0f,
                            top = trackTop,
                            right = trackHeightPx,
                            bottom = trackTop + trackHeightPx
                        ),
                        startAngleDegrees = 90f,
                        sweepAngleDegrees = 180f,
                        forceMoveTo = false
                    )
                    
                    // Top line to bulge start
                    val bulgeStartX = thumbX - thumbRadius - thumbRadius
                    lineTo(bulgeStartX, trackTop)
                    
                    // Top bulge curve (going up)
                    cubicTo(
                        x1 = thumbX - 1.25f * thumbRadius + 6.25f, 
                        y1 = trackTop,
                        x2 = thumbX - 1.25f * thumbRadius + 8.75f, 
                        y2 = trackTop,
                        x3 = thumbX - 1.25f * thumbRadius + 16.25f, 
                        y3 = trackTop - 9f
                    )
                    
                    // Vertical line on right side
                    lineTo(thumbX - 1.25f * thumbRadius + 16.25f, trackTop + trackHeightPx + 10f)
                    
                    // Bottom bulge curve (going down)
                    cubicTo(
                        x1 = thumbX - 1.25f * thumbRadius + 8.75f, 
                        y1 = trackTop + trackHeightPx,
                        x2 = thumbX - 1.25f * thumbRadius + 6.25f, 
                        y2 = trackTop + trackHeightPx,
                        x3 = thumbX - 2 * thumbRadius + 5, 
                        y3 = trackTop + trackHeightPx
                    )
                    
                    // Line to thumb position
                    lineTo(thumbX, trackTop + trackHeightPx)
                    
                    // Line back to left cap bottom
                    lineTo(radius, trackTop + trackHeightPx)
                    
                    close()
                } else {
                    // Simple rounded cap for small positions
                    addRoundRect(
                        androidx.compose.ui.geometry.RoundRect(
                            left = 0f,
                            top = trackTop,
                            right = fillWidth,
                            bottom = trackTop + trackHeightPx,
                            cornerRadius = CornerRadius(radius)
                        )
                    )
                }
            }
            
            drawPath(
                path = trackPath,
                brush = Brush.horizontalGradient(
                    colors = listOf(
                        trackColor1,
                        trackColor2
                    ),
                    startX = 0f,
                    endX = thumbX
                )
            )
            
            // Thumb - using light color
            val thumbCenterY = centerY
            val thumbScale = 1.0f
            val scaledThumbSize = thumbSizePx * thumbScale
            
            // Outer glow
            drawCircle(
                brush = Brush.radialGradient(
                    colors = listOf(
                        trackColor2.copy(alpha = 0.4f),
                        trackColor2.copy(alpha = 0.2f),
                        Color.Transparent
                    ),
                    center = Offset(thumbX, thumbCenterY),
                    radius = scaledThumbSize / 2 + dp12Px
                ),
                center = Offset(thumbX - 10, thumbCenterY),
                radius = scaledThumbSize / 2 + dp12Px
            )
            
            // Main sphere - solid color
            drawCircle(
                color = trackColor2,
                center = Offset(thumbX - 10, thumbCenterY),
                radius = scaledThumbSize / 2
            )
            
            // Inner ring with gradient
            drawCircle(
                brush = Brush.verticalGradient(
                    colors = listOf(
                        Color.Black.copy(alpha = 0.35f),
                        Color.Black.copy(alpha = 0.2f),
                        Color.Black.copy(alpha = 0.1f)
                    ),
                    startY = thumbCenterY - scaledThumbSize * 0.35f,
                    endY = thumbCenterY + scaledThumbSize * 0.35f
                ),
                center = Offset(thumbX - 10, thumbCenterY),
                radius = scaledThumbSize * 0.35f,
                style = Stroke(width = dp2Px)
            )
            
            // Inner depression (radial gradient)
            drawCircle(
                brush = Brush.radialGradient(
                    colors = listOf(
                        Color.Transparent,
                        Color.Black.copy(alpha = 0.15f),
                        Color.Transparent
                    ),
                    center = Offset(thumbX - 10, thumbCenterY),
                    radius = scaledThumbSize * 0.55f
                ),
                center = Offset(thumbX - 10, thumbCenterY),
                radius = scaledThumbSize * 0.55f
            )
        }
    }
}

