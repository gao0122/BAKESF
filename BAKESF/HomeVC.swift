//
//  HomeVC.swift
//  BAKESF
//
//  Created by 高宇超 on 5/15/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

// TODO: - Searching(Semantic search)

import UIKit
import PagingMenuController
import AVOSCloud

class HomeVC: UIViewController, UISearchBarDelegate, AMapSearchDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var xView: UIView!
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
    @IBOutlet weak var searchHistoryBtnsView: UIView!
    @IBOutlet weak var searchHotBtnsView: UIView!
    @IBOutlet weak var rapperView: UIView!
    @IBOutlet weak var searchHotIndicatorView: UIActivityIndicatorView!
    

    private var homeShopVC: HomeShopVC!
    private var homeBakeVC: HomeBakeVC!
    private var homeFollowVC: HomeFollowVC!
    private var sellerTableView: UITableView!
    private var bakeTableView: UITableView!
    private var followTableView: UITableView!
    
    var needToUpdateHotSearchWords: Bool = true
    
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
    var searchResults = [String: [AVBake]]() // key: shop id.
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

        xView.fixiPhoneX(tab: self.tabBarController?.tabBar)
        
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
        if (searchBar.text?.count ?? 0) > 0 { return }

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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.needToUpdateHotSearchWords = true
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
        xView.bringSubview(toFront: locateFailedView)
        xView.bringSubview(toFront: indicatorSuperView)
        searchResultsView.bringSubview(toFront: searchResultsHelperView)
        searchResultsTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        searchResultsHelperView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelSearch(_:))))
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
        case "homeToShopFromSearchingShop":
            guard let shopVC = segue.destination as? ShopVC else { return }
            guard let indexPath = searchResultsTableView.indexPathForSelectedRow else { return }
            let section = indexPath.section
            let avshop = searchResultShops[section]
            
            shopVC.avshop = avshop
        case "homeToShopFromSearchingBake":
            guard let shopVC = segue.destination as? ShopVC else { return }
            guard let indexPath = searchResultsTableView.indexPathForSelectedRow else { return }
            let section = indexPath.section
            let row = indexPath.row
            let avshop = searchResultShops[section]
            guard let avshopID = avshop.objectId else { return }
            guard let avbakes = searchResults[avshopID] else { return }
            shopVC.searchingBake = avbakes[row - 1]
            shopVC.avshop = avshop
            printit(avbakes)
        default:
            break
        }
    }
    
    
    
    @IBAction func locationBtnPressed(_ sender: Any) {
        // do nothing
    }
    
    func updateLocationBtnAndSearchBar(by city: String) {
        locationBtn.setTitle(city, for: .normal)
        if city == "" {
            locationBtn.setTitle("火星", for: .normal)
        }
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
        self.resetSearchHotHelperItemLabels()
        self.resetSearchHistoryHelperItemLabels()
        self.searchBar.setShowsCancelButton(true, animated: true)
        if let searchText = searchBar.text {
            if searchText == "" {
                self.searchResultsTableView.isHidden = true
            }
        } else {
            self.searchResultsTableView.isHidden = true
        }
        UIView.animate(withDuration: 0.23, delay: 0, options: [.curveEaseInOut], animations: {
            self.searchBarFocusAni()
        }, completion: {
            finished in
            self.searchBarFocusAni()
        })
        
        self.setSearchResultsViewHidden(for: false)
        self.setSearchResultsHelperViewHidden(for: false)
        self.setSearchResultsTableViewHidden(for: false)
        self.setSearchHelperLabelHidden(for: true)
        self.setSearchResultsHotViewHidden(for: false)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.setSearchResultsHelperViewHidden(for: false)
            self.setSearchResultsTableViewHidden(for: true)
            self.setSearchHelperLabelHidden(for: true)
            self.setSearchResultsHotViewHidden(for: false)
            self.resetSearchHistoryHelperItemLabels()
        }
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
        search(with: text)
    }
    
    func search(with text: String) {
        guard text.count > 0 else {
            setSearchHelperLabelHidden(for: false, with: "请输入搜索内容后重试。")
            self.setSearchResultsHotViewHidden(for: true)
            self.setSearchResultsHistoryViewHidden(for: true)
            return
        }
        
        let query = AVBake.query()
        query.whereKey("name", contains: text)
        query.includeKey("image")
        query.includeKey("shop")
        query.includeKey("shop.baker")
        query.includeKey("shop.address")
        query.includeKey("shop.headphoto")
        query.includeKey("shop.bgImage")
        query.addAscendingOrder("priority")
        query.limit = 10
        query.findObjectsInBackground({
            objects, error in
            self.searchResults.removeAll()
            self.searchResultShops.removeAll()
            if let bakes = objects as? [AVBake] {
                self.recordSearchHistory(with: text)
                self.setSearchResultsHelperViewHidden(for: false)
                if bakes.count == 0 {
                    self.setSearchHelperLabelHidden(for: false, with: "没有找到相关结果。")
                    self.setSearchResultsHotViewHidden(for: true)
                    self.setSearchResultsHistoryViewHidden(for: true)
                } else {
                    self.setSearchResultsHelperViewHidden(for: true)
                    self.setSearchResultsTableViewHidden(for: false)
                    for bake in bakes {
                        if let shopID = bake.shop?.objectId {
                            if self.searchResults[shopID] == nil {
                                self.searchResults[shopID] = [AVBake]()
                            }
                            self.searchResults[shopID]!.append(bake)
                            if !self.searchResultShops.contains(bake.shop!) {
                                self.searchResultShops.append(bake.shop!)
                            }
                        }
                    }
                    self.searchResultsTableView.reloadData()
                    self.searchBar.resignFirstResponder()
                }
            } else {
                self.setSearchResultsHelperViewHidden(for: false)
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
    
    func setSearchHelperLabelHidden(for shouldHidden: Bool, with text: String = "") {
        self.searchHelperLabel.text = text
        self.searchHelperLabel.isHidden = shouldHidden
    }
    
    func setSearchResultsViewHidden(for shouldHidden: Bool) {
        searchResultsView.isHidden = shouldHidden
        if shouldHidden {
            xView.bringSubview(toFront: locateFailedView)
            xView.bringSubview(toFront: indicatorSuperView)
        } else {
            xView.bringSubview(toFront: searchResultsView)
            xView.bringSubview(toFront: rapperView)
            xView.bringSubview(toFront: searchBar)
            xView.bringSubview(toFront: locationBtn)
        }
    }
    
    func setSearchResultsHelperViewHidden(for shouldHidden: Bool) {
        searchResultsHelperView.isHidden = shouldHidden
    }
    
    func setSearchResultsTableViewHidden(for shouldHidden: Bool) {
        searchResultsTableView.isHidden = shouldHidden
    }
    
    func setSearchResultsHotViewHidden(for shouldHidden: Bool) {
        searchHotView.isHidden = shouldHidden
        if !shouldHidden {
            resetSearchHotHelperItemLabels()
        }
    }
    
    func setSearchResultsHistoryViewHidden(for shouldHidden: Bool) {
        searchHistoryView.isHidden = shouldHidden
        if !shouldHidden {
            setSearchHistoryHelperItemLabels()
        }
    }
    

    func resetSearchHotHelperItemLabels() {
        guard needToUpdateHotSearchWords else { return }
        
        self.searchHotIndicatorView.startAnimating()
        let query = AVQuery(className: "HotSearchingWord")
        query.addAscendingOrder("priority")
        query.findObjectsInBackground({
            (objs, error) in
            if let error = error {
                printit("search hot labels error: \(error.localizedDescription)")
            } else if let objs = objs as? [AVObject] {
                var lastBtn: UIButton?
                for hotWord in objs {
                    if let word = hotWord.object(forKey: "text") as? String {
                        lastBtn = self.setSearchHelperItemLabel(lastBtn, with: word, view: self.searchHotBtnsView)
                    }
                }
                self.needToUpdateHotSearchWords = false
                self.searchHotIndicatorView.stopAnimating()
            }
        })
    }

    func resetSearchHistoryHelperItemLabels() {
        self.searchHistoryBtnsView.subviews.forEach({ $0.removeFromSuperview() })
        let histories = RealmHelper.retrieveSearchHistories(by: avbaker)
        setSearchResultsHistoryViewHidden(for: histories.count == 0)
    }
    
    func setSearchHistoryHelperItemLabels() {
        var lastBtn: UIButton?
        for his in RealmHelper.retrieveSearchHistories(by: avbaker) {
            lastBtn = setSearchHelperItemLabel(lastBtn, with: his.searchingText, view: self.searchHistoryBtnsView)
        }
    }
    
    func setSearchHelperItemLabel(_ btnToBeCopied: UIButton?, with text: String, view: UIView) -> UIButton? {
        let rightMargin: CGFloat = 12 // it is also the width te be added to button
        if let btnToBeCopied = btnToBeCopied {
            let leftMargin: CGFloat = 0
            let ox = btnToBeCopied.frame.origin.x
            let width = btnToBeCopied.frame.width
            let btn = UIButton(frame: btnToBeCopied.frame)
            self.setSearchBtn(btn, with: text)
            btn.frame.size.width += rightMargin
            let x = ox + width + rightMargin
            
            btn.frame.origin.x = x
            guard leftMargin + btn.frame.origin.x + btn.frame.size.width + rightMargin <= screenWidth else { return nil }
            view.addSubview(btn)
            return btn
        } else {
            let btn = UIButton()
            self.setSearchBtn(btn, with: text)
            btn.frame.size.width += rightMargin
            btn.frame.origin = CGPoint(x: 0, y: 0)
            view.addSubview(btn)
            return btn
        }
    }
    
    func setSearchBtn(_ btn: UIButton, with text: String) {
        btn.setTitle(text, for: .normal)
        btn.setTitleColor(.bkBlack, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.sizeToFit()
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 4
        btn.backgroundColor = UIColor.btnBgGray
        btn.addTarget(self, action: #selector(HomeVC.searchHistoryBtnPresses(_:)), for: .touchUpInside)
    }
    
    func searchHistoryBtnPresses(_ sender: UIButton) {
        guard let text = sender.title(for: .normal) else { return }
        searchBar.text = text
        search(with: text)
    }

    @IBAction func removeAllBtnPressed(_ sender: Any) {
        RealmHelper.deleteAllSearchHistory()
        resetSearchHistoryHelperItemLabels()
    }
    
    
    // MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return searchResultShops.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let avshop = searchResultShops[section]
        guard let shopID = avshop.objectId else { return 0 }
        guard let avbakes = searchResults[shopID] else { return 0 }
        let count = avbakes.count
        if count == 1 {
            return 1 + 1
        } else if count < 3 {
            return 1 + count
        } else {
            return 1 + 3 + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let section = indexPath.section
        let avshop = searchResultShops[section]
        if row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "homeSearchResultTableViewCell", for: indexPath) as! HomeSearchResultTableViewCell
            guard let shopID = avshop.objectId else { return cell }
            if let _ = searchResults[shopID] {
                guard let name = avshop.name else { return cell }
                guard let searchBarText = searchBar.text else { return cell }
                cell.nameLabel.attributedText = name.attributedString(key: searchBarText, keyFont: UIFont.boldSystemFont(ofSize: cell.nameLabel.font.pointSize), color: UIColor.bkRed)
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
                    cell.avatarIV.makeRoundCorder(radius: cell.avatarIV.frame.width / 2)
                }
            } else {
                printit("Error: result is nil.")
            }
            return cell
        } else {
            let item = row - 1
            guard let shopID = avshop.objectId else { return UITableViewCell() }
            guard let avbakes = searchResults[shopID] else { return UITableViewCell() }
            if avbakes.count > 3 && row == 4 {
                return UITableViewCell.centerTextCell(with: "进店查看更多 >>", in: .bkBlack, fontSize: 12)
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "homeSearchResultBakeTableViewCell", for: indexPath) as! HomeSearchResultBakeTableViewCell
                let avbake = avbakes[item]
                
                if let url = avbake.image?.url {
                    cell.bakeIV.sd_setImage(with: URL(string: url), completed: nil)
                    cell.bakeIV.contentMode = .scaleAspectFill
                    cell.bakeIV.clipsToBounds = true
                    cell.bakeIV.makeRoundCorder()
                }
                guard let name = avbake.name else { return cell }
                guard let searchBarText = searchBar.text else { return cell }
                cell.nameLabel.attributedText = name.attributedString(key: searchBarText, keyFont: UIFont.boldSystemFont(ofSize: cell.nameLabel.font.pointSize), color: UIColor.bkRed)
                cell.nameLabel.sizeToFit()
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 4 {
            self.performSegue(withIdentifier: "homeToShopFromSearchingShop", sender: tableView)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)

    }
    
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        if row == 0 {
            return 66
        } else if row == 4 {
            return 40
        } else {
            return 90
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if tableView.numberOfSections == section + 1 { return nil }
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 0))
        view.backgroundColor = UIColor(hex: 0xefefef)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableView.numberOfSections == section + 1 { return 0 }
        return 10
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


