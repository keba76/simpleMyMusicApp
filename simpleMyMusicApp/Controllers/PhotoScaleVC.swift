//
//  PhotoScaleVC.swift
//  simpleMyMusicApp
//
//  Created by Ievgen Keba on 7/10/17.
//  Copyright © 2017 Harman Inc. All rights reserved.
//

import UIKit
import AVFoundation
import SDWebImage
import MediaPlayer
import UserNotifications
import LocalAuthentication

class PhotoScaleVC: UIViewController {
    
    @IBOutlet weak var baseView: UIView!
    
    var image: UIImage?
    var index: IndexPath?
    var delegateOffset: OffserCell?
    var urlVideo: URL?
    var imageView: ImageViewLayer?
    lazy var timeRemainingLabel = UILabel()
    lazy var playBtn = UIButton()
    lazy var previousBtn = CustomBtn(frame: CGRect.zero)
    lazy var nextBtn = CustomBtn(frame: CGRect.zero)
    lazy var seekSlider = UISlider()
    lazy var mainViewContainerForAction = UIView()
    var timeObserver: Any?
    var timeObserverScreenLock: Any?
    
    var timeScreenLock = 0
    
    var viewProgress: NVActivityIndicatorView?
    
    private var playbackLikelyToKeepUpContext = 0
    var playerRateBeforeSeek: Float = 0
    
    let avPlayer = AVQueuePlayer()
    var avPlayerLayer: AVPlayerLayer!
    
