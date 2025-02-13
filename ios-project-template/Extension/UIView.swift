//
//  UIView.swift
//  ios-project-template
//
//  Created by Vic Tsai on 2025/2/13.
//

import UIKit

extension UITextField {
    @IBInspectable var localizedPlaceholder: String {
        get { return "" }
        set {
            self.placeholder = newValue.loc()
        }
    }

    @IBInspectable var localizedText: String {
        get { return "" }
        set {
            self.text = newValue.loc()
        }
    }
    
    @IBInspectable var showUnderLine: Bool {
        get { return false }
        set {
            if newValue {
                setBottomBorder()
            }
        }
    }
    
    func setBottomBorder() {
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.masksToBounds = true
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: self.frame.height - 1, width: self.frame.width, height: 1.0)
        bottomLine.backgroundColor = UIColor.gray.cgColor
        self.layer.addSublayer(bottomLine)
    }
}

extension UITextView {

    @IBInspectable var localizedText: String {
        get { return "" }
        set {
            self.text = newValue.loc()
        }
    }
}

extension UIBarItem {

    @IBInspectable var localizedTitle: String {
        get { return "" }
        set {
            self.title = newValue.loc()
        }
    }
}

extension UILabel {

    @IBInspectable var localizedText: String {
        get { return "" }
        set {
            self.text = newValue.loc()
        }
    }
}

extension UINavigationItem {

    @IBInspectable var localizedTitle: String {
        get { return "" }
        set {
            self.title = newValue.loc()
        }
    }
}

extension UIButton {

    @IBInspectable var localizedTitle: String {
        get { return "" }
        set {
            self.setTitle(newValue.loc(), for: .normal)
        }
    }
    
    @IBInspectable var showShadow: Bool {
        get { return false }
        set {
            if newValue {
                addShadow()
            }
        }
    }
    
    func addShadow() {
        self.layer.cornerRadius = 8
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
    }
}

extension UISearchBar {

    @IBInspectable var localizedPrompt: String {
        get { return "" }
        set {
            self.prompt = newValue.loc()
        }
    }

    @IBInspectable var localizedPlaceholder: String {
        get { return "" }
        set {
            self.placeholder = newValue.loc()
        }
    }
}

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set {
              layer.cornerRadius = newValue

              // If masksToBounds is true, subviews will be
              // clipped to the rounded corners.
              layer.masksToBounds = (newValue > 0)
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
}

