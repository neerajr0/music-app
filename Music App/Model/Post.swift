//
//  Post.swift
//  Music App
//
//  Created by Neeraj Ramachandran on 7/16/19.
//  Copyright © 2019 Neeraj Ramachandran. All rights reserved.
//

import Foundation
import FirebaseAuth
class Post {
    var caption: String?    // Use optionals so anything missing in an initializer will be nil by default
    var photoUrl: String?
    var videoUrl: String?
    var uid: String?
    var id: String?
    var likeCount: Int?
    var likes: Dictionary<String, Any>?
    var isLiked: Bool?
    var ratio: CGFloat?
    var timestamp: Int?
}
extension Post{
    static func transformPostPhoto(dict: [String: Any], key: String) -> Post {
        let post = Post()
        post.id = key
        post.caption = dict["caption"] as? String
        post.photoUrl = dict["photoUrl"] as? String
        post.videoUrl = dict["videoUrl"] as? String
        post.uid = dict["uid"] as? String
        post.likeCount = dict["likeCount"] as? Int
        post.likes = dict["likes"] as? Dictionary<String, Any>
        post.ratio = dict["ratio"] as? CGFloat
        post.timestamp = dict["timestamp"] as? Int
        if let currentUserId = Auth.auth().currentUser?.uid {
            if post.likes != nil {
                // Checks if the current user liked the post
                post.isLiked = post.likes![currentUserId] != nil
            }
        }
        return post
    }
    
}
