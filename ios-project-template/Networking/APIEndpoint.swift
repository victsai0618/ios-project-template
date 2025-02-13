//
//  APIEndpoint.swift
//  ios-project-template
//
//  Created by Vic Tsai on 2025/2/13.
//

import Alamofire

protocol APIEndpoint {
    var host: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
}
