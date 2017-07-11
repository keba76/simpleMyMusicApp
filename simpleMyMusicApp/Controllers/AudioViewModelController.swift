//
//  AudioViewModelController.swift
//  simpleMyMusicApp
//
//  Created by Ievgen Keba on 7/10/17.
//  Copyright © 2017 Harman Inc. All rights reserved.
//

import Foundation
import Firebase


class AudioViewModelController {
    
    static let share = AudioViewModelController()
    
    fileprivate var viewModels: [AudioViewModel?] = []
    
    typealias AudioDataComplete = (_ success: Bool, _ error: NSError?) -> ()
    
    func retrieveData(_ completionBlock: @escaping AudioDataComplete) {
        DataService.ds.refPosts.observe(.value, with: { (snapShot) in
            if let snapshots = snapShot.children.allObjects as? [DataSnapshot] {
                self.viewModels.removeAll()
                let myGroup = DispatchGroup()
                let myGroupStorage = DispatchGroup()
                for snap in snapshots {
                    myGroup.enter()
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        
                        var favorites = false
                        if let data = postDict["favorites"] as? Dictionary<String, AnyObject> {
                            if let _ = data["\(DataService.ds.refUserCurrent.key)"] {
                                favorites = true
                            }
                        }
                        let title = postDict["title"] as? String ?? ""
                        var images = NSURLComponents().url!
                        if let url = postDict["image"] as? String {
                            
                            myGroupStorage.enter()
                            Storage.storage().reference(forURL: url).getMetadata(completion: { (meta, error) in
                                if error != nil {
                                    print(error!.localizedDescription)
                                    
                                }
                                if let data = meta?.downloadURL() {
                                    images  = data
                                    myGroupStorage.leave()
                                }
                            })
                        }
                        var audioURL = NSURLComponents().url!
                        if let url = postDict["audioFile"] as? String {
                            myGroupStorage.enter()
                            Storage.storage().reference(forURL: url).getMetadata(completion: { (meta, error) in
                                if error != nil {
                                    print(error!.localizedDescription)
                                    
                                }
                                if let data = meta?.downloadURL() {
                                    audioURL = data
                                    myGroupStorage.leave()
                                }
                            })
                        }
                        myGroupStorage.notify(queue: .main) {
                            let data = AudioViewModel(post: Post(title: title, favorites: favorites, images: images, audio: audioURL, postKey: snap.key))
                            if !self.viewModels.contains(where: {$0?.postKey == data.postKey}) {
                                self.viewModels.append(data)
                            }
                            myGroup.leave()
                        }
                    }
                }
                myGroup.notify(queue: .main, execute: {
                    print(self.viewModels)
                    completionBlock(true, nil)
                })
            } else {
                completionBlock(false, NSError.createError(0, description: "FIREBASE parsing error"))
            }
        })
    }
    
    var viewModelsCount: Int {
        return viewModels.count
    }
    
    func viewModel(at index: Int) -> AudioViewModel? {
        guard index >= 0 && index < viewModelsCount else { return nil }
        return viewModels[index]
    }
}

