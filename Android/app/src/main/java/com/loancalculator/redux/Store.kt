package com.loancalculator.redux

import android.content.SharedPreferences
import com.loancalculator.network.ApiService
import com.loancalculator.network.LoanApplication
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

/**
 * Redux Store - holds state and handles actions
 */
class Store(
    private val apiService: ApiService,
    private val preferences: SharedPreferences,
    private val scope: CoroutineScope = CoroutineScope(Dispatchers.Main)
) {
    private val _state = MutableStateFlow(LoanState())
    val state: StateFlow<LoanState> = _state.asStateFlow()

    /**
     * Dispatch an action to update state
     */
    fun dispatch(action: LoanAction) {
        when (action) {
            is LoanAction.SubmitApplication -> {
                handleSubmitApplication()
            }
            else -> {
                _state.value = loanReducer(_state.value, action, preferences)
            }
        }
    }

    /**
     * Handle async submission
     */
    private fun handleSubmitApplication() {
        val currentState = _state.value
        
        if (!currentState.isValid) {
            dispatch(LoanAction.SubmissionFailure("Invalid loan parameters"))
            return
        }

        dispatch(LoanAction.SubmissionStarted)

        scope.launch {
            try {
                val application = LoanApplication(
                    amount = currentState.amount,
                    period = currentState.periodDays,
                    totalRepayment = currentState.totalRepayment
                )
                
                val response = apiService.submitApplication(application)
                dispatch(LoanAction.SubmissionSuccess(response.id))
            } catch (e: Exception) {
                dispatch(LoanAction.SubmissionFailure(
                    e.message ?: "Network error occurred"
                ))
            }
        }
    }
}

