//
//  MeConnNewPhoneVC.swift
//  BAKESF
//
//  Created by 高宇超 on 3/13/18.
//  Copyright © 2018 Yuchao. All rights reserved.
//

import UIKit
import AVOSCloud

class MeConnNewPhoneVC: UIViewController {

    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var msgCodeTextField: UITextField!
    @IBOutlet weak var getMsgBtn: UIButton!
    @IBOutlet weak var confirmBtn: UIButton!
    
    var phoneNum = ""
    var phoneZone = "86"
    var timer = Timer()
    var totalSeconds = 45
    var seconds = 0
    var hasSent = false
    var timerState: TimerState = .inited
    
    var avbaker: AVBaker?
    var meVC: MeVC!
    var meLoginVC: MeLoginVC!
    var userInfo: [String: Any]!

    override func viewDidLoad() {
        super.viewDidLoad()

        getMsgBtn.setBorder(with: .bkRed)
        
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    // MARK: - TextField
    @IBAction func textDidChange(_ sender: UITextField) {
        guard let text = sender.text else { return }
        switch sender.tag {
        case 0:
            checkPhoneTextFieldIsValid(with: text)
        case 1:
            if text.count == 4 {
                confirmBtn.isEnabled = true
            } else {
                confirmBtn.isEnabled = false
            }
        default:
            break
        }
    }
    
    func checkPhoneTextFieldIsValid(with text: String?) {
        guard let text = text else {
            self.confirmBtn.isEnabled = false
            return
        }
        if text.count == 11 &&
            (   text.starts(with: "13") ||
                text.starts(with: "17") ||
                text.starts(with: "15") ||
                text.starts(with: "14") ||
                text.starts(with: "18") ) {
            self.phoneNum = text
            self.confirmBtn.isEnabled = true
        } else {
            self.confirmBtn.isEnabled = false
        }
    }
    

    @IBAction func getMsgCodeBnPressed(_ sender: Any) {
        self.getMsgBtn.isEnabled = false
        let color = (self.getMsgBtn.titleColor(for: .normal) ?? .bkRed).withAlphaComponent(0.42)
        self.getMsgBtn.setTitleColor(color, for: .normal)
        self.getMsgBtn.setTitle("正在获取...", for: .normal)
        let query = AVBaker.query()
        query.whereKey(lcKey[.phone]!, equalTo: phoneNum)
        query.findObjectsInBackground({
            objects, error in
            if let error = error {
                printit(error.localizedDescription)
                self.getMsgBtn.isEnabled = true
                self.getMsgBtn.setTitle("获取验证码", for: .normal)
            } else if let bakers = objects as? [AVBaker] {
                if bakers.count == 1 && bakers[0].wxOpenID != nil && bakers[0].wxOpenID! != "" {
                    // this phone number has been connected with WX
                    self.view.notify(text: "该号码已绑定微信", color: .alertOrange, nav: self.navigationController?.navigationBar)
                    self.getMsgBtn.isEnabled = true
                    self.getMsgBtn.setTitle("获取验证码", for: .normal)
                } else {
                    // not connected with WX
                    self.sendMsgCode()
                }
            }
        })
    }
    
    func sendMsgCode() {
        SMSSDK.getVerificationCode(by: SMSGetCodeMethodSMS, phoneNumber: phoneNum, zone: phoneZone, result: {
            error in
            if error == nil {
                self.msgCodeTextField.becomeFirstResponder()
                self.timerState = .rolling
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer(sender: )), userInfo: nil, repeats: true)
                updateSentMsgDate(phone: self.phoneNum)
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
        })
    }
    
    @IBAction func confirmBtnPressed(_ sender: Any) {
        guard let openid = userInfo["openid"] as? String else {
            self.view.notify(text: "微信用户信息获取失败", color: .alertOrange, nav: self.navigationController?.navigationBar)
            return
        }
        guard let code = msgCodeTextField.text else { return }
        guard code.count > 0 else { return }
        SMSSDK.commitVerificationCode(code, phoneNumber: phoneNum, zone: phoneZone, result: {
            error in
            if let error = error {
                self.view.notify(text: error.localizedDescription, color: .alertOrange, nav: self.navigationController?.navigationBar)
                printit(error.localizedDescription)
            } else {
                self.avbaker = retrieveBaker(withPhone: self.phoneNum)
                if let avbaker = self.avbaker {
                    avbaker.wxOpenID = openid
                    avbaker.saveInBackground()
                    self.meLoginVC.avbaker = avbaker
                    self.meLoginVC.setCurrentUser()
                    self.backToMeVC(avbaker: avbaker)
                } else {
                    self.newAVBaker(openid: openid)
                }
            }
        })
    }
    
    func newAVBaker(openid: String) {
        let user = AVBaker()
        let pwd = generateRandomPwd()
        var uname = userInfo["nickname"] as? String ?? "u\(phoneNum)"
        if uname == "" {
            uname = "u\(phoneNum)"
        }
        let headimgURL = userInfo["headimgurl"] as? String ?? ""
        let acl = AVACL()
        acl.setPublicReadAccess(true)
        acl.setPublicWriteAccess(true)
        user.acl = acl
        user.mobilePhoneNumber = phoneNum
        user.password = pwd
        user.username = uname
        user.wxOpenID = openid
        user.headphoto = headimgURL
        user.signedup = true
        user.saveInBackground({
            succeeded, error in
            if succeeded {
                self.avbaker = user
                self.meLoginVC.avbaker = user
                self.meLoginVC.setCurrentUser()
                self.backToMeVC(avbaker: user)
            } else {
                self.view.notify(text: "注册失败 \(error?.localizedDescription ?? "")", color: .alertOrange, nav: self.navigationController?.navigationBar)
                self.resetGetMsgBtn()
            }
        })
    }
    
    func backToMeVC(avbaker: AVBaker) {
        if self.navigationController?.view.layer.animation(forKey: "backToMeFromConnNewPhone") == nil {
            let transition = CATransition()
            transition.duration = 0.32
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            transition.type = kCATransitionReveal
            transition.subtype = kCATransitionFromBottom
            
            self.navigationController?.view.layer.add(transition, forKey: "backToMeFromConnNewPhone")
        }
        self.meVC.avbaker = avbaker
        self.meVC.checkCurrentUser()
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    func resetGetMsgBtn() {
        self.getMsgBtn.setTitle("获取验证码", for: .normal)
        let color = (self.getMsgBtn.titleColor(for: .normal) ?? .bkRed).withAlphaComponent(0.98)
        self.getMsgBtn.setTitleColor(color, for: .normal)
        self.getMsgBtn.isEnabled = true
    }
    
    func updateTimer(sender: UISegmentedControl) {
        seconds += 1
        
        let timeLeft = totalSeconds - seconds
        if timeLeft > 0 {
            self.getMsgBtn.setTitle("已发送(\(timeLeft)s)", for: .normal)
        } else {
            self.resetTimer()
        }
    }
    
    func resetTimer() {
        timer.invalidate()
        timerState = .done
        timer = Timer()
        seconds = 0
        resetGetMsgBtn()
    }

}
