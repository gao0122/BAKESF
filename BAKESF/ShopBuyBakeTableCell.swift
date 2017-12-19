//
//  ShopBuyBakeTableCell.swift
//  BAKESF
//
//  Created by 高宇超 on 6/8/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

class ShopBuyBakeTableCell: UITableViewCell {
    
    @IBOutlet weak var bakeImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var monthlyLabel: UILabel!
    @IBOutlet weak var oneMoreBtn: UIButton!
    @IBOutlet weak var minusOneBtn: UIButton!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var soldOutLabel: UILabel!
    @IBOutlet weak var specBtn: UIButton!
    
    var bake: AVBake!
    var bakesCount: Int = 0

}

