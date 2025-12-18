//
//  Store.swift
//  LoanCalculator
//
//  Created by Ivan Tishchenko on 17.12.2025.
//

import Foundation
import Combine

// MARK: - Store
@MainActor
class Store: ObservableObject {
    @Published private(set) var state: LoanState
    private let apiService: LoanAPIService
    
    init(initialState: LoanState = LoanState(), apiService: LoanAPIService = LoanAPIService()) {
        self.state = initialState
        self.apiService = apiService
    }
    
    func dispatch(_ action: LoanAction) {
        // Handle async actions (middleware pattern)
        if case .submitApplication = action {
            handleSubmitApplication()
            return
        }
        
        // Synchronous actions
        state = loanReducer(state: state, action: action)
    }
    
    private func handleSubmitApplication() {
        guard state.isValid else {
            dispatch(.submissionFailure(message: "Invalid loan parameters"))
            return
        }
        
        dispatch(.submissionStarted)
        
        Task {
            do {
                let application = LoanApplication(
                    amount: state.amount,
                    period: state.periodDays,
                    totalRepayment: state.totalRepayment
                )
                let response = try await apiService.submitApplication(application)
                dispatch(.submissionSuccess(responseId: response.id))
            } catch {
                dispatch(.submissionFailure(message: error.localizedDescription))
            }
        }
    }
}

