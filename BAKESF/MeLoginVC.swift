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

enum TimerState {
    case inited, rolling, done
}

let TEST = true

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

    let totalSeconds = 42 + 3
    var seconds = 0
    var timer = Timer()
    var timerIsOn = false
    var hasSent = false
    var loginState: LoginState = .normal
    var timerState: TimerState = .inited
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
            if self.loginState == .normal {
                self.loginState = .sending
                self.getMsgBtn.isEnabled = false
                self.getMsgBtn.setTitleColor(UIColor.gray, for: .disabled)
                self.getMsgBtn.setTitle("正在发送...", for: .disabled)
                if self.timerState == .done {
                    self.sendMsg(phone: phone)
                } else {
                    let query = LCQuery(className: "Baker")
                    query.whereKey("mobilePhoneNumber", .equalTo(phone))
                    query.getFirst {
                        result in
                        switch result {
                        case .success(let usr as LCBaker):
                            var canSendMsg = false
                            let sentLCDate = usr.get("msgSentDate") as? LCDate
                            if sentLCDate == nil {
                                canSendMsg = true
                            } else {
                                let secs = Date().seconds(fromDate: sentLCDate!.value)
                                if secs > self.totalSeconds {
                                    canSendMsg = true
                                } else {
                                    // notify how many seconds left
                                    self.view.notify(text: "还需要\(self.totalSeconds - secs)秒后才能获取验证码哦", color: .orange)
                                    canSendMsg = false
                                }
                            }
                            
                            if canSendMsg {
                                self.sendMsg(phone: phone)
                            } else {
                                self.resetGetMsgBtn()
                            }
                        case .failure(let error):
                            //error
                            let userLC = LCBaker()
                            let pwd = generateRandomPwd()
                            let uname = "u\(phone)"
                            let acl = LCACL()
                            acl.setAccess(LCACL.Permission.write, allowed: true)
                            acl.setAccess(LCACL.Permission.read, allowed: true)
                            userLC.ACL = acl
                            userLC.mobilePhoneNumber = LCString(phone)
                            userLC.password = LCString(pwd)
                            userLC.username = LCString(uname)
                            userLC.save {
                                result in
                                switch result {
                                case .success:
                                    self.sendMsg(phone: phone)
                                case .failure(let error):
                                    let code = error.code
                                    switch code {
                                    case 217:
                                        break
                                    default:
                                        break
                                    }
                                    self.resetGetMsgBtn()
                                }
                            }
                        default:
                            break
                        }
                    }
                }
            }
        }
    }
    
    func sendMsg(phone: String) {
        self.phoneNum = phone
        if TEST {
            self.msgTextField.becomeFirstResponder()
            self.timerState = .rolling
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer(sender: )), userInfo: nil, repeats: true)
            self.updateSentMsgDate(phone: phone)
            return
        }
        SMSSDK.getVerificationCode(by: SMSGetCodeMethodSMS, phoneNumber: phone, zone: "86", result: {
            error in
            if error == nil {
                self.msgTextField.becomeFirstResponder()
                self.timerState = .rolling
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer(sender: )), userInfo: nil, repeats: true)
                self.updateSentMsgDate(phone: phone)
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
            self.loginState = .normal
        })
    }
    
    func updateSentMsgDate(phone: String) {
        let query = LCQuery(className: "Baker")
        query.whereKey("mobilePhoneNumber", .equalTo(phone))
        query.getFirst {
            result in
            switch result  {
            case .success(let usr as LCBaker):
                usr.set("msgSentDate", value: LCDate())
                usr.save {
                    result in
                    switch result {
                    case .success:
                        break
                    case .failure(let error):
                        printit(any: error)
                    }
                }
            case .failure(let error):
                printit(any: error)
            default:
                break
            }
        }
    }
    
    @IBAction func loginBtnPressed(_ sender: Any) {
        if self.phoneTextField.text!.characters.count > 0 {
            if self.phoneNum == phoneTextField.text {
                if let code = msgTextField.text {
                    if code.characters.count > 0 {
                        if self.loginState != .loggingIn {
                            self.loginBtn.isEnabled = false
                            self.loginState = .loggingIn
                            if TEST {
                                self.login(sender)
                                self.loginBtn.isEnabled = true
                                self.loginState = .normal
                            } else {
                                SMSSDK.commitVerificationCode(code, phoneNumber: self.phoneNum, zone: "86", result: {
                                    error in
                                    if error == nil {
                                        self.login(sender)
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
                                    self.loginState = .normal
                                })
                            }
                        }
                    } else {
                        // please input verification code
                        self.view.notify(text: "请输入验证码", color: .orange)
                    }
                }
            } else {
                // please input verified phone number
                self.view.notify(text: "请输入接受验证的手机号码", color: .orange)
            }
        } else {
            // please input the right phone number
            self.view.notify(text: "请输入手机号码", color: .orange)
        }
    }
    
    func login(_ sender: Any) {
        if RealmHelper.retrieveUser(withPhone: self.phoneNum) == nil {
            addRealmUser(user: retrieveBaker(withPhone: self.phoneNum)!)
        } else {
            let _ = RealmHelper.setCurrentUser(withPhone: self.phoneNum)
        }
        self.loginState = .normal
        self.performSegue(withIdentifier: "unwindToMeFromLogin", sender: sender)
    }
    
    func addRealmUser(user: LCBaker) {
        let id = user.objectId!.value
        let userRealm = UserRealm()
        userRealm.id = id
        userRealm.phone = self.phoneNum
        userRealm.name = user.username!.value
        userRealm.current = true
        RealmHelper.addUser(user: userRealm)
    }
    
    func dismissKeyboard(sender: UISegmentedControl) {
        msgTextField.resignFirstResponder()
        phoneTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    // When user switch to another app the timer will be paused, 
    // we are not going to update it in background.
    // Update timer by real time in case user quit the app and restart it.
    // But here we only save the data when app will terminate.
    func updateTimer(sender: UISegmentedControl) {
        seconds += 1
        
        let timeLeft = totalSeconds - seconds
        if timeLeft > 0 {
            self.getMsgBtn.setTitleColor(UIColor.gray, for: .disabled)
            getMsgBtn.setTitle("已发送 (\(timeLeft))", for: .disabled)
        } else {
            resetTimer()
        }
    }
    
    func resetGetMsgBtn() {
        loginState = .normal
        getMsgBtn.setTitle("获取验证码", for: .normal)
        getMsgBtn.isEnabled = true
        getMsgBtn.setTitleColor(loginBtn.currentTitleColor, for: .normal)
    }
    
    func resetTimer() {
        timer.invalidate()
        timerState = .done
        timer = Timer()
        seconds = 0
        resetGetMsgBtn()
    }
    
    @IBAction func screenEdgePanBackToMeFromLogin(_ sender: UIScreenEdgePanGestureRecognizer) {
        self.performSegue(withIdentifier: "unwindToMeFromLogin", sender: sender)
    }
    
}
