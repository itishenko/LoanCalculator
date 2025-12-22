package com.loancalculator.utils

import java.text.DecimalFormat
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Number and date formatting utilities
 */
object NumberFormatter {

    fun formatAsCurrency(value: Double): String {
        val formatter = DecimalFormat("#,###")
        return formatter.format(value)
    }

    fun formatAsPercentage(value: Double): String {
        return "${(value * 100).toInt()}%"
    }

    fun formatAsShortDate(date: Date): String {
        val formatter = SimpleDateFormat("MMM dd, yyyy", Locale.getDefault())
        return formatter.format(date)
    }
}

