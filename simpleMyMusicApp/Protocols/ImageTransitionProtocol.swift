//
//  ImageTransitionProtocol.swift
//  simpleMyMusicApp
//
//  Created by Ievgen Keba on 7/10/17.
//  Copyright © 2017 Harman Inc. All rights reserved.
//

import UIKit

// For custom transition collectionView cell
protocol ImageTransitionProtocol {
    func tranisitionSetup()
    func tranisitionCleanup()
    func imageWindowFrame() -> CGRect
}

