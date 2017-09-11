//
//  CommunityVC.swift
//  BAKESF
//
//  Created by 高宇超 on 6/27/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

class CommunityVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
