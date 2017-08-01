//
//  MeInfoVC.swift
//  BAKESF
//
//  Created by 高宇超 on 7/5/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

class MeInfoVC: UIViewController {

    var navigationDelegate: NavigationControllerDelegate?
    let edgePanGestrue = UIScreenEdgePanGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //edgePanGestrue.edges = .left
        //edgePanGestrue.addTarget(self, action: #selector(MeSettingVC.panGestureToMeFromSetting(_:)))
        //view.addGestureRecognizer(edgePanGestrue)
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    @IBAction func panGestureToMeFromSetting(_ sender: UIScreenEdgePanGestureRecognizer) {
        let translationX = sender.translation(in: view).x
        let translationBase: CGFloat = view.frame.width
        let translationAbs = translationX > 0 ? translationX : -translationX
        let percent = translationAbs > translationBase ? 1.0 : translationAbs / translationBase
        
        switch sender.state {
        case .began:
            navigationDelegate = self.navigationController?.delegate as? NavigationControllerDelegate
            navigationDelegate?.interactive = true
            self.performSegue(withIdentifier: "unwindToMeFromInfo", sender: sender)
        case .changed:
            navigationDelegate?.interactionController.update(percent)
        case .cancelled, .ended:
            // if the half of the view is dismissed or the x velocity is very large
            if percent > 0.5 || sender.velocity(in: view!).x > 1000 {
                navigationDelegate?.interactionController.finish()
            } else {
                navigationDelegate?.interactionController.cancel()
            }
            navigationDelegate?.interactive = false
        default:
            break
        }
    }

}
