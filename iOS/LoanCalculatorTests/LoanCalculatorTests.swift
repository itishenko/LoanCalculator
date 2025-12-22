//
//  LoanCalculatorTests.swift
//  LoanCalculatorTests
//
//  Created by Ivan Tishchenko on 17.12.2025.
//

import XCTest
@testable import LoanCalculator

// MARK: - Loan State Tests
final class LoanStateTests: XCTestCase {
    
    func testDefaultState() {
        let state = LoanState()
        
        XCTAssertEqual(state.amount, 5000.0, accuracy: 0.01)
        XCTAssertEqual(state.periodDays, 14)
        XCTAssertEqual(state.interestRate, 0.15, accuracy: 0.01)
        XCTAssertFalse(state.isLoading)
        XCTAssertNil(state.submissionResult)
    }
    
    func testTotalRepaymentCalculation() {
        let state = LoanState(
            amount: 10000.0,
            periodDays: 14,
            interestRate: 0.15
        )
        
        let expectedRepayment = 10000.0 * 1.15
        XCTAssertEqual(state.totalRepayment, expectedRepayment, accuracy: 0.01)
    }
    
    func testRepaymentDateCalculation() {
        let state = LoanState(periodDays: 14)
        
        let calendar = Calendar.current
        let expectedDate = calendar.date(byAdding: .day, value: 14, to: Date())!
        let actualDate = state.repaymentDate
        
        let expectedDay = calendar.component(.day, from: expectedDate)
        let actualDay = calendar.component(.day, from: actualDate)
        
        XCTAssertEqual(actualDay, expectedDay)
    }
    
    func testValidationValidState() {
        let state = LoanState(
            amount: 10000.0,
            periodDays: 14
        )
        
        XCTAssertTrue(state.isValid)
    }
    
    func testValidationInvalidAmountTooLow() {
        let state = LoanState(
            amount: 4000.0,
            periodDays: 14
        )
        
        XCTAssertFalse(state.isValid)
    }
    
    func testValidationInvalidAmountTooHigh() {
        let state = LoanState(
            amount: 60000.0,
            periodDays: 14
        )
        
        XCTAssertFalse(state.isValid)
    }
    
    func testValidationInvalidPeriod() {
        let state = LoanState(
            amount: 10000.0,
            periodDays: 10 // Not in allowed periods
        )
        
        XCTAssertFalse(state.isValid)
    }
    
    func testValidationAllValidPeriods() {
        let validPeriods = [7, 14, 21, 28]
        
        for period in validPeriods {
            let state = LoanState(
                amount: 10000.0,
                periodDays: period
            )
            
            XCTAssertTrue(state.isValid, "Period \(period) should be valid")
        }
    }
    
    func testEdgeCaseMinimumValues() {
        let state = LoanState(
            amount: 5000.0,
            periodDays: 7
        )
        
        XCTAssertTrue(state.isValid)
        XCTAssertEqual(state.totalRepayment, 5750.0, accuracy: 0.01)
    }
    
    func testEdgeCaseMaximumValues() {
        let state = LoanState(
            amount: 50000.0,
            periodDays: 28
        )
        
        XCTAssertTrue(state.isValid)
        XCTAssertEqual(state.totalRepayment, 57500.0, accuracy: 0.01)
    }
}

// MARK: - Loan Reducer Tests
final class LoanReducerTests: XCTestCase {
    
    func testSetAmountAction() {
        var state = LoanState()
        state = loanReducer(state: state, action: .setAmount(15000.0))
        
        XCTAssertEqual(state.amount, 15000.0, accuracy: 0.01)
        XCTAssertNil(state.submissionResult)
    }
    
    func testSetPeriodAction() {
        var state = LoanState()
        state = loanReducer(state: state, action: .setPeriod(21))
        
        XCTAssertEqual(state.periodDays, 21)
        XCTAssertNil(state.submissionResult)
    }
    
    func testSubmissionStartedAction() {
        var state = LoanState(
            submissionResult: .success(responseId: 123)
        )
        state = loanReducer(state: state, action: .submissionStarted)
        
        XCTAssertTrue(state.isLoading)
        XCTAssertNil(state.submissionResult)
    }
    
    func testSubmissionSuccessAction() {
        var state = LoanState(isLoading: true)
        state = loanReducer(state: state, action: .submissionSuccess(responseId: 456))
        
        XCTAssertFalse(state.isLoading)
        if case .success(let id) = state.submissionResult {
            XCTAssertEqual(id, 456)
        } else {
            XCTFail("Expected success result")
        }
    }
    
    func testSubmissionFailureAction() {
        var state = LoanState(isLoading: true)
        state = loanReducer(state: state, action: .submissionFailure(message: "Network error"))
        
        XCTAssertFalse(state.isLoading)
        if case .failure(let message) = state.submissionResult {
            XCTAssertEqual(message, "Network error")
        } else {
            XCTFail("Expected failure result")
        }
    }
    
