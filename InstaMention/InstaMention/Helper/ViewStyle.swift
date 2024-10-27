//
//  ViewStyle.swift
//  InstaMention

import UIKit

protocol ViewStyle { }
extension UIView: ViewStyle { }

extension ViewStyle where Self: UIView {
    
    @discardableResult func setRound() -> Self {
        self.layer.cornerRadius = self.frame.size.height / 2.0
        self.clipsToBounds = true
        return self
    }
    
    @discardableResult func shadow(color: UIColor = UIColor.black, shadowOffset : CGSize = CGSize(width: 1.0, height: 1.0) , shadowOpacity : Float = 0.7) -> Self {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowOffset = shadowOffset
        self.layer.masksToBounds = false
        return self
    }
}

