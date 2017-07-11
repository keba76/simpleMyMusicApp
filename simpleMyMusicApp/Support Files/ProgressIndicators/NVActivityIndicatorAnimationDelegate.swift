//
//  NVActivityIndicatorAnimationDelegate.swift
//  pushMyMusic
//
//  Created by Ievgen Keba on 7/8/17.
//  Copyright © 2017 Harman Inc. All rights reserved.
//

import UIKit

protocol NVActivityIndicatorAnimationDelegate {
    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor)
}
