//
//  LoanApplication.swift
//  LoanCalculator
//
//  Created by Ivan Tishchenko on 17.12.2025.
//

import Foundation

// MARK: - Loan Application Model
struct LoanApplication: Codable {
    let amount: Double
    let period: Int
    let totalRepayment: Double
}

// MARK: - API Response Model
struct LoanApplicationResponse: Codable {
    let id: Int
    let amount: Double
    let period: Int
    let totalRepayment: Double
}

