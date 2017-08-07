//
//  DeliveryAddressEditingVC.swift
//  BAKESF
//
//  Created by 高宇超 on 8/6/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

class DeliveryAddressEditingVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var okayBtn: UIButton!
    
    
    var address: AVAddress!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }


    class func instantiateFromStoryboard() -> DeliveryAddressEditingVC {
        return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: self)) as! DeliveryAddressEditingVC
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    @IBAction func unwindToDeliveryAddressEditingVC(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func okayBtnPressed(_ sender: Any) {
        
    }

    
    // MARK: - TextField
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }


}
