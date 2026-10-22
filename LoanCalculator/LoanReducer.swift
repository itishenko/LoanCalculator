//
//  LoanReducer.swift
//  LoanCalculator
//
//  Created by Ivan Tishchenko on 17.12.2025.
//

import Foundation

// MARK: - Loan Reducer
func loanReducer(state: LoanState, action: LoanAction) -> LoanState {
    var newState = state
    
    switch action {
    case .setAmount(let amount):
        newState.amount = amount
        newState.submissionResult = nil
        saveState(newState)
        
    case .setPeriod(let period):
        newState.periodDays = period
        newState.submissionResult = nil
        saveState(newState)
        
    case .submissionStarted:
        newState.isLoading = true
        newState.submissionResult = nil
        
    case .submissionSuccess(let responseId):
        newState.isLoading = false
        newState.submissionResult = .success(responseId: responseId)
        
    case .submissionFailure(let message):
        newState.isLoading = false
        newState.submissionResult = .failure(message: message)
        
    case .dismissResult:
        newState.submissionResult = nil
        
    case .loadSavedState:
        if let savedState = loadState() {
            newState.amount = savedState.amount
            newState.periodDays = savedState.periodDays
        }
        
    case .submitApplication:
        // Handled by middleware
        break
    }
    
    return newState
}

// MARK: - UserDefaults Persistence
private func saveState(_ state: LoanState) {
    UserDefaults.standard.set(state.amount, forKey: "loan_amount")
    UserDefaults.standard.set(state.periodDays, forKey: "loan_period")
}

private func loadState() -> (amount: Double, periodDays: Int)? {
    let amount = UserDefaults.standard.double(forKey: "loan_amount")
    let period = UserDefaults.standard.integer(forKey: "loan_period")
    
    guard amount > 0 else { return nil }
    
    return (amount: amount, periodDays: period == 0 ? 14 : period)
}