    func testDismissResultAction() {
        var state = LoanState(
            submissionResult: .success(responseId: 789)
        )
        state = loanReducer(state: state, action: .dismissResult)
        
        XCTAssertNil(state.submissionResult)
    }
    
    func testLoadSavedStateAction() {
        // Test with no saved state
        var state = LoanState()
        state = loanReducer(state: state, action: .loadSavedState)
        
        // Should return default state when no saved state exists
        XCTAssertEqual(state.amount, 5000.0, accuracy: 0.01)
        XCTAssertEqual(state.periodDays, 14)
    }
}

// MARK: - Number Formatter Tests
final class NumberFormatterTests: XCTestCase {
    
    func testFormatAsCurrency() {
        XCTAssertEqual(formatCurrency(5000.0), "5,000")
        XCTAssertEqual(formatCurrency(10000.0), "10,000")
        XCTAssertEqual(formatCurrency(50000.0), "50,000")
        XCTAssertEqual(formatCurrency(1234567.0), "1,234,567")
    }
    
    func testFormatAsPercentage() {
        XCTAssertEqual(formatPercentage(0.15), "15%")
        XCTAssertEqual(formatPercentage(0.20), "20%")
        XCTAssertEqual(formatPercentage(0.075), "7%")
        XCTAssertEqual(formatPercentage(0.5), "50%")
    }
    
    func testFormatAsShortDate() {
        let date = Date()
        let formatted = formatDate(date)
        
        XCTAssertFalse(formatted.isEmpty)
        XCTAssertTrue(formatted.count > 5)
    }
}

// MARK: - Integration Tests
final class IntegrationTests: XCTestCase {
    
    func testCompleteUserFlow() {
        var state = LoanState()
        
        // User selects amount
        state = loanReducer(state: state, action: .setAmount(15000.0))
        XCTAssertEqual(state.amount, 15000.0, accuracy: 0.01)
        
        // User selects period
        state = loanReducer(state: state, action: .setPeriod(21))
        XCTAssertEqual(state.periodDays, 21)
        
        // Verify calculations
        XCTAssertEqual(state.totalRepayment, 17250.0, accuracy: 0.01) // 15000 * 1.15
        XCTAssertTrue(state.isValid)
        
        // Simulate submission
        state = loanReducer(state: state, action: .submissionStarted)
        XCTAssertTrue(state.isLoading)
        
        // Simulate success
        state = loanReducer(state: state, action: .submissionSuccess(responseId: 999))
        XCTAssertFalse(state.isLoading)
        if case .success(let id) = state.submissionResult {
            XCTAssertEqual(id, 999)
        } else {
            XCTFail("Expected success result")
        }
        
        // Dismiss result
        state = loanReducer(state: state, action: .dismissResult)
        XCTAssertNil(state.submissionResult)
    }
    
    func testMultipleStateUpdates() {
        var state = LoanState()
        
        // Multiple amount changes
        state = loanReducer(state: state, action: .setAmount(10000.0))
        state = loanReducer(state: state, action: .setAmount(20000.0))
        state = loanReducer(state: state, action: .setAmount(30000.0))
        
        XCTAssertEqual(state.amount, 30000.0, accuracy: 0.01)
        
        // Multiple period changes
        state = loanReducer(state: state, action: .setPeriod(7))
        state = loanReducer(state: state, action: .setPeriod(14))
        state = loanReducer(state: state, action: .setPeriod(28))
        
        XCTAssertEqual(state.periodDays, 28)
    }
    
    func testSubmissionClearsResults() {
        var state = LoanState(
            submissionResult: .success(responseId: 123)
        )
        
        // Setting amount should clear result
        state = loanReducer(state: state, action: .setAmount(15000.0))
        XCTAssertNil(state.submissionResult)
        
        // Add result back
        state = loanReducer(state: state, action: .submissionSuccess(responseId: 456))
        XCTAssertNotNil(state.submissionResult)
        
        // Setting period should clear result
        state = loanReducer(state: state, action: .setPeriod(21))
        XCTAssertNil(state.submissionResult)
    }
}

// MARK: - Performance Tests
final class PerformanceTests: XCTestCase {
    
    func testStateCalculationPerformance() {
        measure {
            for _ in 0..<1000 {
                let state = LoanState(amount: 25000.0, periodDays: 14)
                _ = state.totalRepayment
                _ = state.repaymentDate
                _ = state.isValid
            }
        }
    }
    
    func testReducerPerformance() {
        measure {
            var state = LoanState()
            for i in 0..<1000 {
                state = loanReducer(state: state, action: .setAmount(Double(i * 100)))
            }
        }
    }
}
