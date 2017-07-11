//
//  UIPanDirectionGestureRecognizer.swift
//  BAKESF
//
//  Created by 高宇超 on 7/11/17.
//  Copyright © 2017 Yuchao. All rights reserved.
//

import UIKit.UIGestureRecognizerSubclass

enum PanDirection {
    case vertical
    case horizontal
}

class UIPanDirectionGestureRecognizer: UIPanGestureRecognizer {
    let direction: PanDirection
    
    init(direction: PanDirection, target: AnyObject, action: Selector) {
        self.direction = direction
        super.init(target: target, action: action)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        if state == .began {
            let v = velocity(in: view)
            switch direction {
            case .horizontal where fabs(v.y) > fabs(v.x):
                state = .cancelled
            case .vertical where fabs(v.x) > fabs(v.y):
                state = .cancelled
            default:
                break
            }
        }
    }
}
