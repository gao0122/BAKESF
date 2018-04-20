//
//  OrderBasicTableViewCell.swift
//  BAKESF
//
//  Created by 高宇超 on 4/10/18.
//  Copyright © 2018 Yuchao. All rights reserved.
//

import UIKit

class OrderBasicTableViewCell: UITableViewCell {

    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var stateDetailLabel: UILabel!
    @IBOutlet weak var btn0: UIButton!
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
