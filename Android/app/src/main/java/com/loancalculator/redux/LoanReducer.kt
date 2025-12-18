package com.loancalculator.redux

import android.content.SharedPreferences

/**
 * Loan Reducer - pure function that produces new state from action
 */
fun loanReducer(
    state: LoanState,
    action: LoanAction,
    preferences: SharedPreferences? = null
): LoanState {
    return when (action) {
        is LoanAction.SetAmount -> {
            val newState = state.copy(
                amount = action.amount,
                submissionResult = null
            )
            saveState(newState, preferences)
            newState
        }

        is LoanAction.SetPeriod -> {
            val newState = state.copy(
                periodDays = action.period,
                submissionResult = null
            )
            saveState(newState, preferences)
            newState
        }

        is LoanAction.SubmissionStarted -> {
            state.copy(
                isLoading = true,
                submissionResult = null
            )
        }

        is LoanAction.SubmissionSuccess -> {
            state.copy(
                isLoading = false,
                submissionResult = SubmissionResult.Success(action.responseId)
            )
        }

        is LoanAction.SubmissionFailure -> {
            state.copy(
                isLoading = false,
                submissionResult = SubmissionResult.Failure(action.message)
            )
        }

        is LoanAction.DismissResult -> {
            state.copy(submissionResult = null)
        }

        is LoanAction.LoadSavedState -> {
            loadState(preferences) ?: state
        }

        is LoanAction.SubmitApplication -> {
            // Handled by middleware in Store
            state
        }
    }
}

/**
 * Save state to SharedPreferences
 */
private fun saveState(state: LoanState, preferences: SharedPreferences?) {
    preferences?.edit()?.apply {
        putFloat("loan_amount", state.amount.toFloat())
        putInt("loan_period", state.periodDays)
        apply()
    }
}

/**
 * Load state from SharedPreferences
 */
private fun loadState(preferences: SharedPreferences?): LoanState? {
    preferences ?: return null
    
    val amount = preferences.getFloat("loan_amount", 0f).toDouble()
    if (amount == 0.0) return null
    
    val period = preferences.getInt("loan_period", 14)
    
    return LoanState(
        amount = amount,
        periodDays = period
    )
}

