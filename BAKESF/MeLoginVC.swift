//
//  MeLoginByMsgVC.swift
//  BAKESF
//
//  Created by 高宇超 on 5/17/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit
import RealmSwift
import AVOSCloud

let TEST = true

class MeLoginVC: UIViewController, UITextFieldDelegate {

    enum LoginMethod {
        case pwd, msg
    }
    
    enum LoginState {
        case normal, sending, loggingIn
    }
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var msgOrPwdTextField: UITextField!
    @IBOutlet weak var getMsgBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var loginByWX: UIButton!
    @IBOutlet weak var loginByWB: UIButton!
    @IBOutlet weak var loginByMsgOrPwd: UIButton!
    @IBOutlet weak var loginInputView: UIView!
    
    var avbaker: AVBaker!
    var userRealm: UserRealm!
    
    var users: Results<UserRealm>!
    let totalSeconds = 42 + 3
    var seconds = 0
    var timer = Timer()
    var hasSent = false
    var loginState: LoginState = .normal
    var timerState: TimerState = .inited
    var loginMethod: LoginMethod = .msg
    var phoneNum = ""
    var userID = ""
    var msgOrPwdAnimating = false
    var btnWidth: CGFloat = 0
    var loginBtnX: CGFloat = 0
    
    var showSegueID: String!
    var unwindSegueID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        msgOrPwdTextField.delegate = self
        phoneTextField.delegate = self
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(sender:))))

        users = RealmHelper.retrieveUsers()
        
        getMsgBtn.layer.cornerRadius = 2
        getMsgBtn.layer.masksToBounds = true
        
        loginBtn.layer.cornerRadius = 2
        loginBtn.layer.masksToBounds = true
        
        btnWidth = loginBtn.frame.width
        loginBtnX = loginBtn.frame.origin.x
        
        switch showSegueID {
        case "showLogin": // from mevc
            unwindSegueID = "unwindToMeFromLogin"
        case "showLoginFromShopChecking":
            unwindSegueID = "unwindToShopCheckingFromLogin"
        default:
            break
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        switch showSegueID {
        case "showLogin", "showLoginFromShopChecking": // from mevc
            navigationController?.setNavigationBarHidden(true, animated: animated)
        default:
            break
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        switch showSegueID {
        case "showLogin", "showLoginFromShopChecking": // from mevc
            navigationController?.setNavigationBarHidden(false, animated: animated)
        default:
            break
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            switch id {
            case "unwindToMeFromLogin":
                let meVC = segue.destination as! MeVC
                meVC.avbaker = self.avbaker
            case "unwindToShopCheckingFromLogin":
                let shopCheckingVC = segue.destination as! ShopCheckingVC
                shopCheckingVC.avbaker = self.avbaker
            default:
                break
            }
        }
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: unwindSegueID, sender: self)
    }
    
    // MARK: - TextField
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.32, animations: {
            self.loginInputView.frame.origin.y = -44
        })
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.32, animations: {
            self.loginInputView.frame.origin.y = 0
        })
    }
    
    @IBAction func loginByMsgOrPwd(_ sender: Any) {
        if !msgOrPwdAnimating {
            msgOrPwdAnimating = true
            if loginMethod == .msg {
                UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
                    self.loginByMsgOrPwd.setTitle("验证码登录", for: .normal)
                    self.loginBtn.frame.origin = self.getMsgBtn.frame.origin
                    self.loginBtn.frame.size.width = self.phoneTextField.frame.width
                    self.getMsgBtn.frame.size.width = 0
                    self.getMsgBtn.alpha = 0.2
                    self.msgOrPwdTextField.placeholder = "密码"
                }, completion: {
                    finished in
                    self.msgOrPwdAnimating = false
                    self.msgOrPwdTextField.keyboardType = UIKeyboardType.default
                    self.msgOrPwdTextField.text = ""
                    self.msgOrPwdTextField.isSecureTextEntry = true
                    self.switchLoginMethod()
                })
            } else {
                UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
                    self.loginByMsgOrPwd.setTitle("密码登录", for: .normal)
                    self.loginBtn.frame.origin.x = self.loginBtnX
                    self.loginBtn.frame.size.width = self.btnWidth
                    self.getMsgBtn.frame.size.width = self.btnWidth
                    self.getMsgBtn.alpha = 1
                    self.msgOrPwdTextField.placeholder = "短信验证码"
                }, completion: {
                    finished in
                    self.msgOrPwdAnimating = false
                    self.msgOrPwdTextField.keyboardType = UIKeyboardType.numberPad
                    self.msgOrPwdTextField.text = ""
                    self.msgOrPwdTextField.isSecureTextEntry = false
                    self.switchLoginMethod()
                })
            }
        }
    }
    
    func switchLoginMethod() {
        self.loginMethod = self.loginMethod == .pwd ? .msg : .pwd
    }
    
    @IBAction func loginByWX(_ sender: Any) {
        
    }
    
    @IBAction func loginByWB(_ sender: Any) {
        
    }
    
    @IBAction func getMsgPressed(_ sender: Any) {
        if let phone = phoneTextField.text {
            if self.loginState == .normal {
                self.loginState = .sending
                self.getMsgBtn.isUserInteractionEnabled = false
                self.getMsgBtn.titleLabel?.alpha = 0.51
                self.getMsgBtn.setTitle("正在发送...", for: .normal)
                if self.timerState == .done {
                    self.sendMsg(phone: phone)
                } else {
                    let query = AVBaker.query()
                    query.whereKey(lcKey[.phone]!, equalTo: phone)
                    query.getFirstObjectInBackground({
                        object, error in
                        if error == nil {
                            // old user
                            let usr = object as! AVBaker
                            var canSendMsg = false
                            let sentLCDate = usr.msgSentDate
                            if sentLCDate == nil {
                                canSendMsg = true
                            } else {
                                let secs = Date().seconds(fromDate: sentLCDate!)
                                if secs > self.totalSeconds {
                                    canSendMsg = true
                                } else {
                                    // notify how many seconds left
                                    self.view.notify(text: "还需要\(self.totalSeconds - secs)秒后才能获取验证码哦", color: .alertOrange, nav: self.navigationController?.navigationBar)
                                    canSendMsg = false
                                }
                            }
                            
                            if canSendMsg {
                                self.userID = usr.objectId!
                                self.sendMsg(phone: phone)
                            } else {
                                self.resetGetMsgBtn()
                            }
                        } else {
                            // new user
                            let userAV = AVBaker()
                            let pwd = generateRandomPwd()
                            let uname = "u\(phone)"
                            let acl = AVACL()
                            acl.setPublicReadAccess(true)
                            acl.setPublicWriteAccess(true)
                            userAV.acl = acl
                            userAV.mobilePhoneNumber = phone
                            userAV.password = pwd
                            userAV.username = uname
                            userAV.saveInBackground({
                                succeeded, error in
                                if succeeded {
                                    self.userID = userAV.objectId!
                                    self.sendMsg(phone: phone)
                                } else {
                                    self.resetGetMsgBtn()
                                }
                            })
                        }
                    })
                }
            }
        }
    }
    
    func sendMsg(phone: String) {
        self.phoneNum = phone
        if TEST {
            self.msgOrPwdTextField.becomeFirstResponder()
            self.timerState = .rolling
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer(sender: )), userInfo: nil, repeats: true)
            updateSentMsgDate(phone: phone)
            return
        }
        SMSSDK.getVerificationCode(by: SMSGetCodeMethodSMS, phoneNumber: phone, zone: "86", result: {
            error in
            if error == nil {
                self.msgOrPwdTextField.becomeFirstResponder()
                self.timerState = .rolling
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer(sender: )), userInfo: nil, repeats: true)
                updateSentMsgDate(phone: phone)
            } else {
                self.resetGetMsgBtn()
                let errorMsg = error!.localizedDescription
                print(errorMsg)
                if errorMsg.contains("456") {
                    self.view.notify(text: "请输入手机号码", color: .alertOrange, nav: self.navigationController?.navigationBar)
                } else if errorMsg.contains("457") {
                    self.view.notify(text: "请输入有效的手机号码", color: .alertOrange, nav: self.navigationController?.navigationBar)
                } else if errorMsg.contains("458") {
                    self.view.notify(text: "发送失败，输入的手机号码在发送黑名单中", color: .alertRed, nav: self.navigationController?.navigationBar)
                } else if errorMsg.contains("459") {
                    self.view.notify(text: "发送失败，不支持该地区发送短信", color: .alertRed, nav: self.navigationController?.navigationBar)
                } else {
                    self.view.notify(text: "发送失败", color: .alertRed, nav: self.navigationController?.navigationBar)
                }
            }
            self.loginState = .normal
        })
    }
    
    @IBAction func loginBtnPressed(_ sender: Any) {
        guard let phoneText = self.phoneTextField.text else { return }
        if phoneText.characters.count > 0 {
            if self.phoneNum == phoneText || self.loginMethod == .pwd {
                if let code = msgOrPwdTextField.text {
                    if code.characters.count > 0 {
                        if self.loginState != .loggingIn {
                            self.loginBtn.isEnabled = false
                            self.loginState = .loggingIn
                            if TEST {
                                if loginMethod == .msg {
                                    self.doLogin(sender)
                                } else {
                                    self.phoneNum = phoneText
                                    self.doLogin(sender)
                                }
                                self.loginBtn.isEnabled = true
                                self.loginState = .normal
                                return
                            }
                            if loginMethod == .msg {
                                self.commitSmsCode(code: code, sender: sender)
                            } else {
                                self.phoneNum = phoneText
                                self.commitPassword(pwd: code)
                            }
                        }
                    } else {
                        // please input verification code
                        self.view.notify(text: "请输入验证码", color: .alertOrange, nav: self.navigationController?.navigationBar)
                    }
                }
            } else {
                // please input verified phone number
                self.view.notify(text: "请输入接受验证的手机号码", color: .alertOrange, nav: self.navigationController?.navigationBar)
            }
        } else {
            // please input the right phone number
            self.view.notify(text: "请输入手机号码", color: .alertOrange, nav: self.navigationController?.navigationBar)
        }
    }
    
    func commitPassword(pwd: String) {
        let queryPhone = AVBaker.query()
        queryPhone.whereKey(lcKey[.phone]!, equalTo: self.phoneNum)
        let queryPwd = AVBaker.query()
        queryPwd.whereKey(lcKey[.pwd]!, equalTo: pwd)
        let query = AVQuery.andQuery(withSubqueries: [queryPhone, queryPwd])
        query.findObjectsInBackground({
            objects, error in
            if error == nil {
                if let baker = objects?.first as? AVBaker {
                    self.avbaker = baker
                    self.userID = baker.objectId!
                    self.doLogin(self)
                } else {
                    self.view.notify(text: "手机号或密码错误", color: .alertRed, nav: self.navigationController?.navigationBar)
                }
            } else {
                self.view.notify(text: "手机号或密码错误", color: .alertRed, nav: self.navigationController?.navigationBar)
            }
            self.loginBtn.isEnabled = true
            self.loginState = .normal
        })
    }
    
    func commitSmsCode(code: String, sender: Any) {
        SMSSDK.commitVerificationCode(code, phoneNumber: self.phoneNum, zone: "86", result: {
            error in
            if let error = error {
                let errorMsg = error.localizedDescription
                if errorMsg.contains("468") {
                    self.view.notify(text: "验证码错误", color: .alertRed, nav: self.navigationController?.navigationBar)
                } else if errorMsg.contains("467") {
                    self.view.notify(text: "5分钟内校验错误超过3次，请稍后再试", color: .alertRed, nav: self.navigationController?.navigationBar)
                }
                print(error.localizedDescription)
            } else {
                self.doLogin(sender)
            }
            self.loginBtn.isEnabled = true
            self.loginState = .normal
        })
    }
    
    func doLogin(_ sender: Any) {
        var isFirstLogin = false
        if avbaker == nil {
            avbaker = retrieveBaker(withPhone: self.phoneNum)!
        }
        if let usr = RealmHelper.retrieveUser(withID: self.userID) {
            userRealm = usr
            isFirstLogin = false
        } else {
            isFirstLogin = true
        }
        self.retrieveHeadphotoAndSetUser(baker: avbaker, first: isFirstLogin)
        self.loginState = .normal
    }
    
    func retrieveHeadphotoAndSetUser(baker: AVBaker, first isFirstLogin: Bool) {
        if let url = baker.headphoto {
            if url == "-" {
                if isFirstLogin {
                    RealmHelper.addUser(user: realmUser(byAVBaker: baker, data: nil))
                } else {
                    userRealm = RealmHelper.setCurrentUser(baker: baker, data: nil)
                }
                self.avbaker = baker
                self.performSegue(withIdentifier: unwindSegueID, sender: self)
                return
            }
            let file = AVFile(url: url)
            let width = self.view.frame.width
            let progressView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 3))
            progressView.backgroundColor = .bkRed
            self.view.addSubview(progressView)
            self.view.bringSubview(toFront: progressView)
            file.getDataInBackground({
                result, error in
                if result != nil && error == nil {
                    let data = UIImage(data: result!)?.cropAndResize(width: 100, height: 100).imageData
                    if isFirstLogin {
                        RealmHelper.addUser(user: self.realmUser(byAVBaker: baker, data: data))
                    } else {
                        self.userRealm = RealmHelper.setCurrentUser(baker: baker, data: data)
                    }
                    self.avbaker = baker
                    self.performSegue(withIdentifier: self.unwindSegueID, sender: self)
                } else {
                    self.view.notify(text: "登录失败", color: .alertRed, nav: self.navigationController?.navigationBar)
                    printit(any: error!.localizedDescription)
                }
                progressView.removeFromSuperview()
            }, progressBlock: {
                percent in
                progressView.frame.size.width = width * CGFloat(percent) / 100
            })
        }
    }
    
    func realmUser(byAVBaker baker: AVBaker, data: Data?) -> UserRealm {
        let userRealm = UserRealm()
        userRealm.id = baker.objectId!
        userRealm.phone = self.phoneNum
        userRealm.name = baker.username!
        userRealm.current = true
        userRealm.headphotoURL = baker.headphoto
        userRealm.headphoto = data
        return userRealm
    }
    
    func dismissKeyboard(sender: UISegmentedControl) {
        msgOrPwdTextField.resignFirstResponder()
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
            self.getMsgBtn.setTitle("已发送 (\(timeLeft))", for: .normal)
        } else {
            self.resetTimer()
        }
    }
    
    func resetGetMsgBtn() {
        loginState = .normal
        getMsgBtn.titleLabel?.alpha = 1
        getMsgBtn.setTitle("获取验证码", for: .normal)
        getMsgBtn.isUserInteractionEnabled = true
        getMsgBtn.setTitleColor(loginBtn.currentTitleColor, for: .normal)
    }
    
    func resetTimer() {
        timer.invalidate()
        timerState = .done
        timer = Timer()
        seconds = 0
        resetGetMsgBtn()
    }
    
}
