//
//  Encodable.swift
//  ios-project-template
//
//  Created by Vic Tsai on 2025/2/13.
//

import Foundation
import Alamofire
import SwiftyJSON

extension Encodable {
    func toData() -> Data {
        return try! JSONEncoder().encode(self)
    }

    func toString() -> String {
        if let data = try? JSONEncoder().encode(self) {
            if let json = String(data: data, encoding: .utf8) {
                return json
            }
        }
        return ""
    }
    
    func toJSON() -> JSON {
        guard let data = try? JSONEncoder().encode(self) else {
            return JSON.null
        }
        if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
            return JSON(jsonObject)
        } else {
            return JSON.null
        }
    }
    
    func ToParameters() -> [String: Any]? {
        do {
            let jsonData = try JSONEncoder().encode(self)
            if let parameters = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                return parameters
            }
        } catch {
            print("Failed to convert model to parameters: \(error)")
        }
        return nil
    }
}
