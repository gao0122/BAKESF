//
//  Extensions.swift
//  BAKESF
//
//  Created by 高宇超 on 6/25/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import Foundation
import UIKit
import LeanCloud

public var notifying: Bool = false

func printit(any: Any) {
    print()
    print("------------------------------")
    print(any)
    print("------------------------------")
}


// MARK: - UIView
//
extension UIView {
    
    func notify(text: String, color: BKColor, duration: TimeInterval = 1.98) {
        if !notifying {
            notifying = true
            let notifyHeight: CGFloat = 64
            let label = UILabel()
            label.restorationIdentifier = "notifyLabel"
            label.frame.size = CGSize(width: self.frame.width, height: notifyHeight)
            label.frame.origin = CGPoint(x: 0, y: -notifyHeight)
            label.font = UIFont.init(name: ".SFUIText-Light", size: 15)
            label.numberOfLines = 2
            label.text = "\n\(text)"
            label.textColor = color == .white ? colors[.black] : colors[.white]
            label.textAlignment = .center
            label.alpha = 0.4
            label.backgroundColor = colors[color]
            self.addSubview(label)
            self.bringSubview(toFront: label)
            UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseInOut], animations: {
                label.frame.origin.y = 0
                label.alpha = 1
            }, completion: {
                finished in
                UIView.animate(withDuration: 0.18, delay: duration, options: [.curveEaseInOut], animations: {
                    label.frame.origin.y = -notifyHeight
                    label.alpha = 0.4
                }, completion: {
                    finished in
                    label.removeFromSuperview()
                    notifying = false
                })
            })
        }
    }
    
}


// MARK: - UIViewController
extension UIViewController {
    
    func alertOkayOrNot(title: String = "", okTitle: String, notTitle: String, msg: String, okAct: @escaping (UIAlertAction) -> Void, notAct: @escaping (UIAlertAction) -> Void) {
        
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: okTitle, style: .default, handler: okAct)
        let cancelAction = UIAlertAction(title: notTitle, style: .cancel, handler: notAct)
        alertController.addAction(okayAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}


// MARK: - String
extension String {
    
    func substring(from: Int, to: Int) -> String {
        if to > characters.count || from >= to { return "" }
        let fromIndex = self.index(startIndex, offsetBy: from)
        let toIndex = self.index(startIndex, offsetBy: to)
        return substring(with: fromIndex..<toIndex)
    }
    
}


// MARK: - Data 
extension Data {
    
    var imageFormat: ImageFormat {
        var buffer = [UInt8](repeatElement(0, count: 1))
        self.copyBytes(to: &buffer, from: NSRange(location: 0, length: 0).toRange()!)
        if buffer == ImageHeaderData.png {
            return .png
        } else if buffer == ImageHeaderData.jpeg {
            return .jpeg
        } else if buffer == ImageHeaderData.gif {
            return .gif
        } else if buffer == ImageHeaderData.tiff01 || buffer == ImageHeaderData.tiff02 {
            return .tiff
        } else {
            return .unknown
        }
    }
    
}


// MARK: - Date
extension Date {
    
    func seconds(fromDate from: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: from, to: self).second ?? 0
    }
    
}


// MARK: - UIImage
extension UIImage {
    
    var imageData: Data? {
        return UIImagePNGRepresentation(self) ?? UIImageJPEGRepresentation(self, 1)
    }
    
    func cropToBounds(width: CGFloat, height: CGFloat) -> UIImage {
        let contextImage: UIImage = UIImage(cgImage: self.cgImage!)
        
        let contextSize: CGSize = contextImage.size
        
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = width
        var cgheight: CGFloat = height
        
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        
        return image
    }
    
    func resize(width: CGFloat, height: CGFloat) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func cropAndResize(width: CGFloat, height: CGFloat) -> UIImage {
        let len = size.width > size.height ? size.height : size.width
        return cropToBounds(width: len, height: len).resize(width: width, height: height)
    }
    
}
