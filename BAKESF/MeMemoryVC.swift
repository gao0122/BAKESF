//
//  MeSubVC.swift
//  BAKESF
//
//  Created by 高宇超 on 5/15/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

class MeMemoryVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    class func instantiateFromStoryboard() -> MeMemoryVC {
        return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: self)) as! MeMemoryVC
    }
    

}
