package com.loancalculator

import android.app.Application
import android.content.Context
import android.content.SharedPreferences
import com.loancalculator.network.RetrofitClient
import com.loancalculator.redux.Store

/**
 * Application class - initializes global dependencies
 */
class LoanCalculatorApp : Application() {
    
    lateinit var store: Store
        private set
    
    lateinit var preferences: SharedPreferences
        private set

    override fun onCreate() {
        super.onCreate()
        
        // Initialize SharedPreferences
        preferences = getSharedPreferences(
            "loan_calculator_prefs",
            Context.MODE_PRIVATE
        )
        
        // Initialize Redux Store
        store = Store(
            apiService = RetrofitClient.apiService,
            preferences = preferences
        )
    }
}

