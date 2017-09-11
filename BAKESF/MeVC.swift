//
//  MeVC.swift
//  BAKESF
//
//  Created by 高宇超 on 5/16/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit
import PagingMenuController
import AVOSCloud
import Crashlytics

class MeVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var bakerView: UIView!
    @IBOutlet weak var loginBtn0: UIButton! // currently using
    @IBOutlet weak var loginBtn: UIButton! // enabled when community is open
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var headphoto: UIButton!
    @IBOutlet weak var settingBtn: UIButton!
    @IBOutlet weak var tweetsBtn: UIButton!
    @IBOutlet weak var followeeBtn: UIButton!
    @IBOutlet weak var followerBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var editBtnBg: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var rightArrowLabel: UILabel!
    @IBOutlet weak var settingTableView: UITableView!

    
    var user: UserRealm!
    var avbaker: AVBaker?
    
    var picker: UIImagePickerController = UIImagePickerController()

    var settingDict: [Int: [Int: String]] = {
        return [
            0: [0: "我的红包",
                1: "我的地址",
                2: "我的收藏"],
            1: [0: "私房入驻",
                1: "给个好评",
                2: "服务中心"]
        ]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        vcInit()
        
        // page menu
        //pageMenuInit()
 
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkCurrentUser()
        guard let tabBarController = self.tabBarController else { return }
        tabBarController.tabBar.isHidden = false
        let duration: TimeInterval = animated ? 0.17 : 0
        UIView.animate(withDuration: duration, animations: {
            tabBarController.tabBar.frame.origin.y = screenHeight - tabBarController.tabBar.frame.height
        }, completion: {
            _ in
            tabBarController.tabBar.frame.origin.y = screenHeight - tabBarController.tabBar.frame.height
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func vcInit() {
        picker.delegate = self
        headphoto.layer.cornerRadius = headphoto.frame.width / 2
        headphoto.layer.masksToBounds = true
        loginBtn.setBorder(with: .bkBlack)
        likeBtn.setBorder(with: .bkBlack)
        editBtnBg.layer.masksToBounds = true
        editBtnBg.layer.cornerRadius = 8
        editBtnBg.backgroundColor = .bkWhite
        editBtnBg.alpha = 0.88
        view.bringSubview(toFront: editBtn)
        navigationController?.navigationBar.barTintColor = .bkRed
        navigationController?.navigationBar.tintColor = .white
        bakerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MeVC.bakerViewTapped(_:))))
        let tableHeaderFooterView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 17))
        tableHeaderFooterView.backgroundColor = UIColor(hex: 0xF7F7F7)
        settingTableView.tableHeaderView = tableHeaderFooterView
        settingTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 50))
    }

    func bakerViewTapped(_ sender: Any) {
        if let _ = avbaker {
            performSegue(withIdentifier: "showInfoEditingFromMe", sender: sender)
        } else {
            performSegue(withIdentifier: "showLogin", sender: sender)
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            switch id {
            case "showLogin":
                guard let loginVC = segue.destination as? MeLoginVC else { break }
                setBackItemTitle(for: navigationItem)
                loginVC.showSegueID = id
            case "showSettingFromMeVC":
                guard let settingVC = segue.destination as? MeSettingVC else { break }
                setBackItemTitle(for: navigationItem)
                settingVC.avbaker = self.avbaker
            case "showInfoEditingFromMe":
                guard let infoVC = segue.destination as? MeInfoVC else { break }
                setBackItemTitle(for: navigationItem)
                infoVC.avbaker = self.avbaker
            default:
                break
            }
        }
    }
    
    @IBAction func unwindToMeVC(segue: UIStoryboardSegue) {
        checkCurrentUser()
        
        if let id = segue.identifier {
            switch id {
            case "unwindToMeFromLogin":
                break
            case "unwindToMeFromSetting":
                break
            case "unwindToMeFromInfo":
                break
            default:
                break
            }
        }
    }
    
    @IBAction func headphotoTapped(_ sender: Any) {
        if user != nil {
            guard let avbaker = avbaker else { return }
            if avbaker.headphoto == user.headphotoURL { return }
            let fileQuery = AVFileQuery(className: "_File")
            fileQuery.whereKey(lcKey[.url]!, equalTo: avbaker.headphoto!)
            fileQuery.findFilesInBackground({
                objects, error in
                if error == nil {
                    if let file = objects?.first as? AVFile {
                        if let data = file.getData() {
                            let data = UIImage(data: data)?.cropAndResize(width: 150, height: 150).imageData
                            let img = UIImage(data: data!)?.cropAndResize(width: self.headphoto.frame.width, height: self.headphoto.frame.height)
                            self.headphoto.setImage(img?.fixOrientation(), for: .normal)
                            _ = RealmHelper.setCurrentUser(baker: self.avbaker!, data: data)
                        }
                    }
                }
            })
        }
    }

    @IBAction func editBtnPressed(_ sender: Any) {
        let alertVC = UIAlertController(title: "", message: "编辑头像", preferredStyle: .actionSheet)
        let cameraAct = UIAlertAction(title: "打开相机", style: .default, handler: {
            _ in
            self.openCamera()
        })
        let gallaryAct = UIAlertAction(title: "打开相册", style: .default, handler: {
            _ in
            self.openGallary()
        })
        let cancelAct = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertVC.addAction(cameraAct)
        alertVC.addAction(gallaryAct)
        alertVC.addAction(cancelAct)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    
    // MARK: - Image Picker
    func openCamera() {
        if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
            picker.sourceType = .camera
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    func openGallary() {
        picker.sourceType = .photoLibrary
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.present(picker, animated: true, completion: nil)
        } else {
            print("device: \(UIDevice.current.userInterfaceIdiom)")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)

        if let img = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if let data = img.fixOrientation().imageData {
                saveImgToLC(data: data, img: img.fixOrientation())
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func deleteOriginHeadphoto(url urlToDelete: String) {
        let query = AVFileQuery(className: "_File")
        query.whereKey(lcKey[.url]!, equalTo: urlToDelete)
        query.findFilesInBackground({
            result, error in
            if error == nil {
                if let obj = result?.first {
                    let file = obj as! AVFile
                    file.deleteInBackground({
                        succeeded, error in
                        if succeeded {
                        } else {
                        }
                    })
                }
            }
        })
    }
    
    func saveImgToLC(data: Data, img: UIImage) {
        guard let _ = self.avbaker else { return }
        guard let urlToDelete = user.headphotoURL else { return }
        let scaledImg = img.cropAndResize(width: headphoto.frame.width, height: headphoto.frame.height)
        let file = AVFile(data: data)
        let width = self.view.frame.width
        let progressView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 3))
        progressView.backgroundColor = .bkWhite
        self.view.addSubview(progressView)
        self.view.bringSubview(toFront: progressView)
        file.saveInBackground({
            succeeded, error in
            if succeeded {
                RealmHelper.saveHeadphoto(user: self.user, data: scaledImg.imageData!, url: file.url!)
                self.avbaker!.headphoto = file.url!
                self.avbaker!.setObject(file.url!, forKey: "headphoto")
                self.avbaker!.saveInBackground({
                    succeeded, error in
                    if succeeded {
                        self.headphoto.setImage(scaledImg, for: .normal)
                        self.deleteOriginHeadphoto(url: urlToDelete)
                        self.view.notify(text: "修改成功", color: UIColor.alertGreen, nav: self.navigationController?.navigationBar)
                    } else {
                        self.view.notify(text: "上传失败", color: .alertRed, nav: self.navigationController?.navigationBar)
                        Answers.logCustomEvent(withName: "上传头像失败", customAttributes: ["phone": self.user.phone, "error": error!.localizedDescription])
                        printit(any: error!.localizedDescription)
                    }
                })
            } else {
                self.view.notify(text: "上传失败", color: .alertRed, nav: self.navigationController?.navigationBar)
                Answers.logCustomEvent(withName: "上传头像失败", customAttributes: ["phone": self.user.phone, "error": error!.localizedDescription])
                printit(any: error!.localizedDescription)
            }
            progressView.removeFromSuperview()
            self.view.isUserInteractionEnabled = true
        }, progressBlock: {
            percent in
            self.view.isUserInteractionEnabled = false
            progressView.frame.size.width = width * CGFloat(percent) / 100
        })
    }
    
    
    // MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingDict.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let dict = settingDict[section] {
            return dict.count + 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        if let text = settingDict[section]?[row] {
            let cell = UITableViewCell.btnCell(with: text)
            if row + 1 == settingDict[section]?.count {
                cell.separatorInset.left = screenWidth
            }
            return cell
        } else {
            return UITableViewCell.separatorCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        let row = indexPath.row
        if let _ = settingDict[section]?[row] {
            return 50
        } else {
            return 17
        }
    }
    
    
    // MARK: - functions
    func checkCurrentUser() {
        if let usr = RealmHelper.retrieveCurrentUser() {
            if let avbaker = retrieveBaker(withID: usr.id) {
                self.avbaker = avbaker
                setupViewsAfterChecking(loggedin: true)
                user = usr
                userNameLabel.text = usr.name
                if let data = usr.headphoto {
                    let img = UIImage(data: data)?.cropAndResize(width: self.headphoto.frame.width, height: self.headphoto.frame.height)
                    self.headphoto.setImage(img?.fixOrientation(), for: .normal)
                }
            } else {
                setupLogout(usr: usr)
            }
        } else {
            setupLogout()
        }
    }
    
    func setupLogout(usr: UserRealm? = nil) {
        if let usr = usr {
            RealmHelper.logoutCurrentUser(user: usr)
        }
        user = nil
        avbaker = nil
        setupViewsAfterChecking(loggedin: false)
        headphoto.setImage(UIImage(named: "巧克力布丁")!, for: .normal)
    }
    
    func setupViewsAfterChecking(loggedin: Bool) {
        editBtn.isHidden = !loggedin
        editBtnBg.isHidden = !loggedin
        userNameLabel.isHidden = !loggedin
        loginBtn.isHidden = loggedin
        loginBtn0.isHidden = loggedin
    }
    
    
    func pageMenuInit() {
        struct MeMemory: MenuItemViewCustomizable {
            var displayMode: MenuItemDisplayMode {
                return .text(title: MenuItemText(text: "回忆", selectedColor: UIColor.red))
            }
        }
        struct MeTweet: MenuItemViewCustomizable {
            var displayMode: MenuItemDisplayMode {
                return .text(title: MenuItemText(text: "推文", selectedColor: UIColor.red))
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
                return .none //underline(height: 3, color: UIColor.red, horizontalPadding: 10, verticalPadding: 0)
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
    
}

