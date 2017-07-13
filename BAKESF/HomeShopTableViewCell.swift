//
//  homeShopTableViewCell.swift
//  BAKESF
//
//  Created by 高宇超 on 5/21/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

class HomeShopTableViewCell: UITableViewCell {
    
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var headphoto: UIImageView!
    @IBOutlet weak var commentsNumber: UIButton!
    @IBOutlet weak var whiteFiveStars: UIImageView!
    
    var picker: UIImagePickerController = UIImagePickerController()
    var rootVC: UIViewController!
    
    @IBAction func followBtnPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func commentNumberBtnPressed(_ sender: Any) {
        
    }
    

}
