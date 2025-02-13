//
//  Data+Hex.swift
//  ios-project-template
//
//  Created by Vic Tsai on 2025/2/13.
//

import Foundation

extension Data {
    func toHex() -> String {
        return self.map { String(format: "%02hhx", $0) }.joined()
    }
}
