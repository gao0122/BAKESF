//
//  OrderShopHeaderTableViewCell.swift
//  BAKESF
//
//  Created by 高宇超 on 4/10/18.
//  Copyright © 2018 Yuchao. All rights reserved.
//

import UIKit

class OrderShopHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var shopAvatarIV: UIImageView!
    @IBOutlet weak var shopNameLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
