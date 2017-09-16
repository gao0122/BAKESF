//
//  UITableView+Extensions.swift
//  BAKESF
//
//  Created by 高宇超 on 9/16/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

extension UITableView {
    
    func deselection(animated: Bool = true) {
        if let index = self.indexPathForSelectedRow {
            self.deselectRow(at: index, animated: animated)
        }
    }
}
