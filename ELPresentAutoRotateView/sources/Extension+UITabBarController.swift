//
//  WeiboPicsViewerTabBarController.swift
//  WeiboPicsViewer
//
//  Created by 陈建立 on 16/12/1.
//  Copyright © 2016年 陈建立. All rights reserved.
//

import UIKit

extension UITabBarController {

    open override var shouldAutorotate : Bool {
        return selectedViewController?.shouldAutorotate ?? super.shouldAutorotate
    }

    override open var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return selectedViewController?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
    }

    open override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return selectedViewController?.preferredInterfaceOrientationForPresentation ?? super.preferredInterfaceOrientationForPresentation
    }

}
