//
//  NVActivityIndicatorView.swift
//  pushMyMusic
//
//  Created by Ievgen Keba on 7/8/17.
//  Copyright © 2017 Harman Inc. All rights reserved.
//

import UIKit

public enum NVActivityIndicatorType: Int {

    case blank
    case ballRotate  //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    case lineScalePulseOut   //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
    static let allTypes = (blank.rawValue ... lineScalePulseOut.rawValue).map { NVActivityIndicatorType(rawValue: $0)! }
    
    func animation() -> NVActivityIndicatorAnimationDelegate {
        switch self {
        case .blank:
            return NVActivityIndicatorAnimationBlank()
        case .lineScalePulseOut:
            return NVActivityIndicatorAnimationLineScalePulseOut()
        case .ballRotate:
            return NVActivityIndicatorAnimationBallRotate()
        }
    }
}

/// Activity indicator view with animations
public final class NVActivityIndicatorView: UIView {
    /// Default type.
    public static var DEFAULT_TYPE: NVActivityIndicatorType = .lineScalePulseOut
    public static var DEFAULT_COLOR = UIColor.white
    public static var DEFAULT_TEXT_COLOR = UIColor.white
    public static var DEFAULT_PADDING: CGFloat = 0
    public static var DEFAULT_BLOCKER_SIZE = CGSize(width: 60, height: 60)
    public static var DEFAULT_BLOCKER_DISPLAY_TIME_THRESHOLD = 0
    public static var DEFAULT_BLOCKER_MINIMUM_DISPLAY_TIME = 0
    public static var DEFAULT_BLOCKER_MESSAGE: String?
    public static var DEFAULT_BLOCKER_MESSAGE_FONT = UIFont.boldSystemFont(ofSize: 20)
    public static var DEFAULT_BLOCKER_BACKGROUND_COLOR = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    
    /// Animation type.
    public var type: NVActivityIndicatorType = NVActivityIndicatorView.DEFAULT_TYPE
    
    @available(*, unavailable, message: "This property is reserved for Interface Builder. Use 'type' instead.")
    @IBInspectable var typeName: String {
        get {
            return getTypeName()
        }
        set {
            _setTypeName(newValue)
        }
    }
    
    /// Color of activity indicator view.
    @IBInspectable public var color: UIColor = NVActivityIndicatorView.DEFAULT_COLOR
    
    /// Padding of activity indicator view.
    @IBInspectable public var padding: CGFloat = NVActivityIndicatorView.DEFAULT_PADDING
    
    /// Current status of animation, read-only.
    @available(*, deprecated: 3.1)
    public var animating: Bool { return isAnimating }
    
    /// Current status of animation, read-only.
    private(set) public var isAnimating: Bool = false
    
    /**
     Returns an object initialized from data in a given unarchiver.
     self, initialized using the data in decoder.
     
     - parameter decoder: an unarchiver object.
     
     - returns: self, initialized using the data in decoder.
     */
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
        isHidden = true
    }
    
    /**
     Create a activity indicator view.
     
     Appropriate NVActivityIndicatorView.DEFAULT_* values are used for omitted params.
     
     - parameter frame:   view's frame.
     - parameter type:    animation type.
     - parameter color:   color of activity indicator view.
     - parameter padding: padding of activity indicator view.
     
     - returns: The activity indicator view.
     */
    public init(frame: CGRect, type: NVActivityIndicatorType? = nil, color: UIColor? = nil, padding: CGFloat? = nil) {
        self.type = type ?? NVActivityIndicatorView.DEFAULT_TYPE
        self.color = color ?? NVActivityIndicatorView.DEFAULT_COLOR
        self.padding = padding ?? NVActivityIndicatorView.DEFAULT_PADDING
        super.init(frame: frame)
        isHidden = true
    }
    
    // Fix issue #62
    // Intrinsic content size is used in autolayout
    // that causes mislayout when using with MBProgressHUD.
    /**
     Returns the natural size for the receiving view, considering only properties of the view itself.
     
     A size indicating the natural size for the receiving view based on its intrinsic properties.
     
     - returns: A size indicating the natural size for the receiving view based on its intrinsic properties.
     */
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: bounds.width, height: bounds.height)
    }
    
    /**
     Start animating.
     */
    public final func startAnimating() {
        isHidden = false
        isAnimating = true
        layer.speed = 1
        setUpAnimation()
    }
    
    /**
     Stop animating.
     */
    public final func stopAnimating() {
        isHidden = true
        isAnimating = false
        layer.sublayers?.removeAll()
    }
    
    // MARK: Internal
    
    func _setTypeName(_ typeName: String) {
        for item in NVActivityIndicatorType.allTypes {
            if String(describing: item).caseInsensitiveCompare(typeName) == ComparisonResult.orderedSame {
                type = item
                break
            }
        }
    }
    
    func getTypeName() -> String {
        return String(describing: type)
    }
    
    // MARK: Privates
    
    private final func setUpAnimation() {
        let animation: NVActivityIndicatorAnimationDelegate = type.animation()
        var animationRect = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(padding, padding, padding, padding))
        let minEdge = min(animationRect.width, animationRect.height)
        
        layer.sublayers = nil
        animationRect.size = CGSize(width: minEdge, height: minEdge)
        animation.setUpAnimation(in: layer, size: animationRect.size, color: color)
    }
}


