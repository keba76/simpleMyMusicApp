//
//  DataService.swift
//  simpleMyMusicApp
//
//  Created by Ievgen Keba on 7/10/17.
//  Copyright © 2017 Harman Inc. All rights reserved.
//

import Foundation
import Firebase



enum ConectionDB {
    static let connect = Database.database().reference(fromURL: "https://pushmymusic-36c60.firebaseio.com/")
    static let storage = Storage.storage().reference(forURL: "gs://pushmymusic-36c60.appspot.com")
}

class DataService {
    // singleton
    static let ds = DataService()
    
    private var _refPosts = ConectionDB.connect.child("posts")
    private var _refUsers = ConectionDB.connect.child("users")
    
    private var _refStoragePostImage = ConectionDB.storage.child("image")
    private var _refStoragePostAudio = ConectionDB.storage.child("audio")
    
    var refPosts: DatabaseReference { return _refPosts }
    
    var refUsers: DatabaseReference { return _refUsers }
    
    var refStorageImages: StorageReference { return _refStoragePostImage }
    
    var refStorageAudio: StorageReference { return _refStoragePostAudio }
    
    // We use the test ID for the current user, since the authorization was disabled in the Firebase sake this example.
    var refUserCurrent: DatabaseReference { return self._refUsers.child("qwerty12345") }
}
