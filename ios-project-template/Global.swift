//
//  Global.swift
//  ios-project-template
//
//  Created by Vic Tsai on 2025/2/13.
//

import UIKit

var nav: UINavigationController?

func infoForKey(_ key: String) -> String? {
    return (Bundle.main.infoDictionary?[key] as? String)?
            .replacingOccurrences(of: "\\", with: "")
}

func getEnv() -> String {
    var env = ""
    #if DEV
            env = "dev"
    #else
            env = "prod"
    #endif
    return env
}

