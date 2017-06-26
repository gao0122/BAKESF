//
//  MeSettingVC.swift
//  BAKESF
//
//  Created by 高宇超 on 6/26/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

class MeSettingVC: UIViewController {

    @IBOutlet weak var userNameBtn: UIButton!
    @IBOutlet weak var logoutBtn: UIButton!
    
    var user: UserRealm!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let usr = RealmHelper.retrieveCurrentUser() {
            userNameBtn.setTitle(usr.name, for: .normal)
        }
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    
    @IBAction func logoutBtnPressed(_ sender: Any) {
        RealmHelper.logoutCurrentUser(user: user)
        performSegue(withIdentifier: "unwindToMeFromSetting", sender: sender)
    }
    
}
