//
//  FavoritesCell.swift
//  simpleMyMusicApp
//
//  Created by Ievgen Keba on 7/10/17.
//  Copyright © 2017 Harman Inc. All rights reserved.
//

import UIKit

class FavoritesCell: UITableViewCell {
    
    @IBOutlet weak var pic: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var star: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        pic.layer.cornerRadius = 5.0
        pic.clipsToBounds = true
        pic.layer.borderColor = UIColor.darkGray.cgColor
        pic.layer.borderWidth = 0.5
        let path = UIBezierPath.init()
        path.move(to: CGPoint(x: 0.0, y: 0.0))
        path.addLine(to: CGPoint(x: 35.0, y: 0.0))
        path.addLine(to: CGPoint(x: 0.0, y: 35.0))
        path.addLine(to: CGPoint(x: 0.0, y: 0.0))
        path.close()
        
        let mask = CAShapeLayer()
        mask.frame = star.bounds
        mask.path = path.cgPath
        star.layer.mask = mask
    }
}
