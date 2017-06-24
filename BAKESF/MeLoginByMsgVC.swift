//
//  MeLoginByMsgVC.swift
//  BAKESF
//
//  Created by 高宇超 on 5/17/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit
import Toast_Swift
import Firebase

class MeLoginByMsgVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var backToMeBtn: UIButton!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var msgTextField: UITextField!
    @IBOutlet weak var getMsgBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var getMsgTimerLabel: UILabel!
    
    var user = UserRealm()
    let getMsgText = "获取验证码"
    let totalSeconds = 41 + 4
    var seconds = 0
    var timer = Timer()
    var timerIsOn = false
    var phoneNum = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        msgTextField.delegate = self
        phoneTextField.delegate = self
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(sender:))))

        self.user = RealmHelper.retrieveUser().first!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backToMeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func loginByMsgToPwd(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        let meLoginByPwdVC = storyboard.instantiateViewController(withIdentifier: "loginByPwd") as! MeLoginByPwdVC

        let top = UIApplication.shared.keyWindow?.rootViewController
        
        top?.present(meLoginByPwdVC, animated: true, completion: nil)

    }
    
    @IBAction func getMsgPressed(_ sender: Any) {
        if let phone = phoneTextField.text {
            
            SMSSDK.getVerificationCode(by: SMSGetCodeMethodSMS, phoneNumber: phone, zone: "86", customIdentifier: nil, result: {
                error in
                
                if error == nil {
                    self.getMsgBtn.isEnabled = false
                    self.getMsgBtn.setTitleColor(UIColor.lightGray, for: UIControlState.disabled)
                    self.getMsgTimerLabel.isHidden = false
                    
                    self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer(sender: )), userInfo: nil, repeats: true)
                    
                    self.phoneNum = phone

                } else {
                    let errorMsg = error!.localizedDescription
                    print(errorMsg)
                    if errorMsg.contains("456") {
                        self.view.makeToast("请输入手机号码", duration: 1.7, position: .center)
                    } else if errorMsg.contains("457") {
                        self.view.makeToast("请输入有效的手机号码", duration: 1.7, position: .center)
                    } else if errorMsg.contains("458") {
                        self.view.makeToast("发送失败，输入的手机号码在发送黑名单中", duration: 1.7, position: .center)
                    } else if errorMsg.contains("459") {
                        self.view.makeToast("发送失败，不支持该地区发送短信", duration: 1.7, position: .center)
                    } else {
                        self.view.makeToast("发送失败", duration: 1.7, position: .center)
                    }
                }
            })
        }
    }
    
    @IBAction func loginBtnPressed(_ sender: Any) {
        
        // MARK: - test user
        //phoneNum = "13143128565"
        
        if self.phoneNum.characters.count > 0 {
            if self.phoneNum == phoneTextField.text {
                if let code = msgTextField.text {
                    if code.characters.count > 0 {
                        
                        SMSSDK.commitVerificationCode(code, phoneNumber: self.phoneNum, zone: "86", result: {
                            
                            userInfo, error in
                            
                            if error == nil {
                                print("verified successfully")
                                
                                RealmHelper.updateUserPhone(user: self.user, phone: self.phoneNum)
                                
                                let recentUser = RecentUserRealm()
                                recentUser.id = self.user.id
                                recentUser.name = self.user.name
                                recentUser.phone = self.user.phone
                                recentUser.pwd = self.user.pwd
                                RealmHelper.updateRecentUser(user: recentUser)
                                
                                self.dismiss(animated: true, completion: {
                                    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                                    
                                    let meVC = storyboard.instantiateViewController(withIdentifier: "meVC") as! MeVC
                                    
                                    meVC.userNameLabel.text = "欢迎 \(self.user.phone)"
                                    
                                })

                            } else {

                                let errorMsg = error!.localizedDescription
                                if errorMsg.contains("468") {
                                    self.view.makeToast("验证码错误", duration: 1.7, position: .center)
                                } else if errorMsg.contains("467") {
                                    self.view.makeToast("5分钟内校验错误超过3次，请稍后再试", duration: 1.7, position: .center)
                                } 
                                print(error!.localizedDescription)
                            }
                        })

                    } else {
                        // please input verification code
                        self.view.makeToast("请输入验证码", duration: 1.7, position: .center)
                    }
                }
            } else {
                // please input phone number
                self.view.makeToast("请输入正确的手机号码", duration: 1.7, position: .center)
            }
        } else {
            // please input the right phone number
            self.view.makeToast("请输入手机号码", duration: 1.7, position: .center)
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
            getMsgTimerLabel.text = "\(timeLeft)"
        } else {
            // stop timer
            timer.invalidate()
            timer = Timer()
            seconds = 0
            getMsgTimerLabel.text = "45"
            getMsgTimerLabel.isHidden = true
            getMsgBtn.isEnabled = true
            self.getMsgBtn.setTitleColor(loginBtn.currentTitleColor, for: UIControlState.normal)
        }
    }
    
}
