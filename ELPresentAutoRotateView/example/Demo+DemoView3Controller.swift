//
//  Demo+DemoView3Controller.swift
//  WeiboPicsViewer
//
//  Created by 陈建立 on 7/10/17.
//  Copyright © 2017 陈建立. All rights reserved.
//

import UIKit
import AVFoundation

class DemoView3Controller: UIViewController {

    @IBOutlet weak var elPresentRotateView: ELPresentRotateView!
    @IBOutlet weak var fullScreenBtn: UIButton!
    @IBOutlet weak var playControlBtn: UIButton!
    @IBOutlet weak var playerLayerContainerView: UIView!

    // 视频播放组件
    fileprivate var urlAsset: AVURLAsset?
    fileprivate var playerItem: AVPlayerItem? {
        didSet {
            onPlayerItemChanged()
        }
    }
    fileprivate var lastPlayerItem: AVPlayerItem?
    fileprivate var playerLayer: AVPlayerLayer?
    fileprivate lazy var player: AVPlayer? = {
        if let item = self.playerItem {
            let player = AVPlayer(playerItem: item)
            return player
        }
        return nil
    }()

    // 控制属性
    fileprivate var isPlayerInited = false
    fileprivate var isUseCustomController = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Video Play"
        elPresentRotateView.register(self, delegate: self)
    }

    deinit {
        resetPlayer()
        print("DemoView3Controller deinit >> 😄")
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func onPlayControlTapped(_ sender: Any) {
        elPresentRotateView.onPresentRotateViewPlayControlBtnTapped()
    }

    @IBAction func onFullScreenTapped(_ sender: Any) {
        elPresentRotateView.onPresentRotateViewRotateControlBtnTapped()
    }

    @IBAction func onUseCustomControllerValueChanged(_ sender: UISwitch) {
        isUseCustomController = sender.isOn
    }

    fileprivate func removeObserver() {
        if let item = lastPlayerItem {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
            item.removeObserver(self, forKeyPath: "status")
            item.removeObserver(self, forKeyPath: "loadedTimeRanges")
            item.removeObserver(self, forKeyPath: "playbackBufferEmpty")
            item.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        }
    }

    fileprivate func addObserver() {
        if let item = playerItem {
            NotificationCenter.default.addObserver(self, selector: #selector(moviePlayDidEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
            item.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
            item.addObserver(self, forKeyPath: "loadedTimeRanges", options: NSKeyValueObservingOptions.new, context: nil)
            item.addObserver(self, forKeyPath: "playbackBufferEmpty", options: NSKeyValueObservingOptions.new, context: nil)
            item.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: NSKeyValueObservingOptions.new, context: nil)
        }
    }

    fileprivate func resetPlayer() {
        pause()

        playerItem = nil
        playerLayer?.removeFromSuperlayer()
        player?.replaceCurrentItem(with: nil)
        player = nil
    }

    fileprivate func playURL(url: URL) {
        let asset = AVURLAsset(url: url)
        playAsset(asset: asset)
    }

    fileprivate func playAsset(asset: AVURLAsset) {
        urlAsset = asset
        configPlayer()
        play()
    }

    fileprivate func configPlayer() {
        playerItem = AVPlayerItem(asset: urlAsset!)
        player = AVPlayer(playerItem: playerItem!)

        playerLayer?.removeFromSuperlayer()
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = AVLayerVideoGravityResizeAspect
        playerLayer?.frame = playerLayerContainerView.bounds

        playerLayerContainerView.layer.addSublayer(playerLayer!)
        playerLayerContainerView.setNeedsLayout()
        playerLayerContainerView.layoutIfNeeded()
    }

    fileprivate func play() {
        if let player = player {
            player.play()
        }
    }

    fileprivate func pause() {
        if let player = player {
            player.pause()
        }
    }

    fileprivate func onPlayerItemChanged() {
        if lastPlayerItem == playerItem {
            return
        }
        removeObserver()
        lastPlayerItem = playerItem
        addObserver()
    }

    @objc fileprivate func moviePlayDidEnd() {
        print("Player play end.")
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print("observeValue >> keyPath >> \(String(describing: keyPath))")
    }

}

extension DemoView3Controller: ELPresentRotateViewDelegate {

    func presentRotateViewGeneratePresentedController(_ containerView: UIView) -> UIViewController? {
        if isUseCustomController {
            return CustomAVPlayerViewController.viewController()
        }
        return nil
    }

    func presentRotateView(_ containerView: UIView, viewStateChanged state: ELPresentRotateViewPlayState) {
        switch state {
        case .initiate, .pause, .stop:
            playControlBtn.setImage(UIImage(named: "play"), for: UIControlState())

            pause()

        case .playing, .resume:
            playControlBtn.setImage(UIImage(named: "pause"), for: UIControlState())

            if isPlayerInited {
                play()
            } else {
                isPlayerInited = true
                let path = Bundle.main.path(forResource: "video", ofType: "mp4")!
                playURL(url: URL(fileURLWithPath: path))
            }
        }
    }

    func presentRotateView(presentAnimating containerView: UIView, presentedSuperView: UIView?) {
        playerLayer?.frame = presentedSuperView?.bounds ?? playerLayerContainerView.bounds
    }

    func presentRotateView(dismissAnimating containerView: UIView, presentingSuperView: UIView?) {
        playerLayer?.frame = presentingSuperView?.bounds ?? playerLayerContainerView.bounds
    }
}
