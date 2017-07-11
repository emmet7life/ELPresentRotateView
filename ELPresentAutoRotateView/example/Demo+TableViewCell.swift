//
//  WeiboPicsTableViewCell.swift
//  WeiboPicsViewer
//
//  Created by 陈建立 on 16/12/1.
//  Copyright © 2016年 陈建立. All rights reserved.
//

import UIKit
import Kingfisher

class PresentRotateViewDemoTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var view: ELPresentRotateView!
    @IBOutlet weak var zoomButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var dogView: UIImageView!

    // MARK: - ELPresentRotateView Control
    var targetController: UIViewController?

    @IBAction func fullscreenAction(_ sender: AnyObject) {
        view.onPresentRotateViewRotateControlBtnTapped()
    }

    @IBAction func playAction(_ sender: AnyObject) {
        view.onPresentRotateViewPlayControlBtnTapped()
    }

    func resetStateIfNeeded() {
        view.resetViewState()
    }

    // MARK: - User`s Custom Control
    func setLabelText(_ text: String) {
        label.text = text
    }

    func setImages(_ imageURL: String) {
        dogView.kf.setImage(with: URL(string: imageURL))
    }

    func register() {
        view.register(targetController, delegate: self)
    }

    func unregister() {
        view.unregister()
    }

}

extension PresentRotateViewDemoTableViewCell: ELPresentRotateViewDelegate {

    func presentRotateView(_ containerView: UIView, viewStateChanged state: ELPresentRotateViewPlayState) {
        switch state {
        case .initiate, .pause, .stop:
            playButton.setImage(UIImage(named: "play"), for: UIControlState())
        case .playing, .resume:
            playButton.setImage(UIImage(named: "pause"), for: UIControlState())
        }
    }
}
