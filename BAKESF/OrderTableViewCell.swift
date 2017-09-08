//
//  OrderTableViewCell.swift
//  BAKESF
//
//  Created by 高宇超 on 9/3/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

class OrderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var shopNameBtn: UIButton!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var avatarIV: UIImageView!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var bakesInfoLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    var order: AVOrder?
    
}
