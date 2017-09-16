//
//  MeFavoriteVC.swift
//  BAKESF
//
//  Created by 高宇超 on 9/16/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

class MeFavoriteVC: UIViewController {

    
    var avbaker: AVBaker?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    

    class func instantiateFromStoryboard() -> MeFavoriteVC {
        return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: self)) as! MeFavoriteVC
    }
    


    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
