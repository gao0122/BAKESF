//
//  MeLoginByPwdVC.swift
//  BAKESF
//
//  Created by 高宇超 on 5/17/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

class MeLoginByPwdVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var backToMeBtn: UIButton!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var pwdTextField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
        
    var user: UserRealm?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        phoneTextField.delegate = self
        pwdTextField.delegate = self
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(sender:))))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backToMeAction(_ sender: Any) {
        self.dismiss(animated: true, completion:{
            
        })
    }
    
    @IBAction func loginByPwdToMsg(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        let meLoginByMsgVC = storyboard.instantiateViewController(withIdentifier: "loginByMsg") as! MeLoginByMsgVC
        
        let top = UIApplication.shared.keyWindow?.rootViewController
        
        top?.present(meLoginByMsgVC, animated: true, completion: nil)

    }
    
    func dismissKeyboard(sender: UISegmentedControl) {
        pwdTextField.resignFirstResponder()
        phoneTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
}
