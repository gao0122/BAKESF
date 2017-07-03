//
//  MeVC.swift
//  BAKESF
//
//  Created by 高宇超 on 5/16/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit
import PagingMenuController
import LeanCloud
import AVOSCloud

class MeVC: UIViewController, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var headphoto: UIButton!
    @IBOutlet weak var settingBtn: UIButton!
    @IBOutlet weak var followeeBtn: UIButton!
    @IBOutlet weak var followerBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!

    var user: UserRealm!
    
    var picker: UIImagePickerController = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let _ = checkCurrentUser()
        
        vcInit()
        
        // page menu 
        struct MeMemory: MenuItemViewCustomizable {
            var displayMode: MenuItemDisplayMode {
                return .text(title: MenuItemText(text: "回忆"))
            }
        }
        struct MeTweet: MenuItemViewCustomizable {
            var displayMode: MenuItemDisplayMode {
                return .text(title: MenuItemText(text: "推文"))
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
                return .underline(height: 3, color: UIColor.black, horizontalPadding: 10, verticalPadding: 0)
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

    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            switch id {
            case "showLogin":
                let sourceVC = segue.source
                sourceVC.navigationController?.interactivePopGestureRecognizer?.delegate = self
                sourceVC.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            case "unwindToMeFromLogin":
                userNameLabel.text = "欢迎 \(self.user.phone)"
            default:
                break
            }
        }
    }
    
    @IBAction func unwindToMeVC(segue: UIStoryboardSegue) {
        let _ = checkCurrentUser()
        
        if let id = segue.identifier {
            switch id {
            case "unwindToMeFromLogin":
                break
            case "unwindToMeFromSetting":
                break
            default:
                break
            }
        }
    }
    
    @IBAction func editBtnPressed(_ sender: Any) {
        let alertVC = UIAlertController(title: "编辑头像", message: "", preferredStyle: .actionSheet)
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
    func vcInit() {
        picker.delegate = self
    }
    
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
            bgImageView.image = img
            bgImageView.image?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .tile)
            
            if let data = UIImagePNGRepresentation(img) {
                saveImgToLC(data: data)
            } else if let data = UIImageJPEGRepresentation(img, 1) {
                saveImgToLC(data: data)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        print("picker did cancel")
    }
    
    
    func saveImgToLC(data: Data) {
        let file = AVFile(data: data)
        file.saveInBackground({
            succeed, error in
            if succeed {
                let usr = retrieveBaker(withPhone: self.user!.phone)!
                usr.headphoto = file
                usr.save {
                    result in
                    switch result {
                    case .success(let usr as LCBaker):
                        self.view.notify(text: "上传成功", color: .green)
                    case .failure(let error):
                        self.view.notify(text: "上传失败", color: .red)
                    default:
                        break
                    }
                }
                printit(any: file.url)
            } else {
                printit(any: error?.localizedDescription)
            }
        })
    }

    func checkCurrentUser() -> Bool {
        if let usr = RealmHelper.retrieveCurrentUser() {
            user = usr
            editBtn.isHidden = false
            loginBtn.isHidden = true
            userNameLabel.text = "\(user.name)"
            return true
        } else {
            editBtn.isHidden = true
            loginBtn.isHidden = false
            userNameLabel.text = ""
            return false
        }
    }
    
}