    override func viewDidLoad() {
        let scc = MPRemoteCommandCenter.shared()
        scc.togglePlayPauseCommand.addTarget(self, action: #selector(doPlayPause))
        scc.playCommand.addTarget(self, action:#selector(doPlay))
        scc.pauseCommand.addTarget(self, action:#selector(doPause))
        scc.changePlaybackPositionCommand.isEnabled = false
        
        imageView = ImageViewLayer(image: image)
        imageView!.contentMode = .scaleAspectFill
        baseView.addSubview(imageView!)
        imageView!.translatesAutoresizingMaskIntoConstraints = false
        baseView.addConstraint(NSLayoutConstraint(item: imageView!, attribute: .centerX, relatedBy: .equal, toItem: baseView, attribute: .centerX, multiplier: 1, constant: 0))
        baseView.addConstraint(NSLayoutConstraint(item: imageView!, attribute: .centerY, relatedBy: .equal, toItem: baseView, attribute: .centerY, multiplier: 1, constant: 0))
        // add imageview side constraints
        for attribute: NSLayoutAttribute in [.top, .bottom, .leading, .trailing] {
            let constraintLowPriority = NSLayoutConstraint(item: imageView!, attribute: attribute, relatedBy: .equal, toItem: baseView, attribute: attribute, multiplier: 1, constant: 0)
            let constraintGreaterThan = NSLayoutConstraint(item: imageView!, attribute: attribute, relatedBy: .greaterThanOrEqual, toItem: baseView, attribute: attribute, multiplier: 1, constant: 0)
            constraintLowPriority.priority = 750
            baseView.addConstraints([constraintLowPriority,constraintGreaterThan])
        }
        
        let rectProgress = CGRect(x: view.bounds.width/2 - 20.0, y: view.bounds.height/2 - 20.0, width: 40.0, height: 40.0)
        viewProgress = NVActivityIndicatorView(frame: rectProgress, type: .ballRotate, color: UIColor.white, padding: 0)
        self.view.addSubview(self.viewProgress!)
        self.view.bringSubview(toFront: self.viewProgress!)
        self.viewProgress?.startAnimating()
        
        self.mainViewContainerForAction.backgroundColor = UIColor(white: 247/255, alpha: 0.3)
        self.mainViewContainerForAction.layer.cornerRadius = 8.0
        self.view.addSubview(mainViewContainerForAction)
        imageView?.playerLayer.player = avPlayer
        let url = AudioViewModelController.share.viewModel(at: self.index!.row)?.audio
        let asset = AVAsset(url: url!)
        let keys: [String] = ["playable"]
        asset.loadValuesAsynchronously(forKeys: keys) {
            DispatchQueue.main.async {
                self.avPlayer.insert(AVPlayerItem(asset: asset), after: nil)
            }
        }
        
        let interval = CMTime(seconds: 0.05, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = avPlayer.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { elapsedTime in
            self.observeTime(elapsedTime: elapsedTime)
            self.syncScrubber(elapsedTime: elapsedTime)
            
        })
        avPlayer.addObserver(self, forKeyPath: "currentItem.playbackLikelyToKeepUp",
                             options: .new, context: &playbackLikelyToKeepUpContext)
        timeRemainingLabel.textColor = UIColor.white
        timeRemainingLabel.adjustsFontSizeToFitWidth = true
        timeRemainingLabel.sizeToFit()
        mainViewContainerForAction.addSubview(timeRemainingLabel)
        
        playBtn.setImage(UIImage(named: "pause"), for: .normal)
        mainViewContainerForAction.addSubview(playBtn)
        previousBtn.setImage(UIImage(named: "previous"), for: .normal)
        mainViewContainerForAction.addSubview(previousBtn)
        nextBtn.setImage(UIImage(named: "next"), for: .normal)
        mainViewContainerForAction.addSubview(nextBtn)
        
        playBtn.addTarget(self, action: #selector(play), for: .touchUpInside)
        previousBtn.addTarget(self, action: #selector(previousTrack), for: .touchUpInside)
        nextBtn.addTarget(self, action: #selector(nextTrack), for: .touchUpInside)
        
        let resizeImageMinimun = UIImage(named: "RightSlider")?.resizableImage(withCapInsets: UIEdgeInsets(top: 0.0, left: 5.0, bottom: 0.0, right: 5.0), resizingMode: .tile)
        let resizeImageMaximum = UIImage(named: "LeftSlider")?.resizableImage(withCapInsets: UIEdgeInsets(top: 0.0, left: 5.0, bottom: 0.0, right: 5.0), resizingMode: .stretch)
        seekSlider.setMinimumTrackImage(resizeImageMinimun, for: .normal)
        seekSlider.setMaximumTrackImage(resizeImageMaximum, for: .normal)
        seekSlider.setThumbImage(UIImage(named: "Point"), for: .normal)
        mainViewContainerForAction.addSubview(seekSlider)
        seekSlider.addTarget(self, action: #selector(sliderBeganTracking), for: .touchDown)
        seekSlider.addTarget(self, action: #selector(sliderEndedTracking), for: [.touchUpInside, .touchUpOutside])
        seekSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        
        self.baseView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(actionClose(_:))))
    }
    
    func doPlayPause(_ event:MPRemoteCommandEvent) {
        print("playpause")
        if self.avPlayer.status == .readyToPlay { self.doPlay() } else { self.doPause() }
    }
    func doPlay() {
        print("play")
        self.playBtn.setImage(UIImage(named: "pause"), for: .normal)
        self.avPlayer.play()
        
        let mpic = MPNowPlayingInfoCenter.default()
        if var d = mpic.nowPlayingInfo {
            d[MPNowPlayingInfoPropertyPlaybackRate] = 1
            mpic.nowPlayingInfo = d
        }
    }
    func doPause() {
        print("pause")
        self.playBtn.setImage(UIImage(named: "play"), for: .normal)
        self.avPlayer.pause()
        let mpic = MPNowPlayingInfoCenter.default()
        if var d = mpic.nowPlayingInfo {
            d[MPNowPlayingInfoPropertyPlaybackRate] = 0
            d[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(self.avPlayer.currentTime())
            mpic.nowPlayingInfo = d
        }
    }
    
    deinit {
        let scc = MPRemoteCommandCenter.shared()
        scc.togglePlayPauseCommand.removeTarget(self)
        scc.playCommand.removeTarget(self)
        scc.pauseCommand.removeTarget(self)
        if let obs = self.timeObserver {
            self.avPlayer.removeTimeObserver(obs)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &playbackLikelyToKeepUpContext {
            if avPlayer.currentItem!.isPlaybackLikelyToKeepUp {
                self.viewProgress?.stopAnimating()
                self.viewProgress?.removeFromSuperview()
                self.timeRemainingLabel.isHidden = false
                
                let mpic = MPNowPlayingInfoCenter.default()
                mpic.nowPlayingInfo = [
                    MPMediaItemPropertyTitle: "\(AudioViewModelController.share.viewModel(at: self.index!.row)!.title)",
                    MPMediaItemPropertyArtwork : MPMediaItemArtwork(boundsSize: self.imageView!.image!.size, requestHandler: { size -> UIImage in
                        return self.imageView!.image!
                    }),
                    MPMediaItemPropertyPlaybackDuration: CMTimeGetSeconds(self.avPlayer.currentItem!.duration),
                    MPNowPlayingInfoPropertyElapsedPlaybackTime: 0,
                    MPNowPlayingInfoPropertyPlaybackRate: 1
                ]
            } else {
                self.view.addSubview(self.viewProgress!)
                self.view.bringSubview(toFront: self.viewProgress!)
                self.viewProgress?.startAnimating()
            }
        }
    }
    
    private func devicePasscodeSet() -> Bool {
        //checks to see if devices (not apps) passcode has been set
        return LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func playerItemDuration() -> CMTime {
        let thePlayerItem = avPlayer.currentItem
        if thePlayerItem?.status == .readyToPlay {
            return thePlayerItem!.duration
        }
        return kCMTimeInvalid
    }
    
    func syncScrubber(elapsedTime: CMTime) {
        let playerDuration = playerItemDuration()
        if CMTIME_IS_INVALID(playerDuration) {
            seekSlider.minimumValue = 0.0
            return
        }
        let duration = Float(CMTimeGetSeconds(playerDuration))
        if duration.isFinite && duration > 0 {
            seekSlider.minimumValue = 0.0
            seekSlider.maximumValue = duration
            let time = Float(CMTimeGetSeconds(elapsedTime))
            if viewProgress!.isAnimating {
                seekSlider.setValue(0.0, animated: true)
            } else {
                seekSlider.setValue(time, animated: true)
            }
            if seekSlider.value == seekSlider.maximumValue {
                seekSlider.value = 0.0
                avPlayer.seek(to: CMTime(value: CMTimeValue.allZeros, timescale: 1))
            }
        }
    }
    
    func updateTime(_ timer: Timer) {
        seekSlider.value = Float(CMTimeGetSeconds(avPlayer.currentItem!.duration))
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let controlsHeight: CGFloat = 30.0
        let countWidth: CGFloat = 56.0
        let widthBtn: CGFloat = 17.0
        
        mainViewContainerForAction.frame = CGRect(x: 8.0, y: imageView!.frame.maxY - 100.0, width: imageView!.frame.size.width - 16.0, height: 90.0)
        
        let countX = mainViewContainerForAction.bounds.maxX - countWidth
        let countY = mainViewContainerForAction.bounds.maxY - 10.0 - controlsHeight
        let playX = mainViewContainerForAction.bounds.midX - widthBtn/2
        let playY: CGFloat = countY - 40.0
        playBtn.frame = CGRect(x: playX, y: playY, width: 40.0, height: 40.0)
        let previousX = playBtn.frame.minX - 20.0 - widthBtn
        let previousY = countY - controlsHeight - 5.0
        previousBtn.frame = CGRect(x: previousX, y: previousY, width: widthBtn, height: controlsHeight)
        let nextX = playBtn.frame.maxX + 20.0
        let nextY = countY - controlsHeight - 5.0
        nextBtn.frame = CGRect(x: nextX, y: nextY, width: widthBtn, height: controlsHeight)
        let xSlider: CGFloat = 10.0
        let widthSlider = countX - 10.0 - xSlider
        timeRemainingLabel.frame = CGRect(x: countX, y: countY, width: countWidth, height: controlsHeight)
        
        seekSlider.frame = CGRect(x: xSlider, y: countY, width: widthSlider, height: controlsHeight)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(.portrait)
        avPlayer.play()
    }
    
    func play() {
       let mpic = MPNowPlayingInfoCenter.default()
        mpic.nowPlayingInfo = [MPNowPlayingInfoPropertyPlaybackRate: 0]
        if self.avPlayer.rate > 0 {
            self.avPlayer.pause()
            self.playBtn.setImage(UIImage(named: "play"), for: .normal)
            
        } else {
            mpic.nowPlayingInfo = [
                MPMediaItemPropertyTitle: "\(AudioViewModelController.share.viewModel(at: self.index!.row)!.title)",
                MPMediaItemPropertyArtwork : MPMediaItemArtwork(boundsSize: self.imageView!.image!.size, requestHandler: { size -> UIImage in
                    return self.imageView!.image!
                }),
                MPMediaItemPropertyPlaybackDuration: CMTimeGetSeconds(self.avPlayer.currentItem!.duration),
                MPNowPlayingInfoPropertyElapsedPlaybackTime: CMTimeGetSeconds(self.avPlayer.currentTime()),
                MPNowPlayingInfoPropertyPlaybackRate: 1
            ]
            self.avPlayer.play()
            self.playBtn.setImage(UIImage(named: "pause"), for: .normal)
        }
    }
    
    func previousTrack(btn: CustomBtn) {
        avPlayer.pause()
        self.playBtn.setImage(UIImage(named: "pause"), for: .normal)
        self.timeRemainingLabel.isHidden = true
        
        guard var indexPath = self.index else { return }
        if indexPath.row == 0 {
            indexPath.row = AudioViewModelController.share.viewModelsCount - 1
        } else {
            indexPath.row = indexPath.row - 1
        }
        imageView?.sd_setImage(with: AudioViewModelController.share.viewModel(at: indexPath.row)?.images)
        self.view.addSubview(self.viewProgress!)
        self.view.bringSubview(toFront: self.viewProgress!)
        self.viewProgress?.startAnimating()
        let url = AudioViewModelController.share.viewModel(at: indexPath.row)?.audio
        let asset = AVAsset(url: url!)
        let keys: [String] = ["playable"]
        asset.loadValuesAsynchronously(forKeys: keys) {
            DispatchQueue.main.async {
                let item = AVPlayerItem(asset: asset)
                self.avPlayer.insert(item, after: self.avPlayer.currentItem)
                self.avPlayer.advanceToNextItem()
                self.avPlayer.play()
            }
        }
        self.index = indexPath
    }
    
    
    func nextTrack() {
        self.avPlayer.pause()
        self.playBtn.setImage(UIImage(named: "pause"), for: .normal)
        self.timeRemainingLabel.isHidden = true
        
        guard var indexPath = self.index else { return }
        if indexPath.row >= AudioViewModelController.share.viewModelsCount - 1 {
            indexPath.row = 0
        } else {
            indexPath.row = indexPath.row + 1
        }
        imageView?.sd_setImage(with: AudioViewModelController.share.viewModel(at: indexPath.row)?.images)
        self.view.addSubview(self.viewProgress!)
        self.view.bringSubview(toFront: self.viewProgress!)
        self.viewProgress?.startAnimating()
        
        let url = AudioViewModelController.share.viewModel(at: indexPath.row)?.audio
        let asset = AVAsset(url: url!)
        let keys: [String] = ["playable"]
        asset.loadValuesAsynchronously(forKeys: keys) {
            DispatchQueue.main.async {
                let item = AVPlayerItem(asset: asset)
                self.avPlayer.insert(item, after: self.avPlayer.currentItem)
                self.avPlayer.advanceToNextItem()
                self.avPlayer.play()
            }
        }
        self.index = indexPath
    }
    
    func sliderBeganTracking(slider: UISlider) {
        playerRateBeforeSeek = avPlayer.rate
        avPlayer.pause()
    }
    func sliderEndedTracking(slider: UISlider) {
        let elapsedTime: Float64 = Float64(seekSlider.value)
        updateTimeLabel(elapsedTime: elapsedTime)
        avPlayer.seek(to: CMTimeMakeWithSeconds(elapsedTime, 1000)) { (completed: Bool) -> Void in
            if self.playerRateBeforeSeek > 0 {
                self.avPlayer.play()
            }
        }
    }
    func sliderValueChanged(slider: UISlider) {
        let elapsedTime: Float64 = Float64(seekSlider.value)
        
        updateTimeLabel(elapsedTime: elapsedTime)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        avPlayer.removeObserver(self, forKeyPath: "currentItem.playbackLikelyToKeepUp")
        //avPlayer.removeTimeObserver(timeObserver!)
        let scc = MPRemoteCommandCenter.shared()
        scc.togglePlayPauseCommand.removeTarget(self)
        scc.playCommand.removeTarget(self)
        scc.pauseCommand.removeTarget(self)
        if let obs = self.timeObserver {
            self.avPlayer.removeTimeObserver(obs)
        }
        
    }
    
    func actionClose(_ tap: UITapGestureRecognizer) {
        avPlayer.pause()
        
        self.delegateOffset?.offset(index: self.index!, image: self.imageView!.image!)
        presentingViewController?.dismiss(animated: true, completion: nil)
        
    }
    
    private func observeTime(elapsedTime: CMTime) {
        if secondFromStart >= 30 {
            // if self.devicePasscodeSet() {
            self.doPause()
            let delegate = UIApplication.shared.delegate as! AppDelegate
            delegate.timer?.invalidate()
            secondFromStart = 0
            // }
        }
        let duration = CMTimeGetSeconds(avPlayer.currentItem!.duration)
        if duration.isFinite {
            let elapsedTime = CMTimeGetSeconds(elapsedTime)
            updateTimeLabel(elapsedTime: elapsedTime)
        }
    }
    
    private func updateTimeLabel(elapsedTime: Float64) {
        let timeRemaining: Float64 = CMTimeGetSeconds(playerItemDuration()) - elapsedTime
        self.timeRemainingLabel.text = String(format: "%02d:%02d", ((lround(timeRemaining) / 60) % 60), lround(timeRemaining) % 60)
    }
}

extension PhotoScaleVC: ImageTransitionProtocol {
    
    func tranisitionSetup() { baseView.isHidden = true }
    
    func tranisitionCleanup() { baseView.isHidden = false }
    
    //return the imageView window frame
    func imageWindowFrame() -> CGRect { return baseView.superview!.convert(baseView.frame, to: nil) }
}

class ImageViewLayer: UIImageView {
    var player: AVPlayer? {
        get { return playerLayer.player }
        set { playerLayer.player = newValue }
    }
    var playerLayer: AVPlayerLayer { return layer as! AVPlayerLayer }
    
    override class var layerClass: AnyClass { return AVPlayerLayer.self }
}

class CustomBtn: UIButton {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let rect = self.bounds.insetBy(dx: -10.0, dy: -10.0)
        if rect.contains(point) { return self }
        return nil
    }
}
