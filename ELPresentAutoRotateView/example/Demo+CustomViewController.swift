//
//  Demo+CustomAVPlayerViewController.swift
//  WeiboPicsViewer
//
//  Created by 陈建立 on 7/5/17.
//  Copyright © 2017 陈建立. All rights reserved.
//

import UIKit

class CustomAVPlayerViewController: UIViewController {

    class func viewController() -> CustomAVPlayerViewController {
        return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "VC_ID_CustomController") as! CustomAVPlayerViewController
    }

    // protocol needed
    public var preferredInterfaceOrientation: UIInterfaceOrientation = .landscapeRight
    public var presentRotateView: ELPresentRotateViewProtocol?
    public var transiton = Transition()
    public weak var presentRotateViewController: UIViewController? {
        return self
    }

    // custom view
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var progressSlider: UISlider!

    public required init(_ presentRotateView: ELPresentRotateViewProtocol) {
        super.init(nibName: nil, bundle: nil)
        self.presentRotateView = presentRotateView
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    fileprivate func setup() {
        self.transitioningDelegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    deinit {
        print("CustomAVPlayerViewController deinit >> 😄")
    }

    @IBAction func onBackTapped(_ sender: Any) {
        presentRotateView?.onPresentRotateViewRotateControlBtnTapped()
    }

    open override var prefersStatusBarHidden : Bool {
        return false
    }

    open override var preferredStatusBarUpdateAnimation : UIStatusBarAnimation {
        return UIStatusBarAnimation.none
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    open override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return preferredInterfaceOrientation
    }

    open override var shouldAutorotate : Bool {
        return true
    }

    open override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }

    // Custom Method
    func hiddenOtherViews(isHidden: Bool = true) {
        backBtn.isHidden = isHidden
        progressSlider.isHidden = isHidden
    }

    func bringOtherViewsToFront() {
        hiddenOtherViews(isHidden: false)
        view.bringSubview(toFront: backBtn)
        view.bringSubview(toFront: progressSlider)
    }

}

extension CustomAVPlayerViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transiton.transitonType = .present
        return transiton
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transiton.transitonType = .dismiss
        return transiton
    }
}

extension CustomAVPlayerViewController: ELPresentRotateViewControllerProtocol {

    func beforeDismiss() {
        hiddenOtherViews()
    }

    func beforePresent() {
        hiddenOtherViews()
    }

    func afterPresent() {
        bringOtherViewsToFront()
    }
}
