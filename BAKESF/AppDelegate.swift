//
//  AppDelegate.swift
//  BAKESF
//
//  Created by 高宇超 on 5/14/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit
import AVOSCloud
import Fabric
import Crashlytics
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WXApiDelegate {

    var window: UIWindow?

    // TO-FIX: - WeChat Pay Bug, sometimes getting feedback is failed
    //         - 新增收货地址，搜索范围为全城而不是附近 \---\ Done
    //         - ...
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        registerSubclassesForAVObjects()
        AVOSCloud.setApplicationId("rok9QXYLMgzG02tv2uErl7fU-gzGzoHsz", clientKey: "7ABa2kGT3QqlarNhVdLFvMeC")
        AVOSCloud.setAllLogsEnabled(false)
        
        Fabric.with([Crashlytics.self, Answers.self])
        
        AMapServices.shared().apiKey = "398b7e40adc487593fb0f36f00a9991e"
        
        WXApi.registerApp(wxAppID)
        
        // 社区版块 - 暂时隐藏
        self.window?.rootViewController?.tabBarController?.childViewControllers[2].removeFromParentViewController()
        self.window?.rootViewController?.view.isMultipleTouchEnabled = false
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        guard let vc = window?.rootViewController?.childViewControllerForStatusBarStyle?.childViewControllers.first as? UINavigationController else {
            return
        }
        guard let loginVC = vc.childViewControllerForStatusBarStyle?.childViewControllers.first as? MeLoginVC, loginVC.seconds > 0 else {
            return
        }
        let query = AVBaker.query()
        query.whereKey(lcKey[.phone]!, equalTo: loginVC.phoneNum)
        query.getFirstObjectInBackground { (obj: AVObject?, error: Error?) in
            if let _ = error {
                //print(error)
            } else if let usr = obj as? AVBaker, let date = usr.msgSentDate {
                loginVC.seconds = Date().seconds(fromDate: date)
            }
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        if let vc = window?.rootViewController?.childViewControllerForStatusBarStyle?.childViewControllers.first {
            if let vc = vc as? UINavigationController {
                if let _ = vc.childViewControllerForStatusBarStyle as? MeLoginVC {
                    
                }
            }
        }
    }
    
    func registerSubclassesForAVObjects() -> Void {
        AVBaker.registerSubclass()
        AVShop.registerSubclass()
        AVBake.registerSubclass()
        AVOrder.registerSubclass()
        AVBakeIn.registerSubclass()
        AVBakePre.registerSubclass()
        AVAddress.registerSubclass()
        AVRedPacket.registerSubclass()
        AVCommentShop.registerSubclass()
        AVRemarksOrder.registerSubclass()
        AVBakeAttribute.registerSubclass()
        AVBakeAttributes.registerSubclass()
        AVBakeDetail.registerSubclass()
        AVHomePageSearchHistory.registerSubclass()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if let host = url.host {
            switch host {
            case "safepay":
                AlipaySDK.defaultService().processOrder(withPaymentResult: url, standbyCallback: {
                    result in
                    printit(result)
                })
            case "pay", "oauth":
                return WXApi.handleOpen(url, delegate: self)
            default:
                break
            }
        }
        return false
    }
    
    // WXApi delegate method
    func onResp(_ resp: BaseResp!) {
        if let sendResp = resp as? SendAuthResp {
            // WX Login
            switch resp.errCode {
            case 0:
                // agreed by user
                getWXAccessToken(code: sendResp.code!)
            case -2:
                // canceled by user
                break
            case -4:
                // declined by user
                break
            default:
                break
            }
        } else if let resp = resp as? PayResp {
            // WX Pay
            switch resp.errCode {
            case 0:
                printit("DONE!!!!")
                // 邀请码 VC 下，加上 ?.childViewControllers.first ，在正式版中删除。
                guard let vc = self.window?.rootViewController?.childViewControllerForStatusBarStyle?.childViewControllers.first as? UINavigationController else { return }
                guard let scVC = vc.childViewControllers.last as? ShopCheckingVC else { return }
                scVC.initializeOrder()
                scVC.saveOrderAndBakes()
            case -1:
                printit("ERROR \(resp.errStr)")
            default:
                break
            }
        }
    }
    

    func getWXAccessToken(code: String) {
        let urlStr = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=\(wxAppID)&secret=1690b3fcb79fb94f6f0311cdc430a1e8&code=\(code)&grant_type=authorization_code"
        Alamofire.request(urlStr, method: .get).responseJSON(completionHandler: {
            response in
            if let err = response.error {
                self.window?.rootViewController?.view.notify(text: "微信授权失败，请重试。\n\(err.localizedDescription)", color: .alertOrange, nav: self.window?.rootViewController?.navigationController?.navigationBar)
                return
            }
            if let data = response.data {
                do {
                    if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                        guard let accessToken = dict["access_token"] as? String else { return }
                        guard let openID = dict["openid"] as? String else { return }
                        self.getUserInfo(by: accessToken, openID)
                    }
                } catch {
                    self.window?.rootViewController?.view.notify(text: "微信授权失败，请重试。", color: .alertOrange, nav: self.window?.rootViewController?.navigationController?.navigationBar)
                }
            }
        })
    }
    
    func getUserInfo(by accessToken: String, _ openID: String) {
        let urlStr = "https://api.weixin.qq.com/sns/userinfo?access_token=\(accessToken)&openid=\(openID)"
        Alamofire.request(urlStr, method: .get).responseJSON(completionHandler: {
            response in
            if let err = response.error {
                self.window?.rootViewController?.view.notify(text: "获取用户信息失败，请重试。\n\(err.localizedDescription)", color: .alertOrange, nav: self.window?.rootViewController?.navigationController?.navigationBar)
                return
            }
            if let data = response.data {
                do {
                    if let userInfoDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                        guard let vc = self.window?.rootViewController?.childViewControllerForStatusBarStyle?.childViewControllers.first as? UINavigationController else {
                            return
                        }
                        guard let loginVC = vc.childViewControllers.last as? MeLoginVC else {
                            return
                        }
                        loginVC.loggedinByWX(userInfo: userInfoDict)
                    }
                } catch {
                    self.window?.rootViewController?.view.notify(text: "获取用户信息失败，请重试。", color: .alertOrange, nav: self.window?.rootViewController?.navigationController?.navigationBar)
                }
            }
        })
    }

    
}

