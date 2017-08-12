//
//  FancyNavigationControllerDelegate.swift
//  BAKESF
//
//  Created by 高宇超 on 7/4/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit

class FancyNavigationControllerDelegate: NSObject, UINavigationControllerDelegate {

    var interactive = false
    let interactionController = UIPercentDrivenInteractiveTransition()
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transitionType = SDETransitionType.navigationTransition(operation)
        return FancyTransitionAnimator(type: transitionType)
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactive ? self.interactionController : nil
    }
    
}
