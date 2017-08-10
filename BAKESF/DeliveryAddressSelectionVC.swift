//
//  DeliveryAddressSelectionVC.swift
//  BAKESF
//
//  Created by 高宇超 on 8/8/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

class DeliveryAddressSelectionVC: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, AMapSearchDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var cityBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var helperView: UIView!
    @IBOutlet weak var helperLabel: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var relocateBtn: UIButton!
    @IBOutlet weak var currentAddressNameLabel: UILabel!
    @IBOutlet weak var currentAddressLabel: UILabel!
    @IBOutlet weak var currentCityLabel: UILabel!
    @IBOutlet weak var currentLocationView: UIView!

    var citys = [Int: [String]]()
    var pois = [AMapPOI]()
    var showSegueID: String!
    var unwindSegueID: String!
    var selectedPOI: AMapPOI!
    var fromCellSelection = false

    private let mapSearch = AMapSearchAPI()!
    private let locationManager = AMapLocationManager()
    private var locationRealm: LocationRealm = {
        return RealmHelper.retrieveLocation()!
    }()
    
    private let noResultText = "没有结果\n\n换个地址试试吧~"
    private let searchingText = "正在搜索..."
    private let errorText = "出错啦！"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        switch showSegueID {
        case "showDeliveryAddressSelectionVCFromDAEditingVC":
            unwindSegueID = "unwindToDeliveryAddressEditingVCFromDASelectionVC"
        case "showDASelctionVCFromHomeVC", "showDASelctionVCFromHomeVCNaN":
            unwindSegueID = "unwindToHomeVCFromDASelectionVC"
        default:
            break
        }
        updateCurrentLocationView()
        relocateBtn.layer.borderColor = relocateBtn.currentTitleColor.cgColor
        relocateBtn.layer.borderWidth = 1
        relocateBtn.layer.cornerRadius = 3
        
        mapSearch.delegate = self
        
        citys[0] = ["正在定位中..."]
        tableView.estimatedRowHeight = 56
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        helperView.isHidden = true
        doPOISearch()
        currentLocationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(currentLocationSelected(_:))))
    }
    
    func currentLocationSelected(_ sender: Any) {
        fromCellSelection = true
        doReGeocode(with: amapGeoPointToCLLocation(selectedPOI.location))
    }
    
    func updateCurrentLocationView() {
        if showSegueID == "showDASelctionVCFromHomeVCNaN" {
            currentCityLabel.text = "最近一次使用的地址："
        } else {
            currentCityLabel.text = "当前地址："
        }
        cityBtn.setTitle(locationRealm.city, for: .normal)
        cityBtn.sizeToFit()
        searchBar.frame.origin.x = 24 + cityBtn.frame.width
        searchBar.frame.size.width = cancelBtn.frame.origin.x - searchBar.frame.origin.x
        currentAddressNameLabel.text = locationRealm.aoiname
        currentAddressLabel.text = locationRealm.address
    }
    
    class func instantiateFromStoryboard() -> DeliveryAddressSelectionVC {
        return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: self)) as! DeliveryAddressSelectionVC
    }

    @IBAction func relocateBtnPressed(_ sender: Any) {
        showHelperView(with: searchingText)
        locateOnce()
    }
    
    @IBAction func cityBtnPressed(_ sender: Any) {
        
    }
    
    func showHelperView(with text: String) {
        helperView.isHidden = false
        helperLabel.text = text
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else { return }
        switch id {
        case "unwindToDeliveryAddressEditingVCFromDASelectionVC":
            guard let vc = segue.destination as? DeliveryAddressEditingVC else { break }
            vc.selectedPOI = self.selectedPOI
            vc.addressSelectionBtn.setTitle(selectedPOI.address, for: .normal)
        case "unwindToHomeVCFromDASelectionVC":
            if let vc = segue.destination as? HomeShopVC {
                vc.homeVC.poiChanged = selectedPOI != vc.homeVC.selectedPOI
                vc.homeVC.selectedPOI = self.selectedPOI
            }
            if let vc = segue.destination as? HomeBakeVC {
                vc.homeVC.poiChanged = selectedPOI != vc.homeVC.selectedPOI
                vc.homeVC.selectedPOI = self.selectedPOI
            }
            if let vc = segue.destination as? HomeFollowVC {
                vc.homeVC.poiChanged = selectedPOI != vc.homeVC.selectedPOI
                vc.homeVC.selectedPOI = self.selectedPOI
            }
        default:
            break
        }
    }
    
    @IBAction func unwindToVC(_ sender: Any) {
        self.performSegue(withIdentifier: unwindSegueID, sender: self)
    }
    
    // MARK: - AMap
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        if response.count == 0 {
            self.showHelperView(with: noResultText)
            return
        }
        self.pois = response.pois
        if self.pois.count == 0 {
            self.showHelperView(with: noResultText)
            self.tableView.isHidden = true
        } else {
            self.helperView.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
    
    func onReGeocodeSearchDone(_ request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        guard let regeocode = response.regeocode else {
            // TODO: - no results
            self.helperView.isHidden = true
            return
        }
        self.locationRealm = RealmHelper.addLocation(by: regeocode)
        self.updateCurrentLocationView()
        if fromCellSelection {
            self.performSegue(withIdentifier: unwindSegueID, sender: self)
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
                    vc.showHelperView(with: vc.errorText)
                }
                return
            }
            
            if let location = location, let vc = self {
                vc.fromCellSelection = false
                vc.doReGeocode(with: location)
            }
            
            if let reGeocode = reGeocode {
                printit("reGeocode: \(reGeocode)")
            }
        })
    }
    
    private func doReGeocode(with location: CLLocation) {
        let request = AMapReGeocodeSearchRequest()
        request.location = cllocationToAMapGeoPoint(location)
        request.requireExtension = true
        mapSearch.cancelAllRequests()
        mapSearch.aMapReGoecodeSearch(request)
    }
    
    private func doPOISearch() {
        let request = AMapPOIAroundSearchRequest()
        request.location = AMapGeoPoint.location(withLatitude: CGFloat(Double(locationRealm.latitude)!), longitude: CGFloat(Double(locationRealm.longitude)!))
        request.requireExtension = true
        request.keywords = searchBar.text!

        mapSearch.cancelAllRequests()
        mapSearch.aMapPOIAroundSearch(request)
        
        showHelperView(with: searchingText)
    }

    
    // MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        switch tableView.tag {
        case 0:
            return 1
        case 1:
            return citys.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case 0:
            return pois.count
        case 1:
            return citys[section]!.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch tableView.tag {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "deliveryAddressSelectionTableViewCell", for: indexPath) as! DeliveryAddressSelectionTableViewCell
            let poi = pois[row]
            cell.poi = poi
            cell.addressLabel.text = poi.address!
            cell.aoiNameLabel.text = poi.name!
            return cell
        case 1:
            let section = indexPath.section
            return UITableViewCell()
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView.tag {
        case 0:
            guard let cell = tableView.cellForRow(at: indexPath) as? DeliveryAddressSelectionTableViewCell else { break }
            selectedPOI = cell.poi
            fromCellSelection = true
            doReGeocode(with: amapGeoPointToCLLocation(selectedPOI.location))
        case 1:
            break
        default:
            break
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - SearchBar
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        doPOISearch()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}
