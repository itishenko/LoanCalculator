package com.loancalculator.utils

import java.text.DecimalFormat
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Number and date formatting utilities
 */
object NumberFormatter {
    
    /**
     * Format number as currency with thousands separator
     */
    fun formatAsCurrency(value: Double): String {
        val formatter = DecimalFormat("#,###")
        return formatter.format(value)
    }
    
    /**
     * Format as percentage
     */
    fun formatAsPercentage(value: Double): String {
        return "${(value * 100).toInt()}%"
    }
    
    /**
     * Format date as short date string
     */
    fun formatAsShortDate(date: Date): String {
        val formatter = SimpleDateFormat("MMM dd, yyyy", Locale.getDefault())
        return formatter.format(date)
    }
}

