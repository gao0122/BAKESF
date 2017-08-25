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
    @IBOutlet weak var genderBtn: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var setDeliveryAddressRightLabel: UILabel!
    @IBOutlet weak var detailAddressTextField: UITextField!
    @IBOutlet weak var addressSelectionBtn: UIButton!
    
    var avbaker: AVBaker!
    var address: AVAddress?
    var daSelectionVC: DeliveryAddressSelectionVC!
    var selectedPOI: AMapPOI?
    var recentlyAddress: AVAddress?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        daSelectionVC = DeliveryAddressSelectionVC.instantiateFromStoryboard()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:))))

    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        if let selectedPOI = selectedPOI {
            if let _ = self.address {
                self.title = "编辑地址"
            } else {
                self.title = "新增地址"
            }
            addressSelectionBtn.setTitleColor(.bkBlack, for: .normal)
            addressSelectionBtn.setTitle(selectedPOI.address + selectedPOI.name, for: .normal)
            detailAddressTextField.becomeFirstResponder()
        } else {
            if let address = self.address {
                self.title = "编辑地址"
                nameTextField.text = address.name
                if let gender = address.gender {
                    if gender.characters.count > 0 {
                        genderBtn.setTitle(gender, for: .normal)
                        if gender == "帅哥" || gender == "靓女" {
                            genderBtn.setTitleColor(.bkBlack, for: .normal)
                        }
                    }
                }
                phoneTextField.text = address.phone
                addressSelectionBtn.setTitle(address.formatted, for: .normal)
                addressSelectionBtn.setTitleColor(.bkBlack, for: .normal)
                addressSelectionBtn.titleLabel?.adjustsFontSizeToFitWidth = true
                addressSelectionBtn.titleLabel?.minimumScaleFactor = 0.4
                detailAddressTextField.text = address.detailed
            } else {
                self.title = "新增地址"
                nameTextField.text = ""
                genderBtn.setTitle("帅哥/靓女", for: .normal)
                phoneTextField.text = ""
                addressSelectionBtn.setTitle("选择收货地址", for: .normal)
                addressSelectionBtn.setTitleColor(UIColor(hex: 0xcbcbcf), for: .normal)
                addressSelectionBtn.titleLabel?.font = addressSelectionBtn.titleLabel?.font.withSize(17)
                detailAddressTextField.text = ""
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        selectedPOI = nil
    }

    class func instantiateFromStoryboard() -> DeliveryAddressEditingVC {
        return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: self)) as! DeliveryAddressEditingVC
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
            genderBtn.setTitleColor(.bkBlack, for: .normal)
        } else if genderBtn.title(for: .normal) == "靓女" {
            genderBtn.setTitle("不告诉你", for: .normal)
            genderBtn.setTitleColor(.textGray, for: .normal)
        } else if genderBtn.title(for: .normal) == "帅哥/靓女" || genderBtn.title(for: .normal) == "不告诉你" {
            genderBtn.setTitle("帅哥", for: .normal)
            genderBtn.setTitleColor(.bkBlack, for: .normal)
        }
    }
    
    @IBAction func okayBtnPressed(_ sender: Any) {
        guard let name = nameTextField.text else {
            view.notify(text: "糟糕，配送员还不知道怎么称呼您。", color: .bkRed, nav: navigationController?.navigationBar)
            nameTextField.becomeFirstResponder()
            return
        }
        if name.removeSpaces().characters.count == 0 {
            view.notify(text: "糟糕，配送员还不知道怎么称呼您。", color: .bkRed, nav: navigationController?.navigationBar)
            nameTextField.becomeFirstResponder()
            return
        }
        guard let phone = phoneTextField.text else {
            view.notify(text: "这样的话配送员联系不到您哦。", color: .bkRed, nav: navigationController?.navigationBar)
            phoneTextField.becomeFirstResponder()
            return
        }
        if phone.removeSpaces().characters.count != 11 {
            view.notify(text: "这样的话配送员联系不到您哦。", color: .bkRed, nav: navigationController?.navigationBar)
            phoneTextField.becomeFirstResponder()
            return
        }
        
        var address: AVAddress! = self.address
        if address == nil {
            address = AVAddress()
        }
        address.name = name
        address.phone = phone
        var gender = genderBtn.title(for: .normal)
        if gender == "帅哥/靓女" {
            gender = "不告诉你"
        }
        address.gender = gender
        address.detailed = detailAddressTextField.text
        if let _ = selectedPOI {
            if let locationRealm = RealmHelper.retrieveLocation(by: 1) {
                saveAVAddress(for: address, from: locationRealm)
                address.recentlyUsed = false
                address.baker = avbaker
                self.address = address
                self.address?.saveInBackground({
                    succeeded, error in
                    if succeeded {
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        self.view.notify(text: "网络似乎出现了问题呢。", color: .bkRed, nav: self.navigationController?.navigationBar)
                    }
                })
            } else {
                self.view.notify(text: "请重新选择收货地址。", color: .bkRed, nav: self.navigationController?.navigationBar)
                return
            }
        } else if self.address != nil {
            self.address = address
            self.address?.saveInBackground({
                succeeded, error in
                if succeeded {
                    self.navigationController?.popViewController(animated: true)
                }
            })
        } else {
            self.view.notify(text: "最后一步，填写收货地址~", color: .bkRed, nav: self.navigationController?.navigationBar)
            return
        }

        
    }

    
    // MARK: - TextField
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case 0:
            address?.name = nameTextField.text
        case 1:
            address?.phone = phoneTextField.text
        case 2:
            address?.detailed = detailAddressTextField.text
        default:
            break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 0:
            phoneTextField.becomeFirstResponder()
        case 1:
            detailAddressTextField.becomeFirstResponder()
        case 2:
            textField.resignFirstResponder()
        default:
            break
        }
        return true
    }


}
