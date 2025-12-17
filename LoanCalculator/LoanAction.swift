//
//  LoanAction.swift
//  LoanCalculator
//
//  Created by Ivan Tishchenko on 17.12.2025.
//

import Foundation

// MARK: - Loan Actions
enum LoanAction {
    case setAmount(Double)
    case setPeriod(Int)
    case submitApplication
    case submissionStarted
    case submissionSuccess(responseId: Int)
    case submissionFailure(message: String)
    case dismissResult
    case loadSavedState
}

