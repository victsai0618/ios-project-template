//
//  ErrorPublisher.swift
//  ios-project-template
//
//  Created by Vic Tsai on 2025/2/13.
//

import Combine

class ErrorPublisher {
    static let shared = ErrorPublisher()
    private init() {}
    
    private var errorSubject = PassthroughSubject<Error, Never>()
    
    func sendError(error: Error) {
        errorSubject.send(error)
    }
    
    func errorPublisher() -> AnyPublisher<Error, Never> {
        return errorSubject.eraseToAnyPublisher()
    }
}

