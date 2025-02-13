//
//  String+Localized.swift
//  ios-project-template
//
//  Created by Vic Tsai on 2025/2/13.
//

import Foundation

extension String {
    func loc(_ comment: String = "") -> String {
        return NSLocalizedString(self, comment: comment)
    }
}

