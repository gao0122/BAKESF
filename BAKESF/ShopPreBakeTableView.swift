//
//  ShopPreBakeTableView.swift
//  BAKESF
//
//  Created by 高宇超 on 7/19/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

class ShopPreBakeTableView: UITableView, UIGestureRecognizerDelegate {
    
    var shouldScroll = false
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.shouldScroll
    }
    
}
