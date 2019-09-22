//
//  CommentApi.swift
//  Music App
//
//  Created by Neeraj Ramachandran on 7/22/19.
//  Copyright © 2019 Neeraj Ramachandran. All rights reserved.
//

import Foundation
import FirebaseDatabase
// Handles database tasks related to comments
class CommentApi {
    // Firebase reference object pointing to comments location
    var REF_COMMENTS = Database.database().reference().child("comments")
    
    func observeComments(withPostId id: String, completion: @escaping (Comment) -> Void) {
        REF_COMMENTS.child(id).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any]{ // Optional dictionary with string keys
                // Grabs comments from database one by one and stores in dictionary format
                let newComment = Comment.transformComment(dict: dict)
                completion(newComment)
            }
        })
    }
}
