import Foundation

class ExecutionService {
    private let baseURL = "https://leetcode-trainer-75896127852.europe-north1.run.app"

    private let session: URLSession

    enum ExecutionError: Error {
        case offline
        case networkError(String)
        case serverError(String)
        case timeout
        case decodingError

        var userMessage: String {
            switch self {
            case .offline:
                return "You're offline. Connect to the internet to run your code."
            case .networkError:
                return "Could not connect to the server. Check your internet connection and try again."
            case .serverError:
                return "The server encountered an error. Please try again in a moment."
            case .timeout:
                return "Your code took too long to execute. Check for infinite loops or optimize your solution."
            case .decodingError:
                return "Received an unexpected response. Please try again."
            }
        }

        var systemImage: String {
            switch self {
            case .offline: return "wifi.slash"
            case .networkError: return "exclamationmark.icloud"
            case .serverError: return "server.rack"
            case .timeout: return "clock.badge.exclamationmark"
            case .decodingError: return "questionmark.diamond"
            }
        }
    }

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)
    }

    private struct ExecuteRequest: Encodable {
        let problemId: String
        let language: String
        let sourceCode: String
    }

    func execute(problemId: String, language: String, sourceCode: String) async throws -> ExecutionResult {
        guard NetworkMonitor.shared.isConnected else {
            throw ExecutionError.offline
        }

        guard let url = URL(string: "\(baseURL)/execute") else {
            throw ExecutionError.networkError("Invalid URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Secrets.apiKey, forHTTPHeaderField: "x-api-key")

        let body = ExecuteRequest(problemId: problemId, language: language, sourceCode: sourceCode)
        request.httpBody = try JSONEncoder().encode(body)

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw ExecutionError.networkError("Invalid response")
            }

            if httpResponse.statusCode >= 200 && httpResponse.statusCode < 500 {
                do {
                    return try JSONDecoder().decode(ExecutionResult.self, from: data)
                } catch {
                    throw ExecutionError.decodingError
                }
            } else {
                throw ExecutionError.serverError("Server returned status \(httpResponse.statusCode)")
            }
        } catch let error as ExecutionError {
            throw error
        } catch let error as URLError where error.code == .timedOut {
            throw ExecutionError.timeout
        } catch let error as URLError {
            throw ExecutionError.networkError(error.localizedDescription)
        } catch {
            throw ExecutionError.networkError(error.localizedDescription)
        }
    }
}
