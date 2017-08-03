//
//  MeTweetVC.swift
//  BAKESF
//
//  Created by 高宇超 on 5/15/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

class MeTweetVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()


    }


    class func instantiateFromStoryboard() -> MeTweetVC {
        return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: self)) as! MeTweetVC
    }
    

}
