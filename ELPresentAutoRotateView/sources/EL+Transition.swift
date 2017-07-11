//
//  Transition+WeiboPicsViewer+Major.swift
//  WeiboPicsViewer
//
//  Created by 陈建立 on 16/12/3.
//  Copyright © 2016年 陈建立. All rights reserved.
//

import UIKit

// MARK: TransitionStype
// Present->Dismiss，Push->Pop必须一一对应使用，不然可能效果达不到
public enum TransitionStype: Int {
    // Present View Controller
    case present
    case dismiss
    // Use NavigationController Push and Pop
    case push
    case pop
}

open class Transition: NSObject, UIViewControllerAnimatedTransitioning {

    // 记录上一次的有效屏幕方向，屏蔽FaceUp,FaceDown,Unknown等设备方向，方便修正
    fileprivate var prevDeviceOrientation = UIDeviceOrientation.portrait

    // 转场动画模式
    var transitonType: TransitionStype = .present

    override init() {
        super.init()
    }

    init(transitonType: TransitionStype) {
        super.init()
        self.transitonType = transitonType
    }

    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        switch transitonType {
        case .present, .push:
            return 1.5
        case .dismiss, .pop:
            return 5.5
        }
    }

    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch transitonType {
        case .present, .push:
            // presenting VC (A)
            guard let _ = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) else { return }
            // presented VC (B)
            guard let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else { return }

            // 此时的keyWindow的bounds已经是横屏时的参数了，即宽 > 高
            let frame = UIApplication.shared.keyWindow?.bounds ?? CGRect.zero
            print("animateTransition >> Present >> keyWindow bounds is \(frame)") // 打印数据：keyWindow bounds is (0.0, 0.0, 667.0, 375.0)

            // containerView的frame也是横屏时的参数了，即宽 > 高，同keyWindow是一样的
            let containerView = transitionContext.containerView
            containerView.addSubview(toVC.view)

            toVC.view.frame = frame

            if let controller = toVC as?ELPresentRotateViewControllerProtocol {
                controller.beforePresent()
                controller.presentRotateView?.presentControl(with: controller, containerView: containerView, controllerView: toVC.view, completion: {
                    controller.afterPresent()
                    transitionContext.completeTransition(true)
                })
            }

        case .dismiss, .pop:
            // presented VC (B)
            guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) else { return }
            // presenting VC (A)
            guard let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else { return }

            print("animateTransition >> Dismiss >> fromVC frame >> \(fromVC.view.frame)")
            print("animateTransition >> Dismiss >> toVC frame >> \(toVC.view.frame)")

            // inserting presenting VC's view under presented VC's view
            let containerView = transitionContext.containerView
            let keyWindowFrame = UIApplication.shared.keyWindow?.bounds ?? CGRect.zero
            toVC.view.frame = keyWindowFrame
            containerView.insertSubview(toVC.view, belowSubview: fromVC.view)

            print("animateTransition >> Dismiss >> keyWindowFrame frame >> \(keyWindowFrame)")
            print("animateTransition >> Dismiss >> containerView frame >> \(containerView.frame)")

            if let controller = fromVC as? ELPresentRotateViewControllerProtocol {
                controller.beforeDismiss()
                controller.presentRotateView?.dismissControl(with: controller, containerView: containerView, controllerView: fromVC.view) {
                    controller.afterDismiss()
                    transitionContext.completeTransition(true)
                }
            }
        }
    }
}
