//
//  ShopCheckAddressTableViewCell.swift
//  BAKESF
//
//  Created by 高宇超 on 7/31/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

class ShopCheckAddressTableViewCell: UITableViewCell {
    
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.accessoryType = .disclosureIndicator
    }
    
}
