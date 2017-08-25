//
//  DeliveryTimeViewCell.swift
//  BAKESF
//
//  Created by 高宇超 on 8/19/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

class DeliveryTimeViewCell: UITableViewCell {
    
    @IBOutlet weak var deliveryTimeLabel: UILabel!
    @IBOutlet weak var deliveryFeeLabel: UILabel!
    @IBOutlet weak var selectedIcon: UILabel!
    
    var components: DateComponents?
   
}
