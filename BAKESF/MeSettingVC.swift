//
//  MeSettingVC.swift
//  BAKESF
//
//  Created by 高宇超 on 6/26/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

class MeSettingVC: UIViewController, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var settingPwdVC: MeSettingPwdVC!
    
    var edgePanGesture: UIScreenEdgePanGestureRecognizer!
    
    var avbaker: AVBaker!
    var user: UserRealm!
    var navigationDelegate: NavigationControllerDelegate?
    let edgePanGestrue = UIScreenEdgePanGestureRecognizer()
    
    var settingDict: [Int: [String]]!
    
    var totalSeconds = 42 + 3


    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingPwdVC = MeSettingPwdVC.instantiateFromStoryboard()
        
        //edgePanGestrue.edges = .left
        //edgePanGestrue.addTarget(self, action: #selector(MeSettingVC.panGestureToMeFromSetting(_:)))
        //view.addGestureRecognizer(edgePanGestrue)
        
        if let usr = RealmHelper.retrieveCurrentUser() {
            user = usr
            settingDict = settingDictLogin
        } else {
            settingDict = settingDictLogout
        }
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
                self.view.notify(text: "还需要\(self.totalSeconds - secs)秒后才能获取验证码哦", color: .alertOrange)
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
        })
    }
    

    func panGestureToMeFromSetting(_ sender: UIScreenEdgePanGestureRecognizer) {
        let translationX = sender.translation(in: view).x
        let translationBase: CGFloat = view.frame.width
        let translationAbs = translationX > 0 ? translationX : -translationX
        let percent = translationAbs > translationBase ? 1.0 : translationAbs / translationBase
        
        switch sender.state {
        case .began:
            navigationDelegate = self.navigationController?.delegate as? NavigationControllerDelegate
            navigationDelegate?.interactive = true
            self.performSegue(withIdentifier: "unwindToMeFromSetting", sender: sender)
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
    
    
    // MARK: - TableView
    //
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingDict.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return settingDict[section]!.count
        case 1:
            return settingDict[section]!.count
        case 2:
            return settingDict[section]!.count
        case 3:
            return settingDict[section]!.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "meSettingTableCell") as! MeSettingTableCell
        let sec = indexPath.section
        let row = indexPath.row
        cell.label.text = settingDict[sec]![row]
        cell.rightLabel.alpha = 0
        if user == nil {
            
        } else {
            if sec == 0 && row == 0 {
                cell.rightLabel.alpha = 1
                cell.rightLabel.text = "\(user.name)"
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sec = indexPath.section
        let row = indexPath.row
        switch sec {
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
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == settingDict.count - 1 ? 15 : 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
    
    func tableViewDeselection() {
        if let index = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: index, animated: true)
        }
    }
    

}

private let settingDictLogin: [Int: [String]] = [
    0: ["用户名"],
    1: ["修改密码"],
    2: ["退出登录"]
]

private let settingDictLogout: [Int: [String]] = [
    0: ["登录"]
]

/*
 <key>NSAllowsArbitraryLoadsInWebContent</key>
 <true/>
 <key>NSExceptionDomains</key>
 <dict>
 <key>clouddn.com</key>
 <dict>
 <key>NSIncludesSubdomains</key>
 <true/>
 <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
 <true/>
 </dict>
 </dict>
 */
