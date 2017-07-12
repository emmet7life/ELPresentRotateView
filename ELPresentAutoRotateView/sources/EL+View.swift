//
//  Demo+TargetAVPlayerView.swift
//  WeiboPicsViewer
//
//  Created by 陈建立 on 3/30/17.
//  Copyright © 2017 陈建立. All rights reserved.
//

import UIKit

// MARK: - 配置
struct ELPresentRotateViewConfig {
    // 动画变换过程的时间
    var animDuration: Double = 0.24
    // 横竖屏切换后对旋转结果监听的延迟时间
    var orientationChangedDeteckDelayTime: Double = 0.40
}

// MARK: - 本视图可以作为任何想要实现自动旋转的视图的父视图
// 旋转的一切触发和变换过程交给这个视图来控制，内部逻辑由对应的delegate协议来跟子视图进行交互
class ELPresentRotateView: UIView {

    // MARK: - 实现协议所规定的属性，各个属性具体含义和用途可以去看协议的描述部分，那里做了描述了

    weak var presentRotateView: UIView?

    var playState: ELPresentRotateViewPlayState = .initiate {
        didSet {
            delegate?.presentRotateView(self, viewStateChanged: playState)
        }
    }

    var isFullScreen: Bool {
        // 可以利用statusBarOrientation来判定是否全屏
        return UIApplication.shared.statusBarOrientation == .landscapeLeft || UIApplication.shared.statusBarOrientation == .landscapeRight
    }

    weak var presentingController: UIViewController?
    weak var presentedController: ELPresentRotateViewControllerProtocol? {
        // 应保证返回的实例是唯一的
        if _presentedController == nil {
            _presentedController = generatePresentedController() as? ELPresentRotateViewControllerProtocol
        }
        return _presentedController
    }

    weak var presentingControllerTargetSuperview: UIView?
    weak var presentedControllerTargetSuperview: UIView?

    weak var delegate: ELPresentRotateViewDelegate?

    // MARK: - 全局控制的配置项
    static var config = ELPresentRotateViewConfig()

    // MARK: - 协议外的属性
    fileprivate weak var _presentedController: ELPresentRotateViewControllerProtocol?

    fileprivate var statusBarOrientation: UIInterfaceOrientation = .landscapeRight // 记录将要dismiss时，状态栏的方向

    fileprivate var delayPortraitDetectIsSchedule = false
    fileprivate var delayLandscapeDetectIsSchedule = false

    fileprivate var convertCenterPoint: CGPoint = CGPoint.zero
    fileprivate var convertWidth: CGFloat = 0.0
    fileprivate var convertHeight: CGFloat = 0.0

    fileprivate var presentedConstraints: [NSLayoutConstraint] = []
    fileprivate var dismissedConstraints: [NSLayoutConstraint] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupUI()
    }

    func setupUI() {
        presentRotateView = self
    }

    private func generatePresentedController() -> UIViewController {
        if let presentedController = delegate?.presentRotateViewGeneratePresentedController(self) {
            return presentedController
        }
        return BasicELPresentRotateViewController(self)
    }

}

extension ELPresentRotateView: ELPresentRotateViewProtocol {

    // MARK: - Protocol Method
    func resetViewState() {
        playState = .initiate
    }

    func onPresentRotateViewPlayControlBtnTapped() {
        switch playState {
        case .initiate, .stop:// 初始阶段 or 播放完成阶段，显示播放按钮，点击开始播放
            playState = .playing
        case .playing, .resume:// 初始播放后 or 暂停后恢复播放，显示暂停按钮，点击暂停播放
            playState = .pause
        case .pause:// 暂停状态，点击恢复播放
            playState = .resume
        }

        // ...
    }

