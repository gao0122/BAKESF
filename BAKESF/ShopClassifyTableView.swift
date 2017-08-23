//
//  ShopClassifyTableView.swift
//  BAKESF
//
//  Created by 高宇超 on 7/11/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

class ShopClassifyTableView: UITableView, UIGestureRecognizerDelegate {
    
    var shouldScroll = false
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.shouldScroll
    }
    
    override func reloadData() {
        if let index = self.indexPathForSelectedRow {
            super.reloadData()
            self.selectRow(at: index, animated: false, scrollPosition: .none)
        }

    }
    
}
