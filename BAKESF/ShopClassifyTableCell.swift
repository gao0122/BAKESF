//
//  ShopClassifyTableCell.swift
//  BAKESF
//
//  Created by 高宇超 on 7/11/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

class ShopClassifyTableCell: UITableViewCell {
    
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var amountLabelWidth: NSLayoutConstraint!
    @IBOutlet weak var amountLabelHeight: NSLayoutConstraint!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        let color = self.amountLabel.backgroundColor
        super.setSelected(selected, animated: animated)
        self.amountLabel.backgroundColor = color
    }
    
}

