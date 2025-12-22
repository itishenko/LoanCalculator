package com.loancalculator.redux

import java.util.Calendar
import java.util.Date

/**
 * Loan State - represents the current state of the loan calculator
 */
data class LoanState(
    val amount: Double = 5000.0,
    val periodDays: Int = 14,
    val interestRate: Double = 0.15,
    val isLoading: Boolean = false,
    val submissionResult: SubmissionResult? = null
) {
    val totalRepayment: Double
        get() = amount * (1 + interestRate)

    val repaymentDate: Date
        get() {
            val calendar = Calendar.getInstance()
            calendar.add(Calendar.DAY_OF_YEAR, periodDays)
            return calendar.time
        }

    val isValid: Boolean
        get() = amount in 5000.0..50000.0 && periodDays in listOf(7, 14, 21, 28)
}

/**
 * Submission Result sealed class
 */
sealed class SubmissionResult {
    data class Success(val responseId: Int) : SubmissionResult()
    data class Failure(val message: String) : SubmissionResult()
}

