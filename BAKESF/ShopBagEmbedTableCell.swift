//
//  ShopBagEmbedTableCell.swift
//  BAKESF
//
//  Created by 高宇超 on 7/27/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

class ShopBagEmbedTableCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var oneMoreBtn: UIButton!
    @IBOutlet weak var minusOneBtn: UIButton!
    
    var bakeIn: BakeInBagRealm?
    var bakePre: BakePreOrderRealm?
    var bake: AVBake?

}

