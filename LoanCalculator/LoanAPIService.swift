//
//  LoanAPIService.swift
//  LoanCalculator
//
//  Created by Ivan Tishchenko on 17.12.2025.
//

import Foundation

// MARK: - Generic API Error
enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
    case encodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Encoding error: \(error.localizedDescription)"
        }
    }
}

// MARK: - HTTP Method
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

// MARK: - Generic API Service
protocol APIServiceProtocol {
    var baseURL: String { get }
    var session: URLSession { get }
    var defaultHeaders: [String: String] { get }
}

extension APIServiceProtocol {
    var session: URLSession { URLSession.shared }
    var defaultHeaders: [String: String] {
        ["Content-Type": "application/json"]
    }
    
    func createURLRequest(
        endpoint: String,
        method: HTTPMethod,
        headers: [String: String]? = nil
    ) throws -> URLRequest {
        guard let url = URL(string: baseURL.appending(endpoint)) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        for (key, value) in defaultHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        return request
    }
    
    func executeRequest<TResponse: Codable>(
        _ request: URLRequest,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> TResponse {
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw APIError.invalidResponse
            }
            
            do {
                let decodedResponse = try decoder.decode(TResponse.self, from: data)
                return decodedResponse
            } catch {
                throw APIError.decodingError(error)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func request<TRequest: Codable, TResponse: Codable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        body: TRequest? = nil,
        headers: [String: String]? = nil,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> TResponse {
        var urlRequest = try createURLRequest(
            endpoint: endpoint,
            method: method,
            headers: headers
        )
        
        if let body = body {
            do {
                urlRequest.httpBody = try encoder.encode(body)
            } catch {
                throw APIError.encodingError(error)
            }
        }
        
        return try await executeRequest(urlRequest, decoder: decoder)
    }
    
    func get<TResponse: Codable>(
        endpoint: String,
        headers: [String: String]? = nil,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> TResponse {
        let urlRequest = try createURLRequest(
            endpoint: endpoint,
            method: .GET,
            headers: headers
        )
        return try await executeRequest(urlRequest, decoder: decoder)
    }
    
    func post<TRequest: Codable, TResponse: Codable>(
        endpoint: String,
        body: TRequest,
        headers: [String: String]? = nil,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> TResponse {
        return try await request(
            endpoint: endpoint,
            method: .POST,
            body: body,
            headers: headers,
            encoder: encoder,
            decoder: decoder
        )
    }
}



// MARK: - Base API Service
class BaseAPIService: APIServiceProtocol {
    let baseURL: String
    
    init(baseURL: String) {
        self.baseURL = baseURL
    }
}

// MARK: - Loan API Service
class LoanAPIService: BaseAPIService {
    init() {
        super.init(baseURL: "https://jsonplaceholder.typicode.com")
    }
    
    func submitApplication(_ application: LoanApplication) async throws -> LoanApplicationResponse {
        return try await post(
            endpoint: "/posts",
            body: application
        )
    }
}

