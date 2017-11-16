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

class HomeVC: UIViewController, UISearchBarDelegate, AMapSearchDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var masterView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var locationBtn: UIButton!
    @IBOutlet weak var indicatorSuperView: UIView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var locateFailedView: UIView!
    @IBOutlet weak var retryBtn: UIButton!
    @IBOutlet weak var locateManuallyBtn: UIButton!
    @IBOutlet weak var helperLabel: UILabel!
    @IBOutlet weak var searchResultsTableView: UITableView!
    @IBOutlet weak var searchResultsView: UIView!
    @IBOutlet weak var searchResultsHelperView: UIView!
    @IBOutlet weak var searchHistoryLabel: UILabel!
    @IBOutlet weak var searchHotLabel: UILabel!
    @IBOutlet weak var searchHistoryView: UIView!
    @IBOutlet weak var searchHotView: UIView!
    @IBOutlet weak var searchHelperLabel: UILabel!
    @IBOutlet weak var rapperView: UIView!
    
    private var homeShopVC: HomeShopVC!
    private var homeBakeVC: HomeBakeVC!
    private var homeFollowVC: HomeFollowVC!
    private var sellerTableView: UITableView!
    private var bakeTableView: UITableView!
    private var followTableView: UITableView!
    
    let bakeLocationRadius: CGFloat = 3000
    
    var user: UserRealm!
    var avbaker: AVBaker?
    var selectedPOI: AMapPOI?
    var pois = [AMapPOI]()
    var poiChanged = false
    var locateManuallyBtnPressed = false
    var locationRealm: LocationRealm? = {
        return RealmHelper.retrieveLocation(by: 0)
    }()
    var locatedOnce = false
    var searchBarWidth: CGFloat!
    var hasSetShopView = false
    var searchResults = [AVShop: [AVBake]]()
    var searchResultShops = [AVShop]()

    let searchItemBtnWidthToAdd: CGFloat = 17
    
    let noShopsText = "未在该城市发现私房"
    let locateErrorText = "加载失败，请重试"
    let searchResultsNoResultsText = "未找到相关结果"
    let searchResultsToSearchText = "输入商品名称、类别或私房名称搜索"
    
    private let mapSearch = AMapSearchAPI()!
    private let locationManager = AMapLocationManager()
    private var clLocation: CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()

        preInit()
        
        setPageMenu()

        locateOnce()
        searchBar.inputAccessoryView = {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 34))
            label.text = searchResultsToSearchText
            label.textColor = .iron
            label.backgroundColor = .bkWhite
            label.textAlignment = .center
            return label
        }()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let tabBarController = self.tabBarController {
            tabBarController.tabBar.isHidden = false
            let duration: TimeInterval = animated ? 0.17 : 0
            UIView.animate(withDuration: duration, animations: {
                tabBarController.tabBar.frame.origin.y = screenHeight - tabBarController.tabBar.frame.height
            }, completion: {
                _ in
                tabBarController.tabBar.frame.origin.y = screenHeight - tabBarController.tabBar.frame.height
            })
        }

        checkCurrentUser()
        if poiChanged && selectedPOI != nil {
            if let locationRealm = RealmHelper.retrieveLocation(by: 0) {
                locateFailedView.isHidden = true
                updateLocationBtnAndSearchBar(by: locationRealm.city)
                homeShopVC.refresher.beginRefreshing()
            } else {
                locateFailedView.isHidden = false
            }
        } else if selectedPOI == nil {
            if let locationRealm = RealmHelper.retrieveLocation(by: 0) {
                locateFailedView.isHidden = true
                updateLocationBtnAndSearchBar(by: locationRealm.city)
                homeShopVC.refresher.beginRefreshing()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func preInit() {
        searchBarWidth = searchBar.frame.width
        mapSearch.delegate = self
        locateFailedView.isHidden = true
        indicatorStartAni()
        retryBtn.setBorder(with: .bkRed)
        locateManuallyBtn.setBorder(with: .bkRed)
        view.bringSubview(toFront: locateFailedView)
        view.bringSubview(toFront: indicatorSuperView)
        searchResultsTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        searchResultsHelperView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelSearch(_:))))
        searchResultsTableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelSearch(_:))))
        navigationController?.navigationBar.barTintColor = .bkRed
        navigationController?.navigationBar.tintColor = .white
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else { return }
        switch id {
        case "showDASelctionVCFromHomeVC":
            guard let vc = segue.destination as? DeliveryAddressSelectionVC else { break }
            vc.showSegueID = id
            vc.avbaker = self.avbaker
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
    
    func updateLocationBtnAndSearchBar(by city: String) {
        locationBtn.setTitle(city, for: .normal)
        locationBtn.sizeToFit()
        locationBtn.frame.size.width += 8
        locationBtn.frame.origin.x = screenWidth - 12 - locationBtn.frame.width
        searchBar.frame.size.width = locationBtn.frame.origin.x - searchBar.frame.origin.x
        searchBarWidth = searchBar.frame.width
    }
    
    @IBAction func relocateBtnPressed(_ sender: Any) {
        if helperLabel.text == noShopsText {
        }
        homeShopVC.loadShops()
        indicatorStartAni()
        locateOnce()
    }
    
    @IBAction func locateManuallyBtnPressed(_ sender: Any) {
        locateManuallyBtnPressed = true
        performSegue(withIdentifier: "showDASelctionVCFromHomeVC", sender: sender)
    }
    
    
    func indicatorStartAni() {
        helperLabel.text = ""
        indicatorView.startAnimating()
        indicatorSuperView.isHidden = false
    }
    
    func indicatorStopAni() {
        indicatorView.stopAnimating()
        indicatorSuperView.isHidden = true
    }

    func hideLocateFailedViewAndStopIndicator() {
        if helperLabel.text == noShopsText { return }
        locateFailedView.isHidden = true
        indicatorStopAni()
    }
    
    func showLocateFailedViewAndStopIndicator(with text: String) {
        helperLabel.text = text
        locateFailedView.isHidden = false
        indicatorStopAni()
    }
    
    
    // MARK: - AMap
    func onReGeocodeSearchDone(_ request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        guard let regeocode = response.regeocode else {
            // TODO: - no results
            self.showLocateFailedViewAndStopIndicator(with: locateErrorText)
            return
        }
        locatedOnce = true
        locationRealm = RealmHelper.addLocation(by: regeocode, for: 0)
        homeShopVC.tableView.reloadData()
        updateLocationBtnAndSearchBar(by: locationRealm!.city)
        if let _ = avbaker {
            hideLocateFailedViewAndStopIndicator()
        } else if user == nil {
            hideLocateFailedViewAndStopIndicator()
        }
        
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
                if let vc = self {
                    vc.showLocateFailedViewAndStopIndicator(with: vc.locateErrorText)
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
    
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        showLocateFailedViewAndStopIndicator(with: locateErrorText)
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
        self.setSearchHotHelperItemLabels()
        self.searchBar.setShowsCancelButton(true, animated: true)
        UIView.animate(withDuration: 0.23, delay: 0, options: [.curveEaseInOut], animations: {
            self.searchBarFocusAni()
        }, completion: {
            finished in
            self.searchBarFocusAni()
        })
        
        if let avbaker = self.avbaker {
            let query = AVQuery(className: "HomePageSearchHistory")
            query.addAscendingOrder("createdAt")
            query.whereKey("baker", equalTo: avbaker)
            query.findObjectsInBackground({
                objs, error in
                
            })
        } else {
            let histories = RealmHelper.retrieveSearchHistories().reversed()
            printit(histories)
        }
        
        setSearchResultsViewHidden(for: false)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        cancelSearch(self)
    }
    
    func cancelSearch(_ sender: Any) {
        self.dismissKeyboard(sender: sender)
        UIView.animate(withDuration: 0.21, delay: 0, options: [.curveEaseInOut], animations: {
            self.searchBarCancelAni()
        }, completion: {
            _ in
            self.searchBarCancelAni()
        })
        self.setSearchResultsViewHidden(for: true)
        self.searchBar.text = ""
        self.searchResults.removeAll()
        self.searchResultsTableView.reloadData()
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // search
        guard let text = searchBar.text else { return }
        guard text.count > 0 else {
            setSearchHelperLabelHidden(for: false, with: "请输入搜索内容后重试。")
            return
        }
        let query = AVBake.query()
        query.whereKey("name", contains: text)
        query.includeKey("image")
        query.includeKey("shop")
        query.includeKey("shop.address")
        query.includeKey("shop.headphoto")
        query.addAscendingOrder("priority")
        query.limit = 10
        query.findObjectsInBackground({
            objects, error in
            if let bakes = objects as? [AVBake] {
                self.recordSearchHistory(with: text)
                if bakes.count == 0 {
                    self.setSearchHelperLabelHidden(for: false, with: "没有找到相关结果。")
                    self.searchResultsHelperView.isHidden = false
                    self.searchHistoryView.isHidden = true
                    self.searchHotView.isHidden = true
                } else {
                    self.searchHistoryView.isHidden = false
                    self.searchHotView.isHidden = false
                    self.searchResultsHelperView.isHidden = true
                    self.setSearchHelperLabelHidden(for: true, with: "")
                    for bake in bakes {
                        if let shop = bake.shop {
                            if self.searchResults[shop] == nil {
                                self.searchResults[shop] = [AVBake]()
                            }
                            self.searchResults[shop]!.append(bake)
                            self.searchResultShops.append(shop)
                        }
                    }
                    self.searchResultsTableView.reloadData()
                    self.searchBar.resignFirstResponder()
                }
            } else {
                self.view.notify(text: "发生未知错误，请检查网络。", color: UIColor.alertRed, nav: self.navigationController?.navigationBar)
            }
        })
    }
    
    func recordSearchHistory(with text: String) {
        let searchRealm = SearchHistoryRealm()
        searchRealm.searchingDate = Date()
        searchRealm.searchingText = text
        if let baker = self.avbaker {
            let searchObj = AVHomePageSearchHistory()
            searchObj.baker = baker
            searchObj.searchingText = text
            searchObj.saveInBackground({
                _ in
            })
            searchRealm.searchingUserID = baker.objectId!
        }
        RealmHelper.addSearchHistory(searchRealm)
        printit("searching: \(text)")
    }
    
    func setSearchHelperLabelHidden(for shouldHidden: Bool, with text: String) {
        self.searchHelperLabel.text = text
        self.searchHelperLabel.isHidden = shouldHidden
    }
    
    func setSearchResultsViewHidden(for shouldHidden: Bool) {
        searchResultsView.isHidden = shouldHidden
        if shouldHidden {
            view.bringSubview(toFront: locateFailedView)
            view.bringSubview(toFront: indicatorSuperView)
        } else {
            view.bringSubview(toFront: searchResultsView)
            view.bringSubview(toFront: rapperView)
            view.bringSubview(toFront: searchBar)
            view.bringSubview(toFront: locationBtn)
        }
    }
    
    func setSearchHotHelperItemLabels() {
        let btn = setSearchHotHelperItemLabel(nil, with: "烘焙精选")
        _ = setSearchHotHelperItemLabel(btn!, with: "私厨")
    }
    
    func setSearchHotHelperItemLabel(_ btnToBeCopied: UIButton?, with text: String) -> UIButton? {
        let rightMargin: CGFloat = 17 // it is also the width te be added to button
        if let btnToBeCopied = btnToBeCopied {
            let leftMargin: CGFloat = 22
            let x = btnToBeCopied.frame.origin.x
            let width = btnToBeCopied.frame.width
            let btn = UIButton(frame: btnToBeCopied.frame)
            btn.titleLabel?.font = btnToBeCopied.titleLabel!.font
            btn.setTitle(text, for: .normal)
            btn.sizeToFit()
            btn.frame.size.width += rightMargin
            btn.frame.origin.x = x + width + rightMargin
            guard leftMargin + btn.frame.origin.x + btn.frame.size.width + rightMargin <= screenWidth else { return nil }
            self.setSearchBtn(btn)
            self.searchHotView.addSubview(btn)
            return btn
        } else {
            let btn = UIButton()
            btn.setTitle(text, for: .normal)
            btn.titleLabel?.font = btn.titleLabel!.font.withSize(14)
            btn.sizeToFit()
            btn.frame.size.width += rightMargin
            btn.frame.origin = CGPoint(x: 0, y: 32)
            self.setSearchBtn(btn)
            self.searchHotView.addSubview(btn)
            return btn
        }
    }
    
    func setSearchBtn(_ btn: UIButton) {
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 4
        btn.backgroundColor = UIColor.lightGray
    }

    
    // MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultShops.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeSearchResultTableViewCell", for: indexPath) as! HomeSearchResultTableViewCell
        let avshop = searchResultShops[row]
        if let _ = searchResults[avshop] {
            cell.nameLabel.text = avshop.name
            cell.nameLabel.sizeToFit()
            let lowestFee = avshop.lowestFee?.stringValue ?? "0"
            let deliveryFee = avshop.deliveryFee?.stringValue ?? "0"
            cell.starLabel.text = "评价5.0"
            cell.starLabel.sizeToFit()
            
            cell.leastFeeLabel.frame.origin.x = cell.starLabel.frame.origin.x + cell.starLabel.frame.width + 15
            cell.leastFeeLabel.text = "¥" + lowestFee + "起送"
            cell.leastFeeLabel.sizeToFit()
            
            cell.deliveryFeeLabel.text = "配送费¥" + deliveryFee
            cell.deliveryFeeLabel.sizeToFit()
            
            cell.deliveryCycleLabel.text = ""
            cell.deliveryCycleLabel.frame.origin.x = cell.leastFeeLabel.frame.origin.x + cell.leastFeeLabel.frame.width + 15
            cell.deliveryCycleLabel.sizeToFit()
            
            cell.distanceLabel.text = calDistance(latitude0: avshop.address?.latitude, longitude0: avshop.address?.longitude, latitude1: locationRealm?.latitude, longitude1: locationRealm?.longitude)
            cell.distanceLabel.sizeToFit()
            
            if let url = avshop.headphoto?.url {
                cell.avatarIV.sd_setImage(with: URL(string: url), completed: nil)
                cell.avatarIV.contentMode = .scaleAspectFill
                cell.avatarIV.clipsToBounds = true
            }
            
            cell.bakesCollectionView.delegate = self
            cell.bakesCollectionView.dataSource = self
            cell.bakesCollectionView.tag = row
            cell.bakesCollectionView.reloadData()
        } else {
            printit("Error: result is nil.")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: - Collection View
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let tag = collectionView.tag
        let shop = searchResultShops[tag]
        let avbakes = searchResults[shop]
        return avbakes?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeSearchBakeCollectionViewCell", for: indexPath) as! HomeSearchResultBakeCollectionViewCell
        let tag = collectionView.tag
        let item = indexPath.item
        let shop = searchResultShops[tag]
        guard let avbakes = searchResults[shop] else { return cell }
        let avbake = avbakes[item]
        
        if let url = avbake.image?.url {
            cell.imageView.sd_setImage(with: URL(string: url), completed: nil)
        }
        cell.nameLabel.text = avbake.name
        
        return cell
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
        
        struct MenuOptions: MenuViewCustomizable {
            var itemsOptions: [MenuItemViewCustomizable] {
                return [HomeShop(), HomeBake()]
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
            
            var componentType: ComponentType {
                return .all(menuOptions: MenuOptions(scroll: .scrollEnabledAndBouces, displayMode: .segmentedControl, animationDuration: 0.24), pagingControllers: [homeShopVC, homeBakeVC])
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
        self.homeShopVC.homeVC = self
        
        pagingMenuController.onMove = {
            state in
            switch state {
            case let .willMoveController(menuController, previousMenuController):
                break
            case let .didMoveController(menuController, previousMenuController):
                break
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
    
    
    func checkCurrentUser() {
        if let usr = RealmHelper.retrieveCurrentUser() {
            if let _ = avbaker {
                // logged in
            } else {
                retrieveBaker(withID: usr.id, completion: {
                    object, error in
                    if let error = error {
                        printit("Retrieve Baker Error: \(error.localizedDescription)")
                        self.helperLabel.text = "登录失败。"
                        if self.locatedOnce && self.indicatorView.isAnimating {
                            self.showLocateFailedViewAndStopIndicator(with: self.locateErrorText)
                        }
                    } else {
                        if let baker = object as? AVBaker {
                            self.avbaker = baker
                            if self.locatedOnce && self.indicatorView.isAnimating {
                                self.hideLocateFailedViewAndStopIndicator()
                            }
                        } else {
                            if self.locatedOnce && self.indicatorView.isAnimating {
                                self.showLocateFailedViewAndStopIndicator(with: self.locateErrorText)
                            }
                        }
                    }
                })
            }
        }
    }
}


