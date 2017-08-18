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

enum PanDirectionD {
    case leftOrUp
    case rightOrDown
    case all
}

class UIPanDirectionGestureRecognizer: UIPanGestureRecognizer {
    let direction: PanDirection
    let pdd: PanDirectionD
    
    init(direction: PanDirection, pdd: PanDirectionD = .all, target: AnyObject, action: Selector) {
        self.direction = direction
        self.pdd = pdd
        super.init(target: target, action: action)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        if state == .began {
            let v = velocity(in: view)
            switch direction {
            case .horizontal where fabs(v.y) > fabs(v.x):
                state = .cancelled
            case .horizontal where fabs(v.y) < fabs(v.x):
                switch pdd {
                case .leftOrUp where v.x > 0:
                    state = .cancelled
                case .rightOrDown where v.x < 0:
                    state = .cancelled
                default:
                    break
                }
            case .vertical where fabs(v.x) > fabs(v.y):
                state = .cancelled
            case .vertical where fabs(v.x) < fabs(v.y):
                switch pdd {
                case .leftOrUp where v.y > 0:
                    state = .cancelled
                case .rightOrDown where v.y < 0:
                    state = .cancelled
                default:
                    break
                }
            default:
                break
            }
        }
    }
    
    
}
