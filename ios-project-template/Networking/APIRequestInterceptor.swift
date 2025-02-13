//
//  APIRequestInterceptor.swift
//  ios-project-template
//
//  Created by Vic Tsai on 2025/2/13.
//

import Foundation
import Alamofire

actor APIRequestRetryState {
    private(set) var isRetrying = false

    func startRetrying() { isRetrying = true }
    func stopRetrying() { isRetrying = false }
}

final class APIRequestInterceptor: RequestInterceptor {
    let retryLimit = 3
    let retryDelay: TimeInterval = 2
    private let retryState = APIRequestRetryState()

    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        
        if let accessToken = UserDefaults.standard.string(forKey: "accessToken"), !accessToken.isEmpty {
            urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        Task {
            let response = request.task?.response as? HTTPURLResponse
            if request.retryCount < self.retryLimit {
                if let statusCode = response?.statusCode, statusCode == 401, await retryState.isRetrying == false {
                    await retryState.startRetrying()
                    
                    let result = await refreshToken()
                    switch result {
                    case .success(let newToken):
                        print("refresh token success: \(newToken)")
                        UserDefaults.standard.set(newToken, forKey: "accessToken")

                        if let originalRequest = request.request {
                            session.request(originalRequest).response { response in
                                if let error = response.error {
                                    completion(.doNotRetryWithError(error))
                                } else {
                                    completion(.retry)
                                }
                            }
                        } else {
                            completion(.doNotRetry)
                        }
                    case .failure:
                        completion(.doNotRetry)
                    }
                    
                    await retryState.stopRetrying()
                } else {
                    completion(.retryWithDelay(self.retryDelay))
                }
            } else {
                session.cancelAllRequests()
                completion(.doNotRetry)
            }
        }
    }

    private func refreshToken() async -> Result<String, Error> {
        // TODO:
        return .failure(NSError(domain: "AuthError", code: 401, userInfo: nil))
    }
}
