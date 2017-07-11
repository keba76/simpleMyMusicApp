//
//  File.swift
//  simpleMyMusicApp
//
//  Created by Ievgen Keba on 7/11/17.
//  Copyright © 2017 Harman Inc. All rights reserved.
//

import UIKit

// protocol for strictly cell position during back from transition
protocol OffserCell {
    func offset(index: IndexPath, image: UIImage)
}