    func onPresentRotateViewRotateControlBtnTapped() {
        statusBarOrientation = UIApplication.shared.statusBarOrientation
        if isFullScreen {
            if let controller = presentedController as? UIViewController {
                controller.dismiss(animated: true) {[weak self] (finished) in
                    self?._presentedController = nil
                }
            }
        } else {
            presentedController?.preferredInterfaceOrientation = preferredInterfaceOrientationForPresentation
            presentedController?.presentRotateView = self
            if let controller = presentedController as? UIViewController {
                presentingController?.present(controller, animated: true, completion: nil)
            }
        }
    }

    func register(_ presentingController: UIViewController?, delegate: ELPresentRotateViewDelegate? = nil) {
        self.delegate = delegate
        self.presentingController = presentingController

        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(onDeviceOrientationChanged(_:)),
                                                         name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }

    func unregister() {
        self.delegate = nil
        self.presentingController = nil

        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.removeObserver(self)
    }
    
    func presentControl(with controller: ELPresentRotateViewControllerProtocol, containerView: UIView, controllerView: UIView, completion: @escaping () -> ()) {
        transformingStateChanged(state: .beforePresent)
        delegate?.presentRotateView(beforePresent: containerView)

        // 获取视图本身及其父视图
        if let superview = presentingControllerTargetSuperview {

            // Inner Method
            func angle(step at: Int) -> CGFloat {
                switch controller.preferredInterfaceOrientation {
                case .landscapeRight:
                    if at == 1 {
                        return -CGFloat(Double.pi/2.0)
                    } else if at == 2 {
                        return CGFloat(Double.pi/2.0)
                    } else {
                        return 0.0
                    }
                default:
                    if at == 1 {
                        return CGFloat(Double.pi/2.0)
                    } else if at == 2 {
                        return -CGFloat(Double.pi/2.0)
                    } else {
                        return 0.0
                    }
                }
            }

            let view = controllerView
            let targetAVPlayerView = self

            // 这里我们打印一下视图本身的frame数据，从打印的数据可以看出：
            // 视图本身的frame，仍然是处于竖屏状态下Controller中时，在其父视图中的frame
            print("targetAVPlayerView.frame >> \(targetAVPlayerView.frame)") // 打印数据：targetAVPlayerView.frame >> (0.0, 0.0, 375.0, 200.0)

            // 但是要注意，这里的view的frame已经是横屏的了，即宽 > 高
            print("view frame >> \(view.frame)") // 打印数据: view frame >> (0.0, 0.0, 667.0, 375.0)

            // 1. 记录下presented Controller横屏时的frame参数
            let landscapeFrame = view.frame

            // 2. 这个经过转化得到的convertRect位置参数是竖屏状态时的视图的frame所形成的形状，
            // 在当前横屏状态时对应的frame，x和y，width和height都和视图原来处于竖屏状态时发生了颠倒。
            let convertRect = superview.convert(targetAVPlayerView.frame, to: view)
            print("convertRect >> \(convertRect)") // 打印数据：convertRect >> (-31.5, 0.0, 200.0, 375.0) // 滚动到最底部，然后点击最靠上的那个Cell的全屏按钮

            // 算出convertRect所在区域的中心点坐标，因为我们可能要围绕这个中心点做旋转
            let centerX = convertRect.origin.x + convertRect.size.width * 0.5
            let centerY = convertRect.origin.y + convertRect.size.height * 0.5
            let centerPoint = CGPoint(x: centerX, y: centerY)
            print("centerPoint >> \(centerPoint)")

            // 3. 首先第一步，把视图从其原先的父视图中移除，然后添加到当前视图
            targetAVPlayerView.removeFromSuperview()
            //targetAVPlayerView.frame = CGRect(x: 0, y: 0, width: convertRect.height, height: convertRect.width)
            //targetAVPlayerView.center = centerPoint
            view.addSubview(targetAVPlayerView)

            // 4. 因为在convertRect中，宽高被颠倒过来了，这里我们要颠倒着取回视图实际的宽、高
            // 其实大可不必这么麻烦，在这里，依然可以直接取targetAVPlayerView.frame的宽和高就可以了，
            // 但是想告诉大家整个变换过程，视图到底发生了什么变化，可以通过什么样的方法去重新获取正确的参数
            let newWidth = convertRect.height
            let newHeight = convertRect.width

            let superviewFrame = landscapeFrame

            let superviewCenterPoint = view.center
            print("superviewCenterPoint >> \(superviewCenterPoint)")

            // 5. 添加了视图之后，我们该放在什么位置上呢？
            // 5.1 首先，保证视图中心点和视图在竖屏时在同一个位置，可以用下面的方法来计算得出这个center1
            // 5.2 然后将视图实际应该显示的宽和高设置好，也就是width1和height1
            convertCenterPoint = CGPoint(x: centerPoint.x - superviewCenterPoint.x, y: centerPoint.y - superviewCenterPoint.y)
            convertWidth = newWidth
            convertHeight = newHeight
            print("convertCenterPoint >> \(convertCenterPoint), convertWidth >> \(convertWidth), convertHeight >> \(convertHeight)")

            // 5.3 设置布局参数
            let centerXLC = NSLayoutConstraint(item: targetAVPlayerView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: convertCenterPoint.x)
            let centerYLC = NSLayoutConstraint(item: targetAVPlayerView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: convertCenterPoint.y)
            let widthLC = NSLayoutConstraint(item: targetAVPlayerView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: convertWidth)
            let heightLC = NSLayoutConstraint(item: targetAVPlayerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: convertHeight)
            presentedConstraints = [centerXLC, centerYLC, widthLC, heightLC]
            view.addConstraints(presentedConstraints)

            // Right: -CGFloat(Double.pi/2.0) -> CGFloat(Double.pi/2)
            // Left :  CGFloat(Double.pi/2) -> -CGFloat(Double.pi/2)

            // 6. 在执行完第5步之后，其实视图的位置还是不“正确”的，因此需要来一个90°翻转，
            // 达到一个什么效果呢？视图看着依然处于竖屏状态时的位置，给用户的感觉就是，从这开始，才要真正的开始旋转了
            // 当然，这个90°到底是顺时针还是逆时针，就跟当前横屏的方式有关系了，
            // 到底是LandscapeLeft还是LandscapeRight？具体的值可通过angle(step:)方法求得

            // transform -> 旋转1，“假象”，保持视图位置与原位置一致
            let transform = CGAffineTransform(rotationAngle: angle(step: 1))
            targetAVPlayerView.transform = transform

            // [注意]：这里要求立刻刷新布局，让transform生效
            view.setNeedsLayout()
            view.layoutIfNeeded()

            // 7. 最后执行的就是让视图实现真正的变换了
            // 7.1 视图的frame与当前的父视图保持一致

            centerXLC.constant = 0.0
            centerYLC.constant = 0.0
            widthLC.constant = superviewFrame.width
            heightLC.constant = superviewFrame.height

            // 7.2 让刚才那个为了“假象”的旋转，旋回来 ^_^，旋回来有两种方式：
            // 7.2.1 之前是怎么旋转的，倒着旋转回来，然后在动画结束时设置最终的transform为CGAffineTransformIdentity
            // 7.2.2 不管之前是怎么为了“假象”去执行旋转，缩小啊等变换，直接让它回归纯真CGAffineTransformIdentity，
            // 动画完成时也不需要在设置最终的transform了，即第二种方式时，7.3不必执行。

            UIView.animate(withDuration: ELPresentRotateView.config.animDuration, animations: {
                // 方式1
                // transform -> 旋转2，“旋回来”的变幻过程，frame变成全屏
                //                transform = CGAffineTransformRotate(transform, self.angle(step: 2))
                //                targetAVPlayerView.transform = transform

                // 方式2
                targetAVPlayerView.transform = CGAffineTransform.identity
                self.delegate?.presentRotateView(presentAnimating: containerView, presentedSuperView: view)
                view.layoutIfNeeded()

                }, completion: { [weak self] (finished) in
                    // 7.3 动画结束了之后，就可以让transform -> 归位了，大功告成 bingo！！
                    //                    targetAVPlayerView.transform = CGAffineTransformIdentity
                    self?.transformingStateChanged(state: .afterPresent)
                    self?.delegate?.presentRotateView(afterPresent: containerView)
                    completion()
            })

            print("doAtPresentAction >> \(view.frame)")
        }
    }

