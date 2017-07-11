//
//  MyCollectionViewFlowLayout.swift
//  simpleMyMusicApp
//
//  Created by Ievgen Keba on 7/10/17.
//  Copyright © 2017 Harman Inc. All rights reserved.
//

import UIKit

class MyCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    var mostRecentOffset : CGPoint = CGPoint()
    
    override func awakeFromNib() {
        let currentSizeScreen = UIScreen.main.bounds.maxX
        switch currentSizeScreen {
        case 320.0:
            self.itemSize = CGSize(width: 90.0, height: 115.0)
            self.minimumInteritemSpacing = 10.0
            self.minimumLineSpacing = 10.0
            self.scrollDirection = .vertical
            self.sectionInset = UIEdgeInsets(top: 70.0, left: 12.0, bottom: 50.0, right: 12.0)
        case 414.0:
            self.itemSize = CGSize(width: 120.0, height: 145.0)
            self.minimumInteritemSpacing = 10.0
            self.minimumLineSpacing = 10.0
            self.scrollDirection = .vertical
            self.sectionInset = UIEdgeInsets(top: 70.0, left: 12.0, bottom: 50.0, right: 12.0)
        default:
            self.itemSize = CGSize(width: 110.0, height: 135.0)
            self.minimumInteritemSpacing = 10.0
            self.minimumLineSpacing = 10.0
            self.scrollDirection = .vertical
            self.sectionInset = UIEdgeInsets(top: 70.0, left: 10.0, bottom: 50.0, right: 10.0)
        }
    }
}
