//
//  HashTagApi.swift
//  Music App
//
//  Created by Neeraj Ramachandran on 8/5/19.
//  Copyright © 2019 Neeraj Ramachandran. All rights reserved.
//

import Foundation
import FirebaseDatabase
// Handles database tasks related to hashtags
class HashTagApi {
    // Firebase reference object pointing to hashtag location
    var REF_HASHTAG = Database.database().reference().child("hashTag")
    
    func fetchPosts(withTag tag: String, completion: @escaping (String) -> Void) {
        REF_HASHTAG.child(tag.lowercased()).observe(.childAdded, with: {
            snapshot in
            completion(snapshot.key)
        })
    }
    
}
