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

class HomeVC: UIViewController, UISearchBarDelegate, AMapSearchDelegate {

    @IBOutlet weak var masterView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var locationBtn: UIButton!
    @IBOutlet weak var indicatorSuperView: UIView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    private var sellerTableView: UITableView!
    private var bakeTableView: UITableView!
    private var followTableView: UITableView!

    var user: UserRealm!
    var avbaker: AVBaker!
    
    var searchBarWidth: CGFloat!
    var hasSetShopView = false
    
    private let mapSearch = AMapSearchAPI()!
    private let locationManager = AMapLocationManager()
    private var clLocation: CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()

        preInit()
        
        // page menu
        setPageMenu()
        
        locateOnce()
    }
    
    func preInit() {
        searchBarWidth = searchBar.frame.width
        mapSearch.delegate = self
        indicatorStartAni()
        checkCurrentUser()
    }
    
    @IBAction func locationBtnPressed(_ sender: Any) {
        locateOnce()
        if let location = clLocation {
            let request = AMapPOIAroundSearchRequest()
            request.location = cllocationToAMapGeoPoint(location)
            request.requireExtension = true
            
            mapSearch.aMapPOIAroundSearch(request)
        }
    }
    
    func checkCurrentUser() -> Void {
        if let usr = RealmHelper.retrieveCurrentUser() {
            // has logged in
            self.user = usr
            self.avbaker = retrieveBaker(withID: user.id)
        } else {
            // to login
        }
    }

    func updateLocationBtnAndSearchBar(by location: LocationRealm) {
        locationBtn.setTitle(location.city, for: .normal)
        locationBtn.sizeToFit()
        locationBtn.frame.size.width += 8
        locationBtn.frame.origin.x = screenWidth - 12 - locationBtn.frame.width
        searchBar.frame.size.width = locationBtn.frame.origin.x - searchBar.frame.origin.x
        searchBarWidth = searchBar.frame.width
    }
    
    // MARK: - AMap
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        if response.count == 0 { return }
        for poi in response.pois {
            //printit(poi.address)
        }
    }
    
    func onReGeocodeSearchDone(_ request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        guard let regeocode = response.regeocode else {
            
            return
        }
        let location = RealmHelper.addLocation(by: regeocode)
        updateLocationBtnAndSearchBar(by: location)
        print(regeocode: regeocode)
        indicatorStopAni()
    }
    
    func locateOnce() {
        locationManager.setLocationAccuracyHundredMeters()
        locationManager.requestLocation(withReGeocode: false, completionBlock: {
            [weak self] (location: CLLocation?, reGeocode: AMapLocationReGeocode?, error: Error?) in
            if let error = error {
                let error = error as NSError
                let code = error.code
                if code == AMapLocationErrorCode.locateFailed.rawValue {
                    printit("定位错误：\(error.code) - \(error.localizedDescription)")
                } else if
                    code == AMapLocationErrorCode.reGeocodeFailed.rawValue
                        || code == AMapLocationErrorCode.timeOut.rawValue
                        || code == AMapLocationErrorCode.cannotFindHost.rawValue
                        || code == AMapLocationErrorCode.badURL.rawValue
                        || code == AMapLocationErrorCode.notConnectedToInternet.rawValue
                        || code == AMapLocationErrorCode.cannotConnectToHost.rawValue {
                    printit("逆地理错误：\(error.code) - \(error.localizedDescription)")
                } else {
                    printit("没有错误：\(error.code) - \(error.localizedDescription)")
                }
                return
            }
            
            if let location = location, let vc = self {
                let request = AMapReGeocodeSearchRequest()
                request.location = cllocationToAMapGeoPoint(location)
                request.requireExtension = true
                vc.mapSearch.aMapReGoecodeSearch(request)
                vc.clLocation = location
            }
            
            if let reGeocode = reGeocode {
                printit("reGeocode: \(reGeocode)")
            } else {
                
            }
        })
    }
    
    func indicatorStartAni() {
        indicatorView.startAnimating()
        indicatorSuperView.isHidden = false
    }
    
    func indicatorStopAni() {
        indicatorView.stopAnimating()
        indicatorSuperView.isHidden = true
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


