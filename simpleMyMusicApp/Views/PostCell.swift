//
//  PostCell.swift
//  simpleMyMusicApp
//
//  Created by Ievgen Keba on 7/10/17.
//  Copyright © 2017 Harman Inc. All rights reserved.
//

import UIKit
import Firebase

class PostCell: UICollectionViewCell {
    
    var index: IndexPath?
    var delegate: CollectionViewCellDelegate?
    var postID: String?
    
    lazy var audioPlay: UIImageView = self.arrowImage()
    
    @IBOutlet weak var pic: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var favoriteBtn: DOFavoriteButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 5.0
    }
    
    func configure(_ viewModel: AudioViewModel) {
        self.postID = viewModel.postKey
        self.favoriteBtn.isSelected = viewModel.favorites
        audioPlay.image = UIImage(named: "viewPlay")
        
        self.title.text = viewModel.title
        
        let tapPic = UITapGestureRecognizer(target: self, action: #selector(handleTapPic))
        self.pic.isUserInteractionEnabled = true
        self.pic.addGestureRecognizer(tapPic)
        
        let tapBtn = UITapGestureRecognizer(target: self, action: #selector(handleTapBtn))
        self.favoriteBtn.isUserInteractionEnabled = true
        self.favoriteBtn.addGestureRecognizer(tapBtn)
        
    }
    
    func arrowImage() -> UIImageView {
        let currentSizeScreen = UIScreen.main.bounds.maxX
        let width: CGFloat
        switch currentSizeScreen {
        case 320.0: width = 90.0
        case 414.0: width = 120.0
        default: width = 110.0
        }
        let image = UIImageView(frame: CGRect(x: width/2 - 15, y: width/2 - 15, width: 30.0, height: 30.0))
        image.alpha = 0.5
        self.pic.addSubview(image)
        return image
        
    }
    
    func handleTapPic(_ sender: UITapGestureRecognizer) {
        guard let image = pic.image, let indexPath = index else { return }
        let intrinsicSize = self.convert(self.pic.frame, to: self.contentView)
        delegate?.tapImage(index: indexPath, image: image, convert: intrinsicSize)
    }
    
    func handleTapBtn(_ sender: UITapGestureRecognizer) {
        if self.favoriteBtn.isSelected {
            self.favoriteBtn.deselect()
            DataService.ds.refPosts.child(self.postID!).child("favorites").child(DataService.ds.refUserCurrent.key).removeValue()
            
        } else {
            self.favoriteBtn.select()
            DataService.ds.refPosts.child(self.postID!).child("favorites").child(DataService.ds.refUserCurrent.key).setValue(true)
            let add = UIApplication.shared.delegate as! AppDelegate
            add.notifHelper.kickThingsOff()
        }
    }
}
