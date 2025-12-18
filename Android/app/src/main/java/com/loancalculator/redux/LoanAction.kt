package com.loancalculator.redux

/**
 * Loan Actions - all possible actions in the loan calculator
 */
sealed class LoanAction {
    data class SetAmount(val amount: Double) : LoanAction()
    data class SetPeriod(val period: Int) : LoanAction()
    object SubmitApplication : LoanAction()
    object SubmissionStarted : LoanAction()
    data class SubmissionSuccess(val responseId: Int) : LoanAction()
    data class SubmissionFailure(val message: String) : LoanAction()
    object DismissResult : LoanAction()
    object LoadSavedState : LoanAction()
}

