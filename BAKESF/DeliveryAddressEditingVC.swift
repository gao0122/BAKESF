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
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genderBtn: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var setDeliveryAddressRightLabel: UILabel!
    @IBOutlet weak var detailAddressTextField: UITextField!
    @IBOutlet weak var addressSelectionBtn: UIButton!
    
    var avbaker: AVBaker!
    var address: AVAddress?
    var daSelectionVC: DeliveryAddressSelectionVC!
    var selectedPOI: AMapPOI!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        daSelectionVC = DeliveryAddressSelectionVC.instantiateFromStoryboard()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:))))
        
    }

    override func viewWillAppear(_ animated: Bool) {
        if let address = self.address {
            titleLabel.text = "编辑地址"
            nameTextField.text = address.name
            if let gender = address.gender {
                if gender.characters.count > 0 {
                    genderBtn.setTitle(gender, for: .normal)
                }
            }
            phoneTextField.text = address.phone
            addressSelectionBtn.setTitle(address.formatted, for: .normal)
            addressSelectionBtn.setTitleColor(.bkBlack, for: .normal)
            addressSelectionBtn.titleLabel?.font = addressSelectionBtn.titleLabel?.font.withSize(14)
            detailAddressTextField.text = address.detailed
        } else {
            titleLabel.text = "新增地址"
            nameTextField.text = ""
            genderBtn.setTitle("帅哥/靓女", for: .normal)
            phoneTextField.text = ""
            addressSelectionBtn.setTitle("选择收货地址", for: .normal)
            addressSelectionBtn.setTitleColor(UIColor(hex: 0xcbcbcf), for: .normal)
            addressSelectionBtn.titleLabel?.font = addressSelectionBtn.titleLabel?.font.withSize(17)
            detailAddressTextField.text = ""
        }
    }

    class func instantiateFromStoryboard() -> DeliveryAddressEditingVC {
        return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: self)) as! DeliveryAddressEditingVC
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        guard let id = segue.identifier else { return }
        switch id {
        case "showDeliveryAddressSelectionVCFromDAEditingVC":
            guard let vc = segue.destination as? DeliveryAddressSelectionVC else { break }
            vc.showSegueID = id
        default:
            break
        }
    }

    @IBAction func unwindToDeliveryAddressEditingVC(segue: UIStoryboardSegue) {
        
    }
    
    func dismissKeyboard(_ sender: Any) {
        nameTextField.resignFirstResponder()
        phoneTextField.resignFirstResponder()
        detailAddressTextField.resignFirstResponder()
    }

    @IBAction func genderBtnPressed(_ sender: Any) {
        if genderBtn.title(for: .normal) == "帅哥" {
            genderBtn.setTitle("靓女", for: .normal)
        } else if genderBtn.title(for: .normal) == "靓女" || genderBtn.title(for: .normal) == "帅哥/靓女" {
            genderBtn.setTitle("帅哥", for: .normal)
        }
    }
    
    @IBAction func okayBtnPressed(_ sender: Any) {
        printit(selectedPOI.formattedDescription()!)
        guard let address = address else {
            // notify: - 保存失败
            return
        }
        guard let name = nameTextField.text else {
            nameTextField.becomeFirstResponder()
            return
        }
        if name.characters.count == 0 {
            nameTextField.becomeFirstResponder()
            return
        }
        guard let phone = phoneTextField.text else {
            phoneTextField.becomeFirstResponder()
            return
        }
        if phone.characters.count == 0 {
            phoneTextField.becomeFirstResponder()
            return
        }
        guard let detailed = detailAddressTextField.text else {
            detailAddressTextField.becomeFirstResponder()
            return
        }
        if detailed.characters.count == 0 {
            detailAddressTextField.becomeFirstResponder()
            return
        }
        
        address.Baker = avbaker
        
    }

    
    // MARK: - TextField
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }


}
