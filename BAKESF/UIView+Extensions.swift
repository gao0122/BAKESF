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
    func notify(text: String, color: UIColor, duration: TimeInterval = 1.98, nav: UINavigationBar?) {
        if !notifying {
            notifying = true
            let notifyHeight: CGFloat = 64
            let label = UILabel()
            label.restorationIdentifier = "notifyLabel"
            label.frame.size = CGSize(width: self.frame.width, height: notifyHeight)
            label.frame.origin = CGPoint(x: 0, y: -notifyHeight)
            label.font = UIFont.init(name: ".SFUIText-Light", size: 15)
            label.numberOfLines = 2
            label.text = "\n    \(text)"
            label.textColor = color == .white ? .bkBlack : .bkWhite
            label.textAlignment = .left
            label.alpha = 0.4
            label.backgroundColor = color
            self.addSubview(label)
            self.bringSubview(toFront: label)
            UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseInOut], animations: {
                label.frame.origin.y = 0
                label.alpha = 1
                nav?.alpha = 0
            }, completion: {
                finished in
                UIView.animate(withDuration: 0.18, delay: duration, options: [.curveEaseInOut], animations: {
                    label.frame.origin.y = -notifyHeight
                    label.alpha = 0.4
                    nav?.alpha = 1
                }, completion: {
                    finished in
                    nav?.alpha = 1
                    label.removeFromSuperview()
                    notifying = false
                })
            })
        }
    }
    
    func addSubviews(_ views: [UIView]) {
        for view in views { self.addSubview(view) }
    }
    
    func makeRoundCorder(radius: CGFloat = 4) {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = radius
    }
    
    func fixiPhoneX(nav: UINavigationBar? = nil, tab: UITabBar? = nil) {
        guard iPhoneX else { return }
        if let navBar = nav {
            let originY = self.frame.origin.y
            self.frame.origin.y = navBar.frame.height + navBar.frame.origin.y
            self.frame.size.height += originY - self.frame.origin.y
        } else {
            self.frame.size.height -= (xTopMargin - self.frame.origin.y)
            self.frame.origin.y = xTopMargin
        }
        if let tabBar = tab {
            self.frame.size.height -= (self.frame.origin.y + self.frame.height - tabBar.frame.origin.y)
        } else {
            
        }
        
    }
    
    
    static func tableFooterView(height: CGFloat) -> UIView {
        let footerHeight = iPhoneX ? (height + xBottomMargin) : height
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: footerHeight))
        footerView.backgroundColor = .white
        return footerView
    }
    
}

