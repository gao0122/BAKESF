//
//  MeVC.swift
//  BAKESF
//
//  Created by 高宇超 on 5/16/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit
import PagingMenuController

class MeVC: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var bgImageView: UIImageView!
    
    var user: UserRealm!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        let _ = checkCurrentUser()
        
        var bgImage = UIImage()
        // todo
        bgImage = UIImage()
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

    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            switch id {
            case "showLogin":
                let sourceVC = segue.source
                sourceVC.navigationController?.interactivePopGestureRecognizer?.delegate = self
                sourceVC.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            case "unwindToMeFromLogin":
                userNameLabel.text = "欢迎 \(self.user.phone)"
            default:
                break
            }
        }
    }

    
    @IBAction func unwindToMeVC(segue: UIStoryboardSegue) {
        let _ = checkCurrentUser()
        
        if let id = segue.identifier {
            switch id {
            case "unwindToMeFromLogin":
                break
            case "unwindToMeFromSetting":
                break
            default:
                break
            }
        }
    }
    
    func checkCurrentUser() -> Bool {
        if let usr = RealmHelper.retrieveCurrentUser() {
            user = usr
            loginBtn.isHidden = true
            userNameLabel.text = "欢迎 \(user.phone)"
            return true
        } else {
            loginBtn.isHidden = false
            userNameLabel.text = ""
            return false
        }
    }
    
}

