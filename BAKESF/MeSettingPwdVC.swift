//
//  MeSettingPwdVC.swift
//  BAKESF
//
//  Created by 高宇超 on 7/29/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

class MeSettingPwdVC: UIViewController {

    @IBOutlet weak var button: UIButton!
    
    var avbaker: AVBaker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.notify(text: "验证码已发送到尾号 \(avbaker.mobilePhoneNumber!.substring(from: 7, to: 11)) 的手机", color: .alertGreen)

    }

    class func instantiateFromStoryboard() -> MeSettingPwdVC {
        return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: self)) as! MeSettingPwdVC
    }
    
    @IBAction func btnPressed(_ sender: Any) {
        
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    
}
