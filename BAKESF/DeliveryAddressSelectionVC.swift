//
//  DeliveryAddressSelectionVC.swift
//  BAKESF
//
//  Created by 高宇超 on 8/8/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

class DeliveryAddressSelectionVC: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, AMapSearchDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var cityBtn: UIButton!
    @IBOutlet weak var tableView: UITableView! // tag 0
    @IBOutlet weak var cityTableView: UITableView! // tag 1
    @IBOutlet weak var bakerDATableView: UITableView! // tag 2
    @IBOutlet weak var helperView: UIView!
    @IBOutlet weak var helperLabel: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var relocateBtn: UIButton!
    @IBOutlet weak var okayBtn: UIButton!
    @IBOutlet weak var currentAddressNameTextField: UITextField!
    @IBOutlet weak var currentAddressTextField: UITextField!
    @IBOutlet weak var currentCityLabel: UILabel!
    @IBOutlet weak var currentLocationView: UIView!

    var cities: [String: [String]] = {
        // retrieve city info from cities.plist
        var res = [String: [String]]()
        let path = Bundle.main.path(forResource: "cities", ofType: "plist")
        let dict = NSDictionary(contentsOfFile: path!) as! [String: Any]
        let keys = Array(dict.keys)
        for kv in dict {
            if let prov = kv.value as? [String: [String]] {
                if res[kv.key] == nil {
                    res[kv.key] = [String]()
                }
                res[kv.key]! = Array(prov.keys).sorted { $0 < $1 }
            } else {
                res[kv.key] = [kv.key]
            }
        }
        return res
    }()
    var provs: [String]!
    var addresses: [AVAddress]!
    var pois = [AMapPOI]()
    var showSegueID: String!
    var unwindSegueID: String!
    var selectedPOI: AMapPOI?
    var fromCellSelection = false
    var avbaker: AVBaker?
    var shouldSearchAround = true
    var currentReGeocode: AMapReGeocode?
    var tag: Int = 0

    private let mapSearch = AMapSearchAPI()!
    private let locationManager = AMapLocationManager()
    private var locationRealm: LocationRealm?
    
    private let noResultText = "没有结果\n\n换个地址试试吧~"
    private let searchingText = "正在搜索..."
    private let errorText = "出错啦！"
    private let locatingText = "正在获取当前位置..."
    
    override func viewDidLoad() {
        super.viewDidLoad()

        okayBtn.isHidden = true
        relocateBtn.frame.origin.x = okayBtn.frame.origin.x - 16
        currentAddressTextField.isUserInteractionEnabled = false
        currentAddressNameTextField.isUserInteractionEnabled = false
        
        provs = cities.keys.sorted(by: { $0 < $1 })
        switch showSegueID {
        case "showDeliveryAddressSelectionVCFromDAEditingVC":
            tag = 1
            //currentAddressTextField.isUserInteractionEnabled = true
            //currentAddressNameTextField.isUserInteractionEnabled = true
            unwindSegueID = "unwindToDeliveryAddressEditingVCFromDASelectionVC"
            locationRealm = RealmHelper.retrieveLocation(by: tag)
            locateOnce()
        case "showDASelctionVCFromHomeVC", "showDASelctionVCFromHomeVCNaN":
            tag = 0
            currentAddressTextField.isUserInteractionEnabled = false
            currentAddressNameTextField.isUserInteractionEnabled = false
            unwindSegueID = "unwindToHomeVCFromDASelectionVC"
            locationRealm = RealmHelper.retrieveLocation(by: tag)
            doPOIAroundSearch()
        default:
            break
        }

        relocateBtn.layer.borderColor = relocateBtn.currentTitleColor.cgColor
        relocateBtn.layer.borderWidth = 1
        relocateBtn.layer.cornerRadius = 3
        
        mapSearch.delegate = self
        
        cityTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        bakerDATableView.estimatedRowHeight = 64
        bakerDATableView.rowHeight = UITableViewAutomaticDimension
        bakerDATableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        tableView.estimatedRowHeight = 56
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        currentLocationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(currentLocationSelected(_:))))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
        hideCityTableView()
        hideHelperView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateCurrentLocationView()
        if let avbaker = self.avbaker {
            bakerDATableView.isHidden = false
            let query = AVAddress.query()
            query.includeKey("baker")
            query.whereKey("baker", equalTo: avbaker)
            query.findObjectsInBackground({
                objects, error in
                if let error = error {
                    // TODO: - error handling
                    printit("AVAddress error: \(error.localizedDescription)")
                } else {
                    if let addresses = objects as? [AVAddress] {
                        self.addresses = addresses
                        self.bakerDATableView.reloadData()
                    } else {
                        // TODO: - error handling
                    }
                }
            })
        } else {
            bakerDATableView.isHidden = true
        }
    }
    
    func currentLocationSelected(_ sender: Any) {
        if showSegueID == "showDeliveryAddressSelectionVCFromDAEditingVC" { return }
        if let regeocode = currentReGeocode {
            unwindFromCellSelection(by: regeocode)
        } else {
            fromCellSelection = true
            if let location = locationRealm {
                doReGeocode(with: CLLocation(latitude: CLLocationDegrees(location.latitude)!, longitude: CLLocationDegrees(location.longitude)!))
            } else {
                showHelperView(with: errorText)
            }
        }
    }
    
    func updateCurrentLocationView(by regeocode: AMapReGeocode? = nil) {
        if showSegueID == "showDASelctionVCFromHomeVCNaN" {
            currentCityLabel.text = "最近一次使用的地址："
        } else {
            currentCityLabel.text = "当前使用的地址："
        }
        if let regeocode = regeocode {
            cityBtn.setTitle(regeocode.addressComponent!.city, for: .normal)
            currentAddressNameTextField.text = regeocode.pois.first?.name
            currentAddressTextField.text = regeocode.pois.first?.address
        } else {
            if let location = locationRealm {
                cityBtn.setTitle(location.city, for: .normal)
                currentAddressNameTextField.text = location.aoiname + location.detailed
                currentAddressTextField.text = location.address
            } else {
                cityBtn.setTitle("火星", for: .normal)
                currentAddressNameTextField.text = ""
                currentAddressTextField.text = ""
            }
        }
        sizeToFitCityBtn()
    }
    
    func sizeToFitCityBtn() {
        cityBtn.sizeToFit()
        searchBar.frame.origin.x = 24 + cityBtn.frame.width
        searchBar.frame.size.width = cancelBtn.frame.origin.x - searchBar.frame.origin.x
    }
    
    class func instantiateFromStoryboard() -> DeliveryAddressSelectionVC {
        return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: self)) as! DeliveryAddressSelectionVC
    }

    @IBAction func relocateBtnPressed(_ sender: Any) {
        shouldSearchAround = true
        showHelperView(with: locatingText)
        hideCityTableView()
        locateOnce()
    }
    
    @IBAction func cityBtnPressed(_ sender: Any) {
        cityTableView.isHidden ? showCityTableView() : hideCityTableView()
    }
    
    func showCityTableView() {
        cityTableView.isHidden = false
        bakerDATableView.isHidden = true
        hideHelperView()
    }
    
    func hideCityTableView() {
        cityTableView.isHidden = true
    }
    
    func showHelperView(with text: String) {
        helperView.isHidden = false
        helperLabel.text = text
    }
    
    func hideHelperView() {
        helperView.isHidden = true
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else { return }
        switch id {
        case "unwindToDeliveryAddressEditingVCFromDASelectionVC":
            navigationController?.setNavigationBarHidden(false, animated: true)
            guard let vc = segue.destination as? DeliveryAddressEditingVC else { break }
            vc.selectedPOI = self.selectedPOI
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
            self.hideHelperView()
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
    
    
    func onReGeocodeSearchDone(_ request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        self.hideHelperView()
        guard let regeocode = response.regeocode else {
            // TODO: - no results
            
            return
        }
        currentReGeocode = regeocode
        if fromCellSelection {
            unwindFromCellSelection(by: regeocode)
        } else {
            if tag == 1 {
                self.locationRealm = RealmHelper.addLocation(by: regeocode, poi: selectedPOI, for: tag)
            }
            self.showHelperView(with: searchingText)
            self.updateCurrentLocationView(by: regeocode)
            self.doPOIAroundSearch(by: regeocode)
        }
    }
    
    func unwindFromCellSelection(by regeocode: AMapReGeocode) {
        self.locationRealm = RealmHelper.addLocation(by: regeocode, poi: selectedPOI, for: tag)
        self.updateCurrentLocationView()
        self.performSegue(withIdentifier: unwindSegueID, sender: self)
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
    
    private func doPOIAroundSearch(by regeocode: AMapReGeocode? = nil) {
        bakerDATableView.isHidden = true
        hideCityTableView()
        let request = AMapPOIAroundSearchRequest()
        if let location = regeocode?.pois.first?.location {
            request.location = location
        } else {
            if let location = locationRealm {
                request.location = AMapGeoPoint.location(withLatitude: CGFloat(Double(location.latitude)!), longitude: CGFloat(Double(location.longitude)!))
            }
        }
        request.requireExtension = true
        request.keywords = searchBar.text!
        
        mapSearch.cancelAllRequests()
        mapSearch.aMapPOIAroundSearch(request)
        
        showHelperView(with: searchingText)
    }
    
    private func doPOIKeywordSearch() {
        bakerDATableView.isHidden = true
        hideCityTableView()
        let request = AMapPOIKeywordsSearchRequest()
        request.requireExtension = true
        request.keywords = searchBar.text!
        request.city = cityBtn.title(for: .normal)
        
        mapSearch.cancelAllRequests()
        mapSearch.aMapPOIKeywordsSearch(request)
        
        showHelperView(with: searchingText)
    }
    
    
    // MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        switch tableView.tag {
        case 0:
            return 1
        case 1:
            return provs.count
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case 0:
            return pois.count
        case 1:
            return cities[provs[section]]!.count
        case 2:
            return addresses == nil ? 0 : addresses.count
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
            let cell = UITableViewCell()
            cell.textLabel?.text = cities[provs[section]]![row].removeNumbers()
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "deliveryAddressTableViewCell", for: indexPath) as! DeliveryAddressTableViewCell
            let addr = addresses[row]
            let township = addr.township ?? ""
            let streetName = addr.streetName ?? ""
            let streetNo = addr.streetNumber ?? ""
            let aoiName = addr.aoiName ?? ""
            let addrDetailed = addr.detailed ?? ""
            let addrAddr = township + streetName + streetNo + aoiName
            let addrProv = addr.province ?? ""
            let addrCity = addr.city ?? ""
            let addrDistrict = addr.district ?? ""
            let addrText = addrAddr + addrDetailed + " " + addrProv + addrCity + addrDistrict
            
            // dynamic set the text, set number of lines
            cell.addressLabel.text = addrAddr + addrDetailed
            var labelHeight = lroundf(Float(cell.addressLabel.sizeThatFits(CGSize(width: screenWidth - 15 * 2, height: CGFloat.infinity)).height))
            let charHeight = lroundf(Float(cell.addressLabel.font.lineHeight))
            if labelHeight / charHeight == 1 {
                cell.addressLabel.text = addrText
                labelHeight = lroundf(Float(cell.addressLabel.sizeThatFits(CGSize(width: screenWidth - 15 * 2, height: CGFloat.infinity)).height))
                if labelHeight / charHeight > 1 {
                    cell.addressLabel.text = addrAddr + addrDetailed + "\n" + addrProv + addrCity + addrDistrict
                }
            } else {
                cell.addressLabel.text = addrText
            }
            
            cell.address = addr
            cell.nameLabel.text = addr.name
            cell.phoneLabel.text = addr.phone
            return cell
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
            shouldSearchAround = true
            doReGeocode(with: amapGeoPointToCLLocation(selectedPOI!.location))
        case 1:
            guard let cell = tableView.cellForRow(at: indexPath) else { break }
            guard let city = cell.textLabel?.text else { break }
            cityBtn.setTitle(city, for: .normal)
            sizeToFitCityBtn()
            shouldSearchAround = false
            hideCityTableView()
            doPOIKeywordSearch()
            tableView.deselectRow(at: indexPath, animated: true)
        case 2:
            guard let cell = tableView.cellForRow(at: indexPath) as? DeliveryAddressTableViewCell else { break }
            cityBtn.setTitle(cell.address.city, for: .normal)
            selectedPOI = nil
            locationRealm = RealmHelper.addLocation(by: cell.address, for: tag)
            performSegue(withIdentifier: unwindSegueID, sender: self)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableView.tag == 1 ? provs[section].removeNumbers() : nil
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - SearchBar
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        shouldSearchAround ? doPOIAroundSearch() : doPOIKeywordSearch()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}
