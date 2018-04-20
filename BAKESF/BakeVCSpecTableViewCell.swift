//
//  BakeVCSpecTableViewCell.swift
//  BAKESF
//
//  Created by 高宇超 on 1/2/18.
//  Copyright © 2018 Yuchao. All rights reserved.
//

import UIKit

class BakeVCSpecTableViewCell: UITableViewCell {

    @IBOutlet weak var specBtn: UIButton!
    @IBOutlet weak var plusOneBtn: UIButton!
    @IBOutlet weak var minusOneBtn: UIButton!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
