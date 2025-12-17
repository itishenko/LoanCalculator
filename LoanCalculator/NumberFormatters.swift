//
//  NumberFormatters.swift
//  LoanCalculator
//
//  Created by Ivan Tishchenko on 17.12.2025.
//

import Foundation

// MARK: - Number Formatters
extension Double {
    func formatAsCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = ","
        formatter.usesGroupingSeparator = true
        
        return formatter.string(from: NSNumber(value: self)) ?? "\(Int(self))"
    }
    
    func formatAsPercentage() -> String {
        let percentage = self * 100
        return String(format: "%.0f%%", percentage)
    }
}

extension Date {
    func formatAsShortDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
}

