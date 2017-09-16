//
//  MeSettingVC.swift
//  BAKESF
//
//  Created by 高宇超 on 6/26/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

class MeSettingVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var settingPwdVC: MeSettingPwdVC!
    
    var avbaker: AVBaker!
    var user: UserRealm!
    
    var settingDict: [Int: [Int: String]]!
    
    var totalSeconds = 42 + 3


    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingPwdVC = MeSettingPwdVC.instantiateFromStoryboard()
        
        if let usr = RealmHelper.retrieveCurrentUser() {
            user = usr
            settingDict = settingDictLogin
        } else {
            settingDict = settingDictLogout
        }
        
        let tableHeaderFooterView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 17))
        tableHeaderFooterView.backgroundColor = UIColor(hex: 0xF7F7F7)
        tableView.tableHeaderView = tableHeaderFooterView
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 50))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        tabBarController?.tabBar.frame.origin.y = screenHeight
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        guard let id = segue.identifier else { return }
        switch id {
        case "showSettingPwd":
            let pwdVC = segue.destination as! MeSettingPwdVC
            pwdVC.avbaker = self.avbaker
        case "unwindToMeFromSetting":
            break
        default:
            break
        }
    }

    @IBAction func unwindToMeSettingVC(segue: UIStoryboardSegue) {
        
    }
    

    func logoutBtnPressed(_ sender: Any) {
        RealmHelper.logoutCurrentUser(user: user)
        performSegue(withIdentifier: "unwindToMeFromSetting", sender: sender)
    }
    
    func canGetMsg() -> Bool {
        let sentLCDate = avbaker.msgSentDate
        var canSendMsg = false
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
        
        return canSendMsg
    }
    
    func sendMsg(phone: String) {
        SMSSDK.getVerificationCode(by: SMSGetCodeMethodSMS, phoneNumber: phone, zone: "86", result: {
            error in
            if error == nil {
                updateSentMsgDate(phone: phone)
                self.performSegue(withIdentifier: "showSettingPwd", sender: self)
            } else {
                let errorMsg = error!.localizedDescription
                printit(errorMsg)
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
    
    
    // MARK: - TableView
    //
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingDict.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let dict = settingDict[section] {
            return dict.count + 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        if let text = settingDict[section]?[row] {
            let cell = UITableViewCell.btnCell(with: text)
            cell.accessoryType = .none
            if user == nil {
                
            } else {
                if section == 0 && row == 0 {
                    cell.accessoryType = .disclosureIndicator
                    cell.detailTextLabel?.text = user.name
                }
            }
            if row + 1 == settingDict[section]?.count {
                cell.separatorInset.left = screenWidth
            }
            return cell
        } else {
            return UITableViewCell.separatorCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        switch section {
        case 0:
            switch row {
            case 0:
                break
            default:
                break
            }
        case 1:
            switch row {
            case 0:
                // change password
                if canGetMsg() {
                    sendMsg(phone: avbaker.mobilePhoneNumber!)
                }
            default:
                break
            }
        case 2:
            switch row {
            case 0:
                // logout
                logoutBtnPressed(self)
            default:
                break
            }
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        let row = indexPath.row
        if let _ = settingDict[section]?[row] {
            return 50
        } else {
            return 17
        }
    }
        

}

private let settingDictLogin: [Int: [Int: String]] = [
    0: [0: "用户名"],
    1: [0: "修改密码"],
    2: [0: "退出登录"]
]

private let settingDictLogout: [Int: [Int: String]] = [
    0: [0: "登录"]
]

