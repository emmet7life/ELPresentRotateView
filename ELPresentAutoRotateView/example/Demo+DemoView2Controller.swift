//
//  Demo+View2Controller.swift
//  WeiboPicsViewer
//
//  Created by 陈建立 on 7/4/17.
//  Copyright © 2017 陈建立. All rights reserved.
//

import UIKit

class Demo2ViewController: UIViewController {

    @IBOutlet weak var testView: UIView!

    @IBOutlet weak var presentRotateView: ELPresentRotateView!
    @IBOutlet weak var playerStateBtn: UIButton!

    @IBOutlet weak var presentRotateView2: ELPresentRotateView!
    @IBOutlet weak var presentRotateView3: ELPresentRotateView!
    @IBOutlet weak var presentRotateView4: ELPresentRotateView!
    @IBOutlet weak var presentRotateView5: ELPresentRotateView!

    @IBAction func onFullAction(_ sender: AnyObject) {
        presentRotateView.onPresentRotateViewRotateControlBtnTapped()
    }

    @IBAction func onPlayStateChangeAction(_ sender: AnyObject) {
        presentRotateView.onPresentRotateViewPlayControlBtnTapped()
    }

    @IBAction func onFullAction1(_ sender: Any) {
        presentRotateView2.onPresentRotateViewRotateControlBtnTapped()
    }

    @IBAction func onFullAction2(_ sender: Any) {
        presentRotateView3.onPresentRotateViewRotateControlBtnTapped()
    }

    @IBAction func onFullAction3(_ sender: Any) {
        presentRotateView4.onPresentRotateViewRotateControlBtnTapped()
    }

    @IBAction func onFullAction4(_ sender: Any) {
        presentRotateView5.onPresentRotateViewRotateControlBtnTapped()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "View On Everywhere"
        presentRotateView.register(self, delegate: self)
        presentRotateView2.register(self)
        presentRotateView3.register(self)
        presentRotateView4.register(self)
        presentRotateView5.register(self)
    }

    deinit {
        print("DemoView2Controller deinit >> 😄")
    }

    /// 屏幕方向仅支持竖屏
    override var shouldAutorotate : Bool {
        return true
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }

}

extension Demo2ViewController: ELPresentRotateViewDelegate {

    func presentRotateView(_ containerView: UIView, viewStateChanged state: ELPresentRotateViewPlayState) {
        switch state {
        case .initiate, .pause, .stop:
            playerStateBtn.setImage(UIImage(named: "play"), for: UIControlState())
        case .playing, .resume:
            playerStateBtn.setImage(UIImage(named: "pause"), for: UIControlState())
        }
    }

}
