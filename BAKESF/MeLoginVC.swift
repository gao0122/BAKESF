//
//  MeLoginByMsgVC.swift
//  BAKESF
//
//  Created by 高宇超 on 5/17/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit
import RealmSwift
import LeanCloud

enum LoginState {
    case normal, sending, loggingIn
}

class MeLoginVC: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var backToMeBtn: UIButton!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var msgTextField: UITextField!
    @IBOutlet weak var getMsgBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var screenEdgePan: UIScreenEdgePanGestureRecognizer!
    @IBOutlet weak var loginByWX: UIButton!
    @IBOutlet weak var loginByWB: UIButton!
    @IBOutlet weak var loginByMsgOrPwd: UIButton!
    
    var users: Results<UserRealm>!
    let getMsgText = "获取验证码"
    let totalSeconds = 42 + 3
    var seconds = 0
    var timer = Timer()
    var timerIsOn = false
    var hasSent = false
    var state: LoginState = .normal
    var phoneNum = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        msgTextField.delegate = self
        phoneTextField.delegate = self
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(sender:))))

        users = RealmHelper.retrieveUsers()
        
        getMsgBtn.layer.cornerRadius = 2
        getMsgBtn.layer.masksToBounds = true
        
        loginBtn.layer.cornerRadius = 2
        loginBtn.layer.masksToBounds = true
        
    }

    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // TODO :- all views move to up for 10px
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    @IBAction func loginByMsgOrPwd(_ sender: Any) {
        
    }
    
    @IBAction func loginByWX(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToMeFromLogin", sender: sender)
    }
    
    @IBAction func getMsgPressed(_ sender: Any) {
        if let phone = phoneTextField.text {
            
            if self.state == .normal {
                self.state = .sending
                self.getMsgBtn.setTitle("正在发送...", for: .focused)
                SMSSDK.getVerificationCode(by: SMSGetCodeMethodSMS, phoneNumber: phone, zone: "86", result: {
                    error in
                    
                    if error == nil {
                        self.getMsgBtn.isEnabled = false
                        self.getMsgBtn.setTitleColor(colors[.white], for: .disabled)
                        
                        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer(sender: )), userInfo: nil, repeats: true)
                        
                        self.phoneNum = phone
                    } else {
                        let errorMsg = error!.localizedDescription
                        print(errorMsg)
                        if errorMsg.contains("456") {
                            self.view.notify(text: "请输入手机号码", color: .orange)
                        } else if errorMsg.contains("457") {
                            self.view.notify(text: "请输入有效的手机号码", color: .orange)
                        } else if errorMsg.contains("458") {
                            self.view.notify(text: "发送失败，输入的手机号码在发送黑名单中", color: .red)
                        } else if errorMsg.contains("459") {
                            self.view.notify(text: "发送失败，不支持该地区发送短信", color: .red)
                        } else {
                            self.view.notify(text: "发送失败", color: .red)
                        }
                    }
                    self.state = .normal
                })
            }
        }
    }
    
    @IBAction func loginBtnPressed(_ sender: Any) {
        
        // MARK: - test user
        //phoneNum = "13143128565"
        
        if self.phoneNum.characters.count > 0 {
            if self.phoneNum == phoneTextField.text {
                if let code = msgTextField.text {
                    if code.characters.count > 0 {
                        if self.state == .normal {
                            self.loginBtn.isEnabled = false
                            self.state = .loggingIn
                            SMSSDK.commitVerificationCode(code, phoneNumber: self.phoneNum, zone: "86", result: {
                                error in
                                if error == nil {
                                    print("verified successfully")
                                    let userLC = LCUser()
                                    userLC.mobilePhoneNumber = LCString(self.phoneNum)
                                    userLC.password = LCString(generateRandomPwd())
                                    userLC.username = LCString("用户\(self.phoneNum)")
                                    
                                    userLC.signUp({
                                        result in
                                        if result.isSuccess {
                                            // new
                                            let id = userLC.objectId!.value
                                            let userRealm = UserRealm()
                                            userRealm.id = id
                                            userRealm.phone = self.phoneNum
                                            userRealm.name = userLC.username!.value
                                            userRealm.current = true
                                            RealmHelper.addUser(user: userRealm)
                                        } else {
                                            // old
                                            printit(any: "sigu up error \(result.error!.code)")
                                        }
                                        self.performSegue(withIdentifier: "unwindToMeFromLogin", sender: sender)
                                    })
                                                                    
                                } else {

                                    let errorMsg = error!.localizedDescription
                                    if errorMsg.contains("468") {
                                        self.view.notify(text: "验证码错误", color: .red)
                                    } else if errorMsg.contains("467") {
                                        self.view.notify(text: "5分钟内校验错误超过3次，请稍后再试", color: .red)
                                    }
                                    print(error!.localizedDescription)
                                }
                                self.loginBtn.isEnabled = true
                                self.state = .normal
                            })
                        }
                    } else {
                        // please input verification code
                        self.view.notify(text: "请输入验证码", color: .orange)
                    }
                }
            } else {
                // please input phone number
                self.view.notify(text: "请输入正确的手机号码", color: .orange)
            }
        } else {
            // please input the right phone number
            self.view.notify(text: "请输入手机号码", color: .orange)
        }
    }
    
    func dismissKeyboard(sender: UISegmentedControl) {
        msgTextField.resignFirstResponder()
        phoneTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func updateTimer(sender: UISegmentedControl) {
        seconds += 1
        
        let timeLeft = totalSeconds - seconds
        if timeLeft > 0 {
            getMsgBtn.setTitle("已发送 (\(timeLeft))", for: .normal)
        } else {
            // stop timer
            timer.invalidate()
            timer = Timer()
            seconds = 0
            getMsgBtn.setTitle("获取验证码", for: .normal)
            getMsgBtn.isEnabled = true
            self.getMsgBtn.setTitleColor(loginBtn.currentTitleColor, for: UIControlState.normal)
        }
    }

    
    @IBAction func screenEdgePanBackToMeFromLogin(_ sender: UIScreenEdgePanGestureRecognizer) {
        self.performSegue(withIdentifier: "unwindToMeFromLogin", sender: sender)
    }
    
}
