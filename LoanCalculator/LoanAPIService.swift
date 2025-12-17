//
//  LoanAPIService.swift
//  LoanCalculator
//
//  Created by Ivan Tishchenko on 17.12.2025.
//

import Foundation

// MARK: - API Service
class LoanAPIService {
    private let baseURL = "https://jsonplaceholder.typicode.com/posts"
    
    enum APIError: LocalizedError {
        case invalidURL
        case invalidResponse
        case networkError(Error)
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL"
            case .invalidResponse:
                return "Invalid response from server"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            }
        }
    }
    
    func submitApplication(_ application: LoanApplication) async throws -> LoanApplicationResponse {
        guard let url = URL(string: baseURL) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(application)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw APIError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode(LoanApplicationResponse.self, from: data)
            
            return apiResponse
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}

