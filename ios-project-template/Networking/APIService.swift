//
//  APIService.swift
//  ios-project-template
//
//  Created by Vic Tsai on 2025/2/13.
//

import Foundation
import Alamofire
import SwiftyJSON

class APIService {
    static let shared = APIService()
    
    private var _apiSession: Session
    
    var apiSession: Session {
        return _apiSession
    }
    
    private init() {
        // Initialize with a default interceptor
        _apiSession = Session(interceptor: APIRequestInterceptor())
    }
    
    func request(endpoint: APIEndpoint, completion: @escaping (Result<JSON, Error>) -> Void) {
        let encoding: ParameterEncoding = (endpoint.method == .post || endpoint.method == .put) ? JSONEncoding.default : URLEncoding.default
        let headers: HTTPHeaders = HTTPHeaders()
        
        apiSession.request(endpoint.path,
                           method: endpoint.method,
                           parameters: endpoint.parameters,
                           encoding: encoding,
                           headers: headers)
            .validate(statusCode: 200..<300)
            .responseData { response in
                guard let _ = response.response?.statusCode else {
                    completion(.failure(AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 0))))
                    return
                }
                
                switch response.result {
                case .success(let data):
                    let json = JSON(data)
                    completion(.success(json))
                case .failure(let error):
                    if case let .responseValidationFailed(reason) = error {
                        switch reason {
                        case .unacceptableStatusCode(let code):
                            print("Received unacceptable status code: \(code)")
                        default:
                            break
                        }
                    }
                    completion(.failure(error))
                }
            }
    }
}
