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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        registerSubclassesForAVObjects()
        AVOSCloud.setApplicationId("rok9QXYLMgzG02tv2uErl7fU-gzGzoHsz", clientKey: "7ABa2kGT3QqlarNhVdLFvMeC")
        AVOSCloud.setAllLogsEnabled(false)
        
        Fabric.with([Crashlytics.self, Answers.self])
        
        self.window?.rootViewController?.tabBarController?.childViewControllers[2].removeFromParentViewController()
        
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
        if let vc = window?.rootViewController?.childViewControllerForStatusBarStyle {
            if let vc = vc as? UINavigationController {
                if let vc = vc.childViewControllerForStatusBarStyle as? MeLoginVC {
                    if vc.seconds > 0 {
                        let query = AVBaker.query()
                        query.whereKey(lcKey[.phone]!, equalTo: vc.phoneNum)
                        query.getFirstObjectInBackground({
                            object, error in
                            if error == nil {
                                let usr = object as! AVBaker
                                vc.seconds = Date().seconds(fromDate: usr.msgSentDate!)
                            }
                        })
                    }
                }
            }
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        if let vc = window?.rootViewController?.childViewControllerForStatusBarStyle {
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
    }
}

