//
//  HomeSearchResultTableViewCell.swift
//  BAKESF
//
//  Created by 高宇超 on 9/13/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit.UITableViewCell

class HomeSearchResultTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarIV: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var starLabel: UILabel! // 评分
    @IBOutlet weak var leastFeeLabel: UILabel! // 起送费
    @IBOutlet weak var deliveryFeeLabel: UILabel! // 配送费
    @IBOutlet weak var deliveryCycleLabel: UILabel! // 配送时长
    @IBOutlet weak var distanceLabel: UILabel! // 距离
    
    var shop: AVShop!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    
        // Configure the view for the selected state
    }

}