    func dismissControl(with controller: ELPresentRotateViewControllerProtocol, containerView: UIView, controllerView: UIView, completion: @escaping () -> ()) {
        transformingStateChanged(state: .beforeDismiss)
        delegate?.presentRotateView(beforeDismiss: containerView)

        let targetAVPlayerView = self
        let view = controllerView

        var angle: CGFloat = -CGFloat(Double.pi/2)
        var centerPoint = convertCenterPoint
        // 1. 首先利用preferredInterfaceOrientation判断，最开始进来时的横屏模式是Right还是Left？
        if controller.preferredInterfaceOrientation == .landscapeRight {

            // 2. 利用协议的statusBarOrientation属性，获取当前控制器处于哪种横屏模式下？
            switch statusBarOrientation {

            // 3. 最终，我们的目的是计算出视图旋转回竖屏状态下“原位置”时的中心点坐标和应该旋转的角度
            case .landscapeLeft:
                angle = CGFloat(Double.pi/2)
                centerPoint = CGPoint(x: -convertCenterPoint.x, y: -convertCenterPoint.y)
            case .landscapeRight:
                angle = -CGFloat(Double.pi/2)
                centerPoint = convertCenterPoint
            default: break
            }
        } else {
            switch statusBarOrientation {
            case .landscapeRight:
                angle = -CGFloat(Double.pi/2)
                centerPoint = CGPoint(x: -convertCenterPoint.x, y: -convertCenterPoint.y)
            case .landscapeLeft:
                angle = CGFloat(Double.pi/2)
                centerPoint = convertCenterPoint
            default: break
            }
        }
        // Okay!为什么会有上面的计算！？其实我也是看了变换效果才发现的规律，
        // 开始旋转进入全屏状态时横屏模式(要看用户怎么拿设备了)与最终要退出全屏状态时当时所处的横屏模式影响了最终的计算方式。
        // 这其中存在着镜像的问题，抽空画图标识一下。

        // 4.1 设置最终变换回竖屏状态下的frame
        let centerXLC = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: centerPoint.x)
        let centerYLC = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: centerPoint.y)
        let widthLC = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: convertWidth)
        let heightLC = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: convertHeight)
        dismissedConstraints = [centerXLC, centerYLC, widthLC, heightLC]
        view.removeConstraints(presentedConstraints)
        view.addConstraints(dismissedConstraints)

        // 4.2 旋转变换和布局改变动画
        var transform = targetAVPlayerView.transform
        UIView.animate(withDuration: ELPresentRotateView.config.animDuration, animations: {

            transform = transform.rotated(by: angle)
            targetAVPlayerView.transform = transform
            self.delegate?.presentRotateView(dismissAnimating: containerView, presentingSuperView: self.presentingControllerTargetSuperview)
            view.layoutIfNeeded()

        }, completion: {[weak self] (finished) in

            // 5. 最后，在协议的afterDismiss方法中，干一些将视图添加回原父视图的工作，因为涉及到内部的布局设置
            // 因此放在协议的方法中，由协议实现者自己实现比较合适。
            self?.transformingStateChanged(state: .afterDismiss)
            self?.delegate?.presentRotateView(afterDismiss: containerView)
            completion()
        })
    }

}

