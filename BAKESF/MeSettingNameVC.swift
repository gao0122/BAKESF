//
//  MeSettingNameVC.swift
//  BAKESF
//
//  Created by 高宇超 on 7/29/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

class MeSettingNameVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    class func instantiateFromStoryboard() -> MeSettingNameVC {
        return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: self)) as! MeSettingNameVC
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
