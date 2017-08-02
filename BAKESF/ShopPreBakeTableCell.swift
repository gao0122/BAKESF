//
//  ShopPreBakeTableCell.swift
//  BAKESF
//
//  Created by 高宇超 on 7/19/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

class ShopPreBakeTableCell: UITableViewCell {
    
    @IBOutlet weak var bakeImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var monthlyLabel: UILabel!
    @IBOutlet weak var oneMoreBtn: UIButton!
    @IBOutlet weak var minusOneBtn: UIButton!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var soldOutLabel: UILabel!
    
    var bake: AVBake!
    
}
