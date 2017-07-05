//
//  HomeVC.swift
//  BAKESF
//
//  Created by 高宇超 on 5/15/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit
import PagingMenuController

class HomeVC: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var masterView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var locationBtn: UIButton!
    
    var user: UserRealm!
    var searchBarWidth: CGFloat! = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBarWidth = searchBar.frame.width

        if let usr = RealmHelper.retrieveCurrentUser() {
            // has logged in
            self.user = usr
            
        } else {
            // to login
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

    // MARK: - SearchBar
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.setShowsCancelButton(true, animated: true)
        UIView.animate(withDuration: 0.23, delay: 0, options: [.curveEaseInOut], animations: {
            self.searchBarFocusAni()
        }, completion: {
            finished in
            self.searchBarFocusAni()
        })
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard(sender: self)
        self.searchBar.setShowsCancelButton(false, animated: true)
        UIView.animate(withDuration: 0.21, delay: 0, options: [.curveEaseInOut], animations: {
            self.searchBarCancelAni()
        }, completion: {
            finished in
            self.searchBarCancelAni()
        })
    }
    
    func dismissKeyboard(sender: Any) {
        searchBar.resignFirstResponder()
    }

    func searchBarFocusAni() {
        self.searchBar.frame.size.width = self.view.frame.width - 16
        self.locationBtn.alpha = 0
    }
    
    func searchBarCancelAni() {
        self.searchBar.frame.size.width = self.searchBarWidth
        self.locationBtn.alpha = 1
    }
}


