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

class MeVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var headphoto: UIButton!
    @IBOutlet weak var settingBtn: UIButton!
    @IBOutlet weak var tweetsBtn: UIButton!
    @IBOutlet weak var followeeBtn: UIButton!
    @IBOutlet weak var followerBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var editInfoBtn: UIButton!
    @IBOutlet weak var editBtnBg: UIButton!

    var user: UserRealm!
    var avbaker: AVBaker!
    
    var picker: UIImagePickerController = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        

        vcInit()
        
        navigationController?.navigationBar.barTintColor = .bkRed
        navigationController?.navigationBar.tintColor = .white
        
        
        
        /* Paging Menu
        // page menu 
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
         */

    }

    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.title = "个人主页"
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
        self.tabBarController?.tabBar.isHidden = true
        self.tabBarController?.tabBar.frame.origin.y = screenHeight
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            switch id {
            case "showLogin":
                let sourceVC = segue.source
                sourceVC.navigationController?.interactivePopGestureRecognizer?.delegate = self
                sourceVC.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

                guard let loginVC = segue.destination as? MeLoginVC else { break }
                loginVC.showSegueID = id
            case "showSettingFromMeVC":
                setBackItemTitle(for: navigationItem)
                guard let settingVC = segue.destination as? MeSettingVC else { break }
                settingVC.avbaker = self.avbaker
            case "showInfoFromMeVC":
                setBackItemTitle(for: navigationItem)
                guard let infoVC = segue.destination as? MeInfoVC else { break }
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
                            _ = RealmHelper.setCurrentUser(baker: self.avbaker, data: data)
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
    
    
    func vcInit() {
        picker.delegate = self
        headphoto.layer.cornerRadius = headphoto.frame.width / 2
        headphoto.layer.masksToBounds = true
        loginBtn.setBorder(with: .bkBlack)
        likeBtn.setBorder(with: .bkBlack)
        editInfoBtn.setBorder(with: .bkBlack)
        editBtnBg.layer.masksToBounds = true
        editBtnBg.layer.cornerRadius = 8
        editBtnBg.backgroundColor = .bkWhite
        editBtnBg.alpha = 0.88
        view.bringSubview(toFront: editBtn)
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
                self.avbaker.headphoto = file.url!
                self.avbaker.setObject(file.url!, forKey: "headphoto")
                self.avbaker.saveInBackground({
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

    func checkCurrentUser() {
        if let usr = RealmHelper.retrieveCurrentUser() {
            setupViewsAfterChecking(loggedin: true)
            user = usr
            self.title = "\(usr.name)"
            avbaker = retrieveBaker(withID: usr.id)
            if let data = usr.headphoto {
                let img = UIImage(data: data)?.cropAndResize(width: self.headphoto.frame.width, height: self.headphoto.frame.height)
                self.headphoto.setImage(img?.fixOrientation(), for: .normal)
            }
        } else {
            setupLogout()
        }
    }
    
    func setupLogout() {
        setupViewsAfterChecking(loggedin: false)
        navigationController?.title = "个人主页"
        headphoto.setImage(UIImage(named: "巧克力布丁")!, for: .normal)
    }
    
    func setupViewsAfterChecking(loggedin: Bool) {
        editBtn.isHidden = !loggedin
        editBtnBg.isHidden = !loggedin
        editInfoBtn.isHidden = !loggedin
        loginBtn.isHidden = loggedin
    }
    
    
}

