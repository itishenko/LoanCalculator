//
//  LoanState.swift
//  LoanCalculator
//
//  Created by Ivan Tishchenko on 17.12.2025.
//

import Foundation

// MARK: - Loan State
struct LoanState: Equatable {
    var amount: Double = 5000
    var periodDays: Int = 14
    var interestRate: Double = 0.15
    var isLoading: Bool = false
    var submissionResult: SubmissionResult? = nil
    
    var totalRepayment: Double {
        amount * (1 + interestRate)
    }
    
    var repaymentDate: Date {
        Calendar.current.date(byAdding: .day, value: periodDays, to: Date()) ?? Date()
    }
    
    var isValid: Bool {
        amount >= 5000 && amount <= 50000 && [7, 14, 21, 28].contains(periodDays)
    }
}

// MARK: - Submission Result
enum SubmissionResult: Equatable {
    case success(responseId: Int)
    case failure(message: String)
}

