//
//  UIView+Extensions.swift
//  BAKESF
//
//  Created by 高宇超 on 7/11/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

extension UIView {
    
    // notification animation
    func notify(text: String, color: UIColor, duration: TimeInterval = 1.98) {
        if !notifying {
            notifying = true
            let notifyHeight: CGFloat = 64
            let label = UILabel()
            label.restorationIdentifier = "notifyLabel"
            label.frame.size = CGSize(width: self.frame.width, height: notifyHeight)
            label.frame.origin = CGPoint(x: 0, y: -notifyHeight)
            label.font = UIFont.init(name: ".SFUIText-Light", size: 15)
            label.numberOfLines = 2
            label.text = "\n\(text)"
            label.textColor = color == .white ? .bkBlack : .bkWhite
            label.textAlignment = .center
            label.alpha = 0.4
            label.backgroundColor = color
            self.addSubview(label)
            self.bringSubview(toFront: label)
            UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseInOut], animations: {
                label.frame.origin.y = 0
                label.alpha = 1
            }, completion: {
                finished in
                UIView.animate(withDuration: 0.18, delay: duration, options: [.curveEaseInOut], animations: {
                    label.frame.origin.y = -notifyHeight
                    label.alpha = 0.4
                }, completion: {
                    finished in
                    label.removeFromSuperview()
                    notifying = false
                })
            })
        }
    }
    
}

