//
//  ShopBuyBakeCollectionView.swift
//  BAKESF
//
//  Created by 高宇超 on 6/8/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

class ShopBuyBakeTableView: UITableView, UIGestureRecognizerDelegate {
    
    var shouldScroll = false
    var shouldDisableScroll = false

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.shouldScroll
    }
 
}
