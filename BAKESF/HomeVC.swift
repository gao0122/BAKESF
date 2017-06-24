//
//  HomeVC.swift
//  BAKESF
//
//  Created by 高宇超 on 5/15/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit
import PagingMenuController
import Alamofire

class HomeVC: UIViewController {

    @IBOutlet weak var masterView: UIView!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var searchTextBtn: UIButton!
    @IBOutlet weak var searchBarBtn: UIButton!
    
    var user = RecentUserRealm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBarBtn.layer.cornerRadius = 5
        
        RealmHelper.initCurrentSeller()
        
        if let usr = RealmHelper.retrieveRecentUser().first {
            self.user = usr
        } else {
            RealmHelper.addUser(user: UserRealm())
            RealmHelper.updateRecentUser(user: user)
        }

        // page menu
        struct HomeSeller: MenuItemViewCustomizable {
            var displayMode: MenuItemDisplayMode {
                return .text(title: MenuItemText(text: "私房"))
            }
        }
        struct HomeBake: MenuItemViewCustomizable {
            var displayMode: MenuItemDisplayMode {
                return .text(title: MenuItemText(text: "食野"))
            }
        }
        struct HomeFollow: MenuItemViewCustomizable {
            var displayMode: MenuItemDisplayMode {
                return .text(title: MenuItemText(text: "关注"))
            }
        }
        
        struct MenuOptions: MenuViewCustomizable {
            var itemsOptions: [MenuItemViewCustomizable] {
                return [HomeSeller(), HomeBake(), HomeFollow()]
            }
            
            var scroll: MenuScrollingMode
            var displayMode: MenuDisplayMode
            var animationDuration: TimeInterval
            
            var focusMode: MenuFocusMode {
                return .underline(height: 3, color: UIColor.black, horizontalPadding: 10, verticalPadding: 0)
            }
        }
        
        struct PagingMenuOptions: PagingMenuControllerCustomizable {
            let homeSellerVC = HomeSellerVC.instantiateFromStoryboard()
            let homeBakeVC = HomeBakeVC.instantiateFromStoryboard()
            let homeFollowVC = HomeFollowVC.instantiateFromStoryboard()

            var componentType: ComponentType {
                return .all(menuOptions: MenuOptions(scroll: .scrollEnabledAndBouces, displayMode: .segmentedControl, animationDuration: 0.24), pagingControllers: [homeSellerVC, homeBakeVC, homeFollowVC])
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
    
}


