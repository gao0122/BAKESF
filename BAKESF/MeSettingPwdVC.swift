//
//  MeSettingPwdVC.swift
//  BAKESF
//
//  Created by 高宇超 on 7/29/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

class MeSettingPwdVC: UIViewController {
    
    enum SettingPwdState {
        case msg, pwd
    }

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var textField: UITextField!
    
    var hrView: UIView!
    var avbaker: AVBaker!
    var state: SettingPwdState = .msg
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.notify(text: "验证码已发送到尾号 \(avbaker.mobilePhoneNumber!.substring(from: 7, to: 11)) 的手机", color: .alertGreen)
        
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 4

        hrView = UIView(frame: CGRect(x: textField.frame.origin.x - 12, y: textField.frame.origin.y + 50, width: textField.frame.width + 24, height: 1))
        hrView.translatesAutoresizingMaskIntoConstraints = true
        hrView.backgroundColor = .bkBlack
        hrView.autoresizingMask = [.flexibleWidth, .flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
        view.addSubview(hrView)
    }

    class func instantiateFromStoryboard() -> MeSettingPwdVC {
        return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: self)) as! MeSettingPwdVC
    }
    
    @IBAction func btnPressed(_ sender: Any) {
        guard let txt = textField.text else { return }
        if state == .msg {
            SMSSDK.commitVerificationCode(txt, phoneNumber: avbaker.mobilePhoneNumber!, zone: "86", result: {
                error in
                if let error = error {
                    let errorMsg = error.localizedDescription
                    if errorMsg.contains("468") {
                        self.view.notify(text: "验证码错误", color: .alertRed)
                    } else if errorMsg.contains("467") {
                        self.view.notify(text: "5分钟内校验错误超过3次，请稍后再试", color: .alertRed)
                    }
                } else {
                    self.switchState()
                }
            })
        } else {
            alertOkayOrNot(okTitle: "是的", notTitle: "不是", msg: "确认新密码为\n\(txt)", okAct: {
                _ in
                self.avbaker.password = txt
                self.avbaker.saveInBackground({
                    succeeded, error in
                    if succeeded {
                        self.view.window?.rootViewController?.view.notify(text: "修改成功", color: .alertGreen)
                        self.performSegue(withIdentifier: "unwindToMeSetting", sender: self)
                    }
                })
            }, notAct: { _ in })
        }
    }
    
    func switchState() {
        if state == .msg {
            textField.text = ""
            textField.placeholder = "新密码"
            textField.keyboardType = .default
            textField.isSecureTextEntry = true
            button.setTitle("确认", for: .normal)
            state = .pwd
        } else {
            textField.text = ""
            textField.placeholder = "验证码"
            textField.keyboardType = .numberPad
            textField.isSecureTextEntry = false
            button.setTitle("下一步", for: .normal)
            state = .msg
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    
}
