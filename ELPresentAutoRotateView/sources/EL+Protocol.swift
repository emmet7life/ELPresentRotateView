//
//  AVPlayerRotateActionProtocol.swift
//  WeiboPicsViewer
//
//  Created by 陈建立 on 3/30/17.
//  Copyright © 2017 陈建立. All rights reserved.
//

import Foundation
import UIKit

// MARK: - 跟视频播放器有关的一些状态枚举
public enum ELPresentRotateViewPlayState: Int {
    case initiate, playing, pause, resume, stop
}

public enum ELPresentRotateViewTransformingState {
    case beforePresent, afterPresent, beforeDismiss, afterDismiss
}

// MARK: - 本协议实际上是用来规定ELPresentRotateView行为的协议
public protocol ELPresentRotateViewProtocol: class {

    // MARK: - 旋转容器视图
    var presentRotateView: UIView? { get }// 实现本协议的视图本身

    // MARK: - 变换过程中需要用到的视图及视图控制器属性
    var presentingController: UIViewController? { get }
    var presentedController: ELPresentRotateViewControllerProtocol? { get }// 返回一个UIViewController，并且该Controller应该满足ELPresentRotateViewControllerProtocol协议

    var presentingControllerTargetSuperview: UIView? { get }
    var presentedControllerTargetSuperview: UIView? { get }

    // MARK: - 状态属性
    var playState: ELPresentRotateViewPlayState { get }// 视图简单维护了一个播放状态信息，使用者可以不使用而使用自己定义的属性来控制
    var isFullScreen: Bool { get }

    // MARK: - 重置状态
    func resetViewState()

    // MARK: - 点击行为
    func onPresentRotateViewPlayControlBtnTapped()
    func onPresentRotateViewRotateControlBtnTapped()

    // MARK: - 绑定和注销行为
    var delegate: ELPresentRotateViewDelegate? { get set }
    func register(_ presentingController: UIViewController?, delegate: ELPresentRotateViewDelegate?)
    func unregister()

    // MARK: - 变换执行过程中使用的属性和方法
    func presentControl(with controller: ELPresentRotateViewControllerProtocol, containerView: UIView, controllerView: UIView, completion: @escaping () -> ())
    func dismissControl(with controller: ELPresentRotateViewControllerProtocol, containerView: UIView, controllerView: UIView, completion: @escaping () -> ())
}

// MARK: - 用来规定播放器视图被present出来的那个Controller该有什么样的属性和行为，使用方式有两种：
// 1.本库实现了一个基本通用Controller，使用者如果无特殊情况下可直接通过继承BasicELPresentRotateViewController来使用。
// 2.自己实现ELPresentRotateViewControllerProtocol协议，不过要照着BasicELPresentRotateViewController实现相应的方法和配置必要的参数，
// 例如设置transitioningDelegate，重写诸如preferredInterfaceOrientationForPresentation/shouldAutorotate/supportedInterfaceOrientations等对横屏的约束方法，
// 实现自定义转场过渡协议UIViewControllerTransitioningDelegate并使用Transition类等。
public protocol ELPresentRotateViewControllerProtocol: class {

    // properties
    var presentRotateViewController: UIViewController? { get }
    var transiton: Transition { get set }
    var presentRotateView: ELPresentRotateViewProtocol? { get set }
    var preferredInterfaceOrientation: UIInterfaceOrientation { get set }

    // init
    init(_ presentRotateView: ELPresentRotateViewProtocol)

    // func: 在适当的时机通知Controller
    func beforePresent()
    func afterPresent()
    func beforeDismiss()
    func afterDismiss()
}

extension ELPresentRotateViewControllerProtocol {
    public func beforePresent() { print("extension ELPresentRotateViewControllerProtocol >> default implements >> beforePresent()") }
    public func afterPresent() { print("extension ELPresentRotateViewControllerProtocol >> default implements >> afterPresent()") }
    public func beforeDismiss() { print("extension ELPresentRotateViewControllerProtocol >> default implements >> beforeDismiss()") }
    public func afterDismiss() { print("extension ELPresentRotateViewControllerProtocol >> default implements >> afterDismiss()") }
}

// MARK: - 容器视图与外部(如某UITableViewCell/UICollectionViewCell)的交互协议
public protocol ELPresentRotateViewDelegate: class {
    func presentRotateView(_ containerView: UIView, viewStateChanged state: ELPresentRotateViewPlayState)
    func presentRotateViewGeneratePresentedController(_ containerView: UIView) -> UIViewController?

    func presentRotateView(beforePresent containerView: UIView)
    func presentRotateView(afterPresent containerView: UIView)
    func presentRotateView(beforeDismiss containerView: UIView)
    func presentRotateView(afterDismiss containerView: UIView)

    func presentRotateView(presentAnimating containerView: UIView, presentedSuperView: UIView?)
    func presentRotateView(dismissAnimating containerView: UIView, presentingSuperView: UIView?)
}

extension ELPresentRotateViewDelegate {
    func presentRotateViewGeneratePresentedController(_ containerView: UIView) -> UIViewController? {
        print("extension ELPresentRotateViewDelegate >> default implements >> presentRotateViewGeneratePresentedController(_:) return nil")
        return nil
    }
    func presentRotateView(_ containerView: UIView, viewStateChanged state: ELPresentRotateViewPlayState) {
        print("extension ELPresentRotateViewDelegate >> default implements >> presentRotateView(_:viewStateChanged:)")
    }

    func presentRotateView(beforePresent containerView: UIView) { print("extension ELPresentRotateViewDelegate >> default implements >> presentRotateView(beforePresent:)") }
    func presentRotateView(afterPresent containerView: UIView) { print("extension ELPresentRotateViewDelegate >> default implements >> presentRotateView(afterPresent:)") }
    func presentRotateView(beforeDismiss containerView: UIView) { print("extension ELPresentRotateViewDelegate >> default implements >> presentRotateView(beforeDismiss:)") }
    func presentRotateView(afterDismiss containerView: UIView) { print("extension ELPresentRotateViewDelegate >> default implements >> presentRotateView(afterDismiss:)") }

    func presentRotateView(presentAnimating containerView: UIView, presentedSuperView: UIView?) { print("extension ELPresentRotateViewDelegate >> default implements >> presentRotateView(presentAnimating:presentedSuperView:)") }
    func presentRotateView(dismissAnimating containerView: UIView, presentingSuperView: UIView?) { print("extension ELPresentRotateViewDelegate >> default implements >> presentRotateView(dismissAnimating:presentingSuperView:)") }
}
