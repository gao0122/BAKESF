//
//  ShopCheckingOrderRemarksVC.swift
//  BAKESF
//
//  Created by 高宇超 on 11/25/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

class ShopCheckingOrderRemarksVC: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var okayBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }



    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    @IBAction func okayBtnPressed(_ sender: Any) {
    }
    

    // MARK: - TextView
    func textViewDidChange(_ textView: UITextView) {
        
    }
    
}
