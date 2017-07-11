//
//  CollectionViewCellDelegate.swift
//  simpleMyMusicApp
//
//  Created by Ievgen Keba on 7/10/17.
//  Copyright © 2017 Harman Inc. All rights reserved.
//

import UIKit

protocol CollectionViewCellDelegate {
    func tapImage(index: IndexPath, image: UIImage, convert: CGRect)
}

