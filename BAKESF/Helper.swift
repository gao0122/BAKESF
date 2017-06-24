//
//  Helper.swift
//  BAKESF
//
//  Created by 高宇超 on 6/3/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

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
