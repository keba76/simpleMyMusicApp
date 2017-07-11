//
//  AudioViewModel.swift
//  simpleMyMusicApp
//
//  Created by Ievgen Keba on 7/10/17.
//  Copyright © 2017 Harman Inc. All rights reserved.
//

import Foundation

struct AudioViewModel {
    var title: String
    var audio: URL
    var images: URL
    var postKey: String
    var favorites: Bool
    
    init(post: Post) {
        title = post.title
        audio = post.audioURL
        images = post.imagesURL
        postKey = post.postKey
        favorites = post.favorites
    }
}
