//
//  BasicELPresentRotateViewController.swift
//  WeiboPicsViewer
//
//  Created by 陈建立 on 6/29/17.
//  Copyright © 2017 陈建立. All rights reserved.
//

import UIKit

open class BasicELPresentRotateViewController: UIViewController {

    // MARK: - ELPresentRotateViewControllerProtocol

    // 用于控制外部Controller present进来时的屏幕方向
    public var preferredInterfaceOrientation: UIInterfaceOrientation = .landscapeRight
    public var presentRotateView: ELPresentRotateViewProtocol?
    // 转场动画
    public var transiton = Transition()
    public weak var presentRotateViewController: UIViewController? {
        return self
    }

    // MARK: - Init
    public required init(_ presentRotateView: ELPresentRotateViewProtocol) {
        super.init(nibName: nil, bundle: nil)
        self.presentRotateView = presentRotateView
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // 使用Storyboard或者Xib时，会走此方法，但这时必须手动配置avplayerRotateView属性的值
        setup()
    }

    fileprivate func setup() {
        self.transitioningDelegate = self
        self.view.backgroundColor = UIColor.clear
    }

    deinit {
        print("BasicELPresentRotateViewController deinit >> 😄")
    }

    // MARK: - 控制状态栏和present时的屏幕方向

    // 下面两个方法可重写去自定义
    open override var prefersStatusBarHidden : Bool {
        return false
    }

    open override var preferredStatusBarUpdateAnimation : UIStatusBarAnimation {
        return UIStatusBarAnimation.none
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // 下面三个方法基本就不允许要重写了，因为下面三个方法实现了对present进入时的横屏模式约束和后续的横屏模式约束行为
    open override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return preferredInterfaceOrientation
    }

    open override var shouldAutorotate : Bool {
        return true
    }

    open override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }
}

extension BasicELPresentRotateViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transiton.transitonType = .present
        return transiton
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transiton.transitonType = .dismiss
        return transiton
    }
}

extension BasicELPresentRotateViewController: ELPresentRotateViewControllerProtocol {

}
