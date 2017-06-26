//
//  Extensions.swift
//  BAKESF
//
//  Created by 高宇超 on 6/25/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import Foundation
import UIKit

public var notifying: Bool = false

func printit(any: Any) {
    print()
    print("------------------------------")
    print(any)
    print("------------------------------")
}


// MARK: - UIView
//
extension UIView {
    
    func notify(text: String, color: BKColor, duration: TimeInterval = 1.98) {
        if !notifying {
            notifying = true
            let label = UILabel()
            label.restorationIdentifier = "notifyLabel"
            label.frame.size = CGSize(width: self.frame.width, height: 60)
            label.frame.origin = CGPoint(x: 0, y: -60)
            label.font = UIFont.init(name: ".SFUIText-Light", size: 15)
            label.numberOfLines = 2
            label.text = "\n\(text)"
            label.textColor = color == .white ? colors[.black] : colors[.white]
            label.textAlignment = .center
            label.alpha = 0.4
            label.backgroundColor = colors[color]
            self.addSubview(label)
            UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseInOut], animations: {
                label.frame.origin.y = 0
                label.alpha = 1
            }, completion: {
                finished in
                if finished {
                    UIView.animate(withDuration: 0.18, delay: duration, options: [.curveEaseInOut], animations: {
                        label.frame.origin.y = -60
                        label.alpha = 0.4
                    }, completion: {
                        finished in
                        if finished {
                            label.removeFromSuperview()
                            notifying = false
                        }
                    })
                }
            })
        }
    }
    
}


// MARK: - UIViewController
extension UIViewController {
    
    func alertOkayOrNot(title: String = "", okTitle: String, notTitle: String, msg: String, okAct: @escaping (UIAlertAction) -> Void, notAct: @escaping (UIAlertAction) -> Void) {
        
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: okTitle, style: .default, handler: okAct)
        let cancelAction = UIAlertAction(title: notTitle, style: .cancel, handler: notAct)
        alertController.addAction(okayAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}


// MARK: - String
extension String {
    
    func substring(from: Int, to: Int) -> String {
        if to > characters.count || from >= to { return "" }
        let fromIndex = self.index(startIndex, offsetBy: from)
        let toIndex = self.index(startIndex, offsetBy: to + 1)
        return substring(with: fromIndex..<toIndex)
    }
    
}

