//
//  AnimationController.swift
//  simpleMyMusicApp
//
//  Created by Ievgen Keba on 7/10/17.
//  Copyright © 2017 Harman Inc. All rights reserved.
//

import UIKit

class AnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    private var image: UIImage?
    private var alphaTabs: String?
    private var fromDelegate: ImageTransitionProtocol?
    private var toDelegate: ImageTransitionProtocol?
    private var frameVideoTriangle: CGRect?
    private var cornerRadius = true
    
    func setupImageTransition(data: SomeData, fromDelegate: ImageTransitionProtocol, toDelegate: ImageTransitionProtocol, alphaTabs: String?){
        
        self.image = data.image
        self.fromDelegate = fromDelegate
        self.toDelegate = toDelegate
        self.alphaTabs = alphaTabs
        self.frameVideoTriangle = data.convertTriangle
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            else { return }
        fromVC.view.backgroundColor = UIColor.black
        toVC.view.backgroundColor = UIColor.black
        
        toVC.view.frame = fromVC.view.frame
        
        let fromSnapshot = fromVC.view.snapshotView(afterScreenUpdates: true)
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.frame = (fromDelegate == nil) ? CGRect.zero : fromDelegate!.imageWindowFrame()
        if cornerRadius { imageView.layer.cornerRadius = 5.0 }
        imageView.clipsToBounds = true
        containerView.addSubview(imageView)
        
        fromDelegate!.tranisitionSetup()
        toDelegate!.tranisitionSetup()
        
        fromSnapshot?.frame = fromVC.view.frame
        containerView.addSubview(fromSnapshot!)
        
        let toSnapshot = toVC.view.snapshotView(afterScreenUpdates: true)
        
        toSnapshot?.frame = fromVC.view.frame
        containerView.addSubview(toSnapshot!)
        toSnapshot?.alpha = 0
        
        var videoTriangle = UIImageView(frame: CGRect.zero)
        if let frameVideo = self.frameVideoTriangle {
            videoTriangle = UIImageView(frame: frameVideo)
            videoTriangle.alpha = 0.7
            videoTriangle.image = UIImage(named: "viewPlay")
            containerView.addSubview(videoTriangle)
            videoTriangle.alpha = alphaTabs == "up" ? 0 : 0
        }
        
        containerView.bringSubview(toFront: imageView)
        containerView.bringSubview(toFront: videoTriangle)
        
        let toFrame = (self.toDelegate == nil) ? CGRect.zero : self.toDelegate!.imageWindowFrame()
        let animationDuration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseIn, animations: {
            toSnapshot?.alpha = 1
            imageView.frame = toFrame
            if self.alphaTabs == "up" {
                videoTriangle.alpha = 0
            } else if self.alphaTabs == "down" {
                videoTriangle.alpha = 0.5
            } else {
            }
        }) { (finished) in
            self.toDelegate!.tranisitionCleanup()
            imageView.removeFromSuperview()
            fromSnapshot?.removeFromSuperview()
            toSnapshot?.removeFromSuperview()
            fromVC.view.removeFromSuperview()
            videoTriangle.removeFromSuperview()
            
            if !transitionContext.transitionWasCancelled {
                containerView.addSubview(toVC.view)
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
