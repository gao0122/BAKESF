//
//  MeVC.swift
//  BAKESF
//
//  Created by 高宇超 on 5/16/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit
import PagingMenuController

class MeVC: UIViewController {
    
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var bgImageView: UIImageView!
    
    var user = RecentUserRealm()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var bgImage = UIImage()

        user = RealmHelper.retrieveRecentUser().first!
        
        if user.phone != nil && user.phone.characters.count == 11 {
            loginBtn.setTitle("重新登录", for: UIControlState.normal)
            userNameLabel.text = "欢迎 \(user.phone!)"
            
            // todo
            bgImage = UIImage()
        } else {
            loginBtn.setTitle("立即登录", for: UIControlState.normal)
            userNameLabel.text = ""
            
            bgImage = UIImage()
        }
        bgImageView.image = bgImage
        
        // page menu 
        struct MeMemory: MenuItemViewCustomizable {
            var displayMode: MenuItemDisplayMode {
                return .text(title: MenuItemText(text: "回忆"))
            }
        }
        struct MeTweet: MenuItemViewCustomizable {
            var displayMode: MenuItemDisplayMode {
                return .text(title: MenuItemText(text: "推文"))
            }
        }
        
        struct MenuOptions: MenuViewCustomizable {
            var itemsOptions: [MenuItemViewCustomizable] {
                return [MeMemory(), MeTweet()]
            }
            
            var scroll: MenuScrollingMode
            var displayMode: MenuDisplayMode
            var animationDuration: TimeInterval
            
            var focusMode: MenuFocusMode {
                return .underline(height: 3, color: UIColor.black, horizontalPadding: 10, verticalPadding: 0)
            }
        }
        
        struct PagingMenuOptions: PagingMenuControllerCustomizable {
            let meMemoryVC = MeMemoryVC.instantiateFromStoryboard()
            let meTweetVC = MeTweetVC.instantiateFromStoryboard()
            
            var componentType: ComponentType {
                return .all(menuOptions: MenuOptions(scroll: .scrollEnabledAndBouces, displayMode: .segmentedControl, animationDuration: 0.24), pagingControllers: [meMemoryVC, meTweetVC])
            }
            
            var defaultPage: Int
            var isScrollEnabled: Bool
        }
        
        let pagingMenuController = self.childViewControllers.first! as! PagingMenuController
        let option = PagingMenuOptions(defaultPage: 0, isScrollEnabled: true)
        pagingMenuController.setup(option)
        pagingMenuController.onMove = {
            state in
            
            switch state {
            case let .willMoveController(menuController, previousMenuController):
                print()
                
            case let .didMoveController(menuController, previousMenuController):
                print()
                
            case let .willMoveItem(menuItemView, previousMenuItemView):
                print()
                
            case let .didMoveItem(menuItemView, previousMenuItemView):
                print()
                
            case .didScrollStart:
                print()
                
            case .didScrollEnd:
                print()
                
            }
        }
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }

    
    @IBAction func loginBtnPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        let meLoginByMsgVC = storyboard.instantiateViewController(withIdentifier: "loginByMsg") as! MeLoginByMsgVC

        if loginBtn.titleLabel?.text == "重新登录" {
            
            self.alertOkayOrNot(okTitle: "确定", notTitle: "取消", msg: "确定登出此账号并重新登录吗？", okAct: { _ in
                self.user = RecentUserRealm()
            }, notAct: { _ in })
            self.present(meLoginByMsgVC, animated: true, completion: nil)
            
        } else if loginBtn.titleLabel?.text == "立即登录" {
            
            self.present(meLoginByMsgVC, animated: true, completion: nil)
        }
    }
    
}

