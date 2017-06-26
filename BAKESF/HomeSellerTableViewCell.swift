//
//  homeSellerTableViewCell.swift
//  BAKESF
//
//  Created by 高宇超 on 5/21/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

class HomeSellerTableViewCell: UITableViewCell, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var followBlurView: UIVisualEffectView!
    @IBOutlet weak var headphoto: UIImageView!
    @IBOutlet weak var commentsNumber: UIButton!
    @IBOutlet weak var whiteFiveStars: UIImageView!
    
    var picker: UIImagePickerController = UIImagePickerController()
    var rootVC: UIViewController!
    
    @IBAction func followBtnPressed(_ sender: UIButton) {
        
        // openGallary() : - Test photo gallary
        
    }
    
    @IBAction func commentNumberBtnPressed(_ sender: Any) {
    }
    

    func vcInit() {
        picker.delegate = self
        
        rootVC = self.window!.rootViewController!
    }

    func openCamera() {
        
        vcInit()
        
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            picker.sourceType = UIImagePickerControllerSourceType.camera
            rootVC.present(picker, animated: true, completion: nil)
        } else {
            openGallary()
        }
    }
    
    func openGallary() {
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        if UIDevice.current.userInterfaceIdiom == .phone {
            rootVC.present(picker, animated: true, completion: nil)
        } else {
            print("device: \(UIDevice.current.userInterfaceIdiom)")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let img = info[UIImagePickerControllerOriginalImage] as? UIImage {
        
            bgImage.image = img
            bgImage.image?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .tile)
            
            let fileManager = FileManager.default
            let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            let docDir = urls[0] as NSURL
            
            print()
            print(docDir)
            
            let currentDate = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .none
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let convertedDate = dateFormatter.string(from: currentDate)
            let imageURL = docDir.appendingPathComponent(convertedDate)!
            let path = imageURL.path
            
            print()
            print(path)
            
            let url = info[UIImagePickerControllerReferenceURL] as! URL
            print(url.absoluteString)
            
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("picker did cancel")
    }
    
}
