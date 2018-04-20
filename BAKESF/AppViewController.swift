//
//  AppViewController.swift
//  BAKESF
//
//  Created by 高宇超 on 2018/4/13.
//  Copyright © 2018 Yuchao. All rights reserved.
//

import UIKit

class AppViewController: UIViewController {

    @IBOutlet var textField: UITextField!
    
    let codes : [String] = [
        "B2A0K1E8S0F4",
        "4F0S8E1K0A2B",
        "BKY20180413C"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }
    
    @IBAction func btnPressed(sender: Any) {
        guard let code = textField.text else { return }
        if codes.contains(code) {
            performSegue(withIdentifier: "showMainVC", sender: sender)
        }
    }

}
