//
//  WeiboPicsViewerNavController.swift
//  WeiboPicsViewer
//
//  Created by 陈建立 on 16/12/1.
//  Copyright © 2016年 陈建立. All rights reserved.
//

import UIKit

extension UINavigationController {

    override open var shouldAutorotate : Bool {
        return topViewController?.shouldAutorotate ?? super.shouldAutorotate
    }

    override open var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return topViewController?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
    } 

    open override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return topViewController?.preferredInterfaceOrientationForPresentation ?? super.preferredInterfaceOrientationForPresentation
    }
}
