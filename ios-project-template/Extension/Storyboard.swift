//
//  Storyboard.swift
//  ios-project-template
//
//  Created by Vic Tsai on 2025/2/13.
//

import UIKit

infix operator !?

func !? <T>(wrapped: T?, nilDefault: @autoclosure () -> (value: T, text: String)) -> T {
    assert(wrapped != nil, nilDefault().text)
    return wrapped ?? nilDefault().value
}

func sb<T>() -> T where T: UIViewController {
    let name = String(describing: T.self)
    return UIStoryboard(name: name, bundle: Bundle.main).instantiateViewController(withIdentifier: name) as? T !? (T(), "\(name) not instantiated")
}
