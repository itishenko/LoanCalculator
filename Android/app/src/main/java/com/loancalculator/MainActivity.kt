package com.loancalculator

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import com.loancalculator.ui.LoanCalculatorScreen
import com.loancalculator.ui.theme.LoanCalculatorTheme

/**
 * Main Activity - entry point of the app
 */
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        
        val store = (application as LoanCalculatorApp).store
        
        setContent {
            LoanCalculatorTheme {
                LoanCalculatorScreen(store = store)
            }
        }
    }
}

