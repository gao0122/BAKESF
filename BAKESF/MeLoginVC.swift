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

class MeLoginVC: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {

    enum LoginMethod {
        case pwd, msg
    }
    
    enum LoginState {
        case normal, sending, loggingIn
    }
    
    @IBOutlet weak var backToMeBtn: UIButton!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var msgOrPwdTextField: UITextField!
    @IBOutlet weak var getMsgBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var loginByWX: UIButton!
    @IBOutlet weak var loginByWB: UIButton!
    @IBOutlet weak var loginByMsgOrPwd: UIButton!
    
    var avbaker: AVBaker!
    var userRealm: UserRealm!
    
    var navigationDelegate: NavigationControllerDelegate?
    let edgePanGestrue = UIScreenEdgePanGestureRecognizer()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        msgOrPwdTextField.delegate = self
        phoneTextField.delegate = self
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(sender:))))
        edgePanGestrue.edges = .left
        edgePanGestrue.addTarget(self, action: #selector(MeLoginVC.screenEdgePanBackToMeFromLogin(_:)))
        view.addGestureRecognizer(edgePanGestrue)
        
        users = RealmHelper.retrieveUsers()
        
        getMsgBtn.layer.cornerRadius = 2
        getMsgBtn.layer.masksToBounds = true
        
        loginBtn.layer.cornerRadius = 2
        loginBtn.layer.masksToBounds = true
        
        btnWidth = loginBtn.frame.width
        loginBtnX = loginBtn.frame.origin.x
    }

    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    deinit {
        edgePanGestrue.removeTarget(self, action: #selector(MeLoginVC.screenEdgePanBackToMeFromLogin(_:)))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            switch id {
            case "unwindToMeFromLogin":
                let meVC = segue.destination as! MeVC
                meVC.avbaker = self.avbaker
            default:
                break
            }
        }
    }
    
    // MARK: - TextField
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // TODO :- all views move to up for 10px
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
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
                    self.loginByMsgOrPwd.setTitle("使用密码登录", for: .normal)
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
                                    self.view.notify(text: "还需要\(self.totalSeconds - secs)秒后才能获取验证码哦", color: .alertOrange)
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
                let errorMsg = error!.localizedDescription
                print(errorMsg)
                if errorMsg.contains("456") {
                    self.view.notify(text: "请输入手机号码", color: .alertOrange)
                } else if errorMsg.contains("457") {
                    self.view.notify(text: "请输入有效的手机号码", color: .alertOrange)
                } else if errorMsg.contains("458") {
                    self.view.notify(text: "发送失败，输入的手机号码在发送黑名单中", color: .alertRed)
                } else if errorMsg.contains("459") {
                    self.view.notify(text: "发送失败，不支持该地区发送短信", color: .alertRed)
                } else {
                    self.view.notify(text: "发送失败", color: .alertRed)
                }
            }
            self.loginState = .normal
        })
    }
    
    @IBAction func loginBtnPressed(_ sender: Any) {
        if self.phoneTextField.text!.characters.count > 0 {
            if self.phoneNum == phoneTextField.text {
                if let code = msgOrPwdTextField.text {
                    if code.characters.count > 0 {
                        if self.loginState != .loggingIn {
                            self.loginBtn.isEnabled = false
                            self.loginState = .loggingIn
                            if TEST {
                                if loginMethod == .msg {
                                    self.loginByMsg(sender)
                                } else {
                                    
                                }
                                self.loginBtn.isEnabled = true
                                self.loginState = .normal
                            } else {
                                if loginMethod == .msg {
                                    self.commitSmsCode(code: code, sender: sender)
                                } else {
                                    self.commitPassword(pwd: code)
                                }
                            }
                        }
                    } else {
                        // please input verification code
                        self.view.notify(text: "请输入验证码", color: .alertOrange)
                    }
                }
            } else {
                // please input verified phone number
                self.view.notify(text: "请输入接受验证的手机号码", color: .alertOrange)
            }
        } else {
            // please input the right phone number
            self.view.notify(text: "请输入手机号码", color: .alertOrange)
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
                    return
                }
            }
            // TODO: Error handling
        })
    }
    
    func commitSmsCode(code: String, sender: Any) {
        SMSSDK.commitVerificationCode(code, phoneNumber: self.phoneNum, zone: "86", result: {
            error in
            if let error = error {
                let errorMsg = error.localizedDescription
                if errorMsg.contains("468") {
                    self.view.notify(text: "验证码错误", color: .alertRed)
                } else if errorMsg.contains("467") {
                    self.view.notify(text: "5分钟内校验错误超过3次，请稍后再试", color: .alertRed)
                }
                print(error.localizedDescription)
            } else {
                self.loginByMsg(sender)
            }
            self.loginBtn.isEnabled = true
            self.loginState = .normal
        })
    }
    
    func loginByMsg(_ sender: Any) {
        var isFirstLogin = false
        let baker = retrieveBaker(withPhone: self.phoneNum)!
        if let usr = RealmHelper.retrieveUser(withID: self.userID) {
            userRealm = usr
            isFirstLogin = false
        } else {
            isFirstLogin = true
        }
        self.retrieveHeadphotoAndSetUser(baker: baker, first: isFirstLogin)
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
                self.performSegue(withIdentifier: "unwindToMeFromLogin", sender: self)
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
                    self.performSegue(withIdentifier: "unwindToMeFromLogin", sender: self)
                } else {
                    self.view.notify(text: "登录失败", color: .alertRed)
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
    
    func screenEdgePanBackToMeFromLogin(_ sender: UIScreenEdgePanGestureRecognizer) {
        let translationX = sender.translation(in: view).x
        let translationBase: CGFloat = view.frame.width
        let translationAbs = translationX > 0 ? translationX : -translationX
        let percent = translationAbs > translationBase ? 1.0 : translationAbs / translationBase
        
        switch sender.state {
        case .began:
            navigationDelegate = self.navigationController?.delegate as? NavigationControllerDelegate
            navigationDelegate?.interactive = true
            self.performSegue(withIdentifier: "unwindToMeFromLogin", sender: sender)
        case .changed:
            navigationDelegate?.interactionController.update(percent)
        case .cancelled, .ended:
            // if the half of the view is dismissed or the x velocity is very large
            if percent > 0.5 || sender.velocity(in: view!).x > 1000 {
                navigationDelegate?.interactionController.finish()
            } else {
                navigationDelegate?.interactionController.cancel()
            }
            navigationDelegate?.interactive = false
        default:
            break
        }
    }
    
}
