//
//  HomeVC.swift
//  BAKESF
//
//  Created by 高宇超 on 5/15/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit
import PagingMenuController
import AVOSCloud

class HomeVC: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var masterView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var locationBtn: UIButton!
    
    private var sellerTableView: UITableView!
    private var bakeTableView: UITableView!
    private var followTableView: UITableView!
    
    var user: UserRealm!
    var avbaker: AVBaker!
    
    var searchBarWidth: CGFloat!
    var hasSetShopView = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBarWidth = searchBar.frame.width

        if let usr = RealmHelper.retrieveCurrentUser() {
            // has logged in
            self.user = usr
            self.avbaker = retrieveBaker(withID: user.id)
        } else {
            // to login
        }
        
        // page menu
        setPageMenu()
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
        UIView.animate(withDuration: 0.21, delay: 0, options: [.curveEaseInOut], animations: {
            self.searchBarCancelAni()
        }, completion: {
            finished in
            self.searchBarCancelAni()
        })
    }
    
    func dismissKeyboard(_ sender: Any) {
        self.searchBar.resignFirstResponder()
        self.searchBar.setShowsCancelButton(false, animated: true)
    }

    func searchBarFocusAni() {
        self.searchBar.frame.size.width = self.view.frame.width - 16
        self.locationBtn.alpha = 0
    }
    
    func searchBarCancelAni() {
        self.searchBar.frame.size.width = self.searchBarWidth
        self.locationBtn.alpha = 1
    }
    
    // MARK: - Page Menu
    func setPageMenu() {
        struct HomeShop: MenuItemViewCustomizable {
            var displayMode: MenuItemDisplayMode {
                return .text(title: MenuItemText(text: "私房", selectedColor: UIColor.red))
            }
        }
        struct HomeBake: MenuItemViewCustomizable {
            var displayMode: MenuItemDisplayMode {
                return .text(title: MenuItemText(text: "食野", selectedColor: UIColor.red))
            }
        }
        struct HomeFollow: MenuItemViewCustomizable {
            var displayMode: MenuItemDisplayMode {
                return .text(title: MenuItemText(text: "收藏", selectedColor: UIColor.red))
            }
        }
        
        struct MenuOptions: MenuViewCustomizable {
            var itemsOptions: [MenuItemViewCustomizable] {
                return [HomeShop(), HomeBake(), HomeFollow()]
            }
            
            var scroll: MenuScrollingMode
            var displayMode: MenuDisplayMode
            var animationDuration: TimeInterval
            
            var focusMode: MenuFocusMode {
                return .none //underline(height: 3, color: UIColor.red, horizontalPadding: 10, verticalPadding: 0)
            }
        }
        
        struct PagingMenuOptions: PagingMenuControllerCustomizable {
            let homeShopVC = HomeShopVC.instantiateFromStoryboard()
            let homeBakeVC = HomeBakeVC.instantiateFromStoryboard()
            let homeFollowVC = HomeFollowVC.instantiateFromStoryboard()
            
            var componentType: ComponentType {
                return .all(menuOptions: MenuOptions(scroll: .scrollEnabledAndBouces, displayMode: .segmentedControl, animationDuration: 0.24), pagingControllers: [homeShopVC, homeBakeVC, homeFollowVC])
            }
            
            var defaultPage: Int
            var isScrollEnabled: Bool
        }
        
        let pagingMenuController = self.childViewControllers.first! as! PagingMenuController
        let option = PagingMenuOptions(defaultPage: 0, isScrollEnabled: true)
        pagingMenuController.setup(option)
        self.sellerTableView = option.homeShopVC.tableView
        
        pagingMenuController.onMove = {
            state in
            switch state {
            case let .willMoveController(menuController, previousMenuController):
                break
            case let .didMoveController(menuController, previousMenuController):
                if let _ = menuController as? HomeFollowVC {
                    self.tabBarController?.tabBar.isHidden = false
                }
            case let .willMoveItem(menuItemView, previousMenuItemView):
                break
            case let .didMoveItem(menuItemView, previousMenuItemView):
                break
            case .didScrollStart:
                break
            case .didScrollEnd:
                break
            }
        }
    }
}