extension ELPresentRotateView {
    var deviceOrientation: UIDeviceOrientation {
        return UIDevice.current.orientation
    }

    // 根据当前的设备方向，来获取present时，BasicELPresentRotateViewController应该对应的preferredInterfaceOrientationForPresentation值
    var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        switch deviceOrientation {
        case .landscapeRight:
            return .landscapeLeft
        default:
            return .landscapeRight
        }
    }

    fileprivate func transformingStateChanged(state: ELPresentRotateViewTransformingState) {
        switch state {
        case .beforePresent: beforePresent()
        case .afterPresent: afterPresent()
        case .beforeDismiss: beforeDismiss()
        case .afterDismiss: afterDismiss()
        }
    }

    fileprivate func beforePresent() {
        // 在由当前视图所在的Controller，记做A，present到下一个Controller，记做B 之前，
        // 记录下视图的父视图，记做superviewA，因为在Controller B dismiss时，
        // 需要将视图添加回 Controller A中的父视图superviewA
        presentingControllerTargetSuperview = superview
    }

    fileprivate func afterPresent() {
        presentedControllerTargetSuperview = superview
    }

    fileprivate func beforeDismiss() {

    }

    fileprivate func afterDismiss() {
        removeFromSuperview()
        presentingControllerTargetSuperview?.addSubview(self)

        self.transform = CGAffineTransform.identity
        if let previousSuperview = presentingControllerTargetSuperview {
            let leadingLC = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: previousSuperview, attribute: .leading, multiplier: 1.0, constant: 0)
            let trailingLC = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: previousSuperview, attribute: .trailing, multiplier: 1.0, constant: 0)
            let topLC = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: previousSuperview, attribute: .top, multiplier: 1.0, constant: 0)
            let bottomLC = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: previousSuperview, attribute: .bottom, multiplier: 1.0, constant: 0)
            previousSuperview.addConstraints([leadingLC, trailingLC, topLC, bottomLC])
        }
        presentingControllerTargetSuperview?.setNeedsLayout()
        presentingControllerTargetSuperview?.layoutIfNeeded()
    }

    @objc fileprivate func onDeviceOrientationChanged(_ notify: Notification) {
        print("AVPlayerView >> onDeviceOrientationChanged deviceOrientation >> \(deviceOrientation))")
        print("AVPlayerView >> onDeviceOrientationChanged statusBarOrientation>> \(UIApplication.shared.statusBarOrientation))")

        if isFullScreen {
            // 全屏时需要检测是否需要旋转回竖屏，并退出全屏

            // 对旋转的判定
            // 1.检测到竖屏时，延迟1.0秒，之后判定有没有再次被旋转到横屏，如果有，忽略对竖屏的处理(竖屏时退出全屏播放)
            // 2.竖屏检测忽略PortraitUpsideDown
            guard deviceOrientation == .portrait && !delayPortraitDetectIsSchedule else { return }
            schedulePortraitDetectDelay()
        } else {
            // 非全屏时，检测是否需要切换到横屏，并全屏展示
            guard (deviceOrientation == .landscapeLeft || deviceOrientation == .landscapeRight) && !delayLandscapeDetectIsSchedule else { return }
            scheduleLandscapeDetectDelay()
        }

    }

    // Portrait Detect Control
    func schedulePortraitDetectDelay() {
        delayPortraitDetectIsSchedule = true
        delay(ELPresentRotateView.config.orientationChangedDeteckDelayTime, callFunc: portraitBlock)
    }

    func portraitBlock() {
        if deviceOrientation != .portrait {
            // Ignore... System Control Screen At Landscape Mode
        } else {
            // Dismiss Controller
            if isFullScreen {
                onPresentRotateViewRotateControlBtnTapped()
            }
        }
        delayPortraitDetectIsSchedule = false
    }

    // Landscape Detect Control
    func scheduleLandscapeDetectDelay() {
        if playState != ELPresentRotateViewPlayState.initiate {
            delayLandscapeDetectIsSchedule = true
            delay(ELPresentRotateView.config.orientationChangedDeteckDelayTime, callFunc: landscapeBlock)
        }
    }

    func landscapeBlock() {
        if deviceOrientation == .landscapeLeft || deviceOrientation == .landscapeRight {
            // Present Controller
            if !isFullScreen {
                onPresentRotateViewRotateControlBtnTapped()
            }
        } else {
            // Ignore...
        }
        delayLandscapeDetectIsSchedule = false
    }

}
