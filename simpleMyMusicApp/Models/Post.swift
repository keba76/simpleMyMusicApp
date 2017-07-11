//
//  Post.swift
//  simpleMyMusicApp
//
//  Created by Ievgen Keba on 7/10/17.
//  Copyright © 2017 Harman Inc. All rights reserved.
//

import Foundation
import Firebase

struct Post {
    
    private var _title: String
    private var _imagesURL: URL
    private var _postKey: String!
    private var _audioURL: URL
    private var _favorites: Bool
    
    var title: String { return _title }
    var imagesURL: URL { return _imagesURL }
    var audioURL: URL { return _audioURL }
    var postKey: String { return _postKey }
    var favorites: Bool { return _favorites }
 
    init(title: String, favorites: Bool, images: URL, audio: URL, postKey: String) {
        self._title = title
        self._imagesURL = images
        self._audioURL = audio
        self._postKey = postKey
        self._favorites = favorites
    }
}
