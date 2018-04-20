//
//  AboutVC.swift
//  BAKESF
//
//  Created by 高宇超 on 2018/4/14.
//  Copyright © 2018 Yuchao. All rights reserved.
//

import UIKit

class AboutVC: UIViewController {

    @IBOutlet var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if iPhoneX {
            label.frame.origin.y += 18
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
