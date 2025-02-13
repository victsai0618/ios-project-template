//
//  BLEConstants.swift
//  ios-project-template
//
//  Created by Vic Tsai on 2025/2/13.
//

import CoreBluetooth

enum BLEConstants {
    case service, write, read, notify
    
    var uuid: CBUUID {
        switch self {
        case .service:
            return CBUUID(string: "")
        case .write:
            return CBUUID(string: "")
        case .read:
            return CBUUID(string: "")
        case .notify:
            return CBUUID(string: "")
        }
    }
}
