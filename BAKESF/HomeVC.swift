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
    @IBOutlet weak var locateFailedView: UIView!
    @IBOutlet weak var retryBtn: UIButton!
    @IBOutlet weak var locateManuallyBtn: UIButton!
    @IBOutlet weak var helperLabel: UILabel!
    
    private var homeShopVC: HomeShopVC!
    private var homeBakeVC: HomeBakeVC!
    private var homeFollowVC: HomeFollowVC!
    private var sellerTableView: UITableView!
    private var bakeTableView: UITableView!
    private var followTableView: UITableView!

    let bakeLocationRadius: CGFloat = 3000
    
    var user: UserRealm!
    var avbaker: AVBaker!
    var selectedPOI: AMapPOI!
    var pois = [AMapPOI]()
    var poiChanged = false
    var locateManuallyBtnPressed = false
    var locationRealm: LocationRealm? = {
        return RealmHelper.retrieveLocation()
    }()
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
    
    override func viewDidAppear(_ animated: Bool) {
        if poiChanged && selectedPOI != nil {
            if let locationRealm = locationRealm {
                locateFailedView.isHidden = true
                locationBtn.setTitle(locationRealm.city, for: .normal)
                homeShopVC.refresher.beginRefreshing()
            } else {
                locateFailedView.isHidden = false
            }
        }
    }
    
    func preInit() {
        searchBarWidth = searchBar.frame.width
        mapSearch.delegate = self
        locateFailedView.isHidden = true
        indicatorStartAni()
        checkCurrentUser()
        retryBtn.layer.cornerRadius = 4
        retryBtn.layer.borderWidth = 1
        retryBtn.layer.borderColor = UIColor.bkRed.cgColor
        retryBtn.setTitleColor(.bkRed, for: .normal)
        locateManuallyBtn.layer.cornerRadius = 4
        locateManuallyBtn.layer.borderWidth = 1
        locateManuallyBtn.layer.borderColor = UIColor.bkRed.cgColor
        locateManuallyBtn.setTitleColor(.bkRed, for: .normal)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else { return }
        switch id {
        case "showDASelctionVCFromHomeVC":
            guard let vc = segue.destination as? DeliveryAddressSelectionVC else { break }
            vc.showSegueID = id
            if locateManuallyBtnPressed {
                locateManuallyBtnPressed = false
                vc.showSegueID = id + "NaN"
            }
        default:
            break
        }
    }
    
    @IBAction func locationBtnPressed(_ sender: Any) {
        // do nothing
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
    
    @IBAction func relocateBtnPressed(_ sender: Any) {
        indicatorStartAni()
        locateOnce()
    }
    
    @IBAction func locateManuallyBtnPressed(_ sender: Any) {
        locateManuallyBtnPressed = true
        performSegue(withIdentifier: "showDASelctionVCFromHomeVC", sender: sender)
    }
    
    
    func indicatorStartAni() {
        indicatorView.startAnimating()
        indicatorSuperView.isHidden = false
    }
    
    func indicatorStopAni() {
        indicatorView.stopAnimating()
        indicatorSuperView.isHidden = true
    }

    func hideLocateFailedViewAndStopIndicator() {
        locateFailedView.isHidden = true
        indicatorStopAni()
    }
    
    func showLocateFailedViewAndStopIndicator() {
        locateFailedView.isHidden = false
        indicatorStopAni()
    }
    
    
    // MARK: - AMap
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        if response.count == 0 { return }
        //response.pois
    }
    
    func onReGeocodeSearchDone(_ request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        guard let regeocode = response.regeocode else {
            // TODO: - no results
            self.showLocateFailedViewAndStopIndicator()
            return
        }
        locationRealm = RealmHelper.addLocation(by: regeocode)
        updateLocationBtnAndSearchBar(by: locationRealm!)
        print(regeocode: regeocode)
        hideLocateFailedViewAndStopIndicator()
    }
    
    private func locateOnce() {
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
                self?.showLocateFailedViewAndStopIndicator()
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
    
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        showLocateFailedViewAndStopIndicator()
        var text = "出错啦！"
        if let error = error as NSError? {
            switch error.code {
            case 1802:
                text = "网络似乎不是很稳。"
            case 1806:
                text = "似乎断网了。"
            default:
                break
            }
        }
        helperLabel.text = text
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
        // variable setup
        self.sellerTableView = option.homeShopVC.tableView
        self.homeShopVC = option.homeShopVC
        self.homeBakeVC = option.homeBakeVC
        self.homeFollowVC = option.homeFollowVC
        self.homeShopVC.homeVC = self
        
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


