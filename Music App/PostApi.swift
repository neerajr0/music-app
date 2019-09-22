//
//  PostApi.swift
//  Music App
//
//  Created by Neeraj Ramachandran on 7/22/19.
//  Copyright © 2019 Neeraj Ramachandran. All rights reserved.
//

import Foundation
import FirebaseDatabase
// Handles database tasks related to posts
class PostApi {
    // Firebase reference object pointing to post location
    var REF_POSTS = Database.database().reference().child("posts")
    
    // Listens to events at the location of all posts on the database
    func observePosts(completion: @escaping (Post) -> Void) {
        REF_POSTS.observe(.childAdded) { (snapshot : DataSnapshot) in
            if let dict = snapshot.value as? [String: Any]{ // Optional dictionary with string keys
                // Grabs posts from database one by one and stores in dictionary format
                let newPost = Post.transformPostPhoto(dict: dict, key: snapshot.key)
                completion(newPost)
            }
        }
    }
    
    // Queries and transforms post from database into object of the Post class
    func observePost(withId id: String, completion: @escaping (Post) -> Void){
        REF_POSTS.child(id).observeSingleEvent(of: DataEventType.value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let post = Post.transformPostPhoto(dict: dict, key: snapshot.key)
                completion(post)
            }
        })
    }
    
    // Observes changes to post likes not from current user
    func observeLikeCount(withPostId id: String, completion: @escaping (Int) -> Void) {
        REF_POSTS.child(id).observe(.childChanged, with: {
            snapshot in
            if let value = snapshot.value as? Int {
                completion(value)
            }
        })
    }
    
    func observeTopPosts(completion: @escaping (Post) -> Void) {
        // Orders post by like count
        REF_POSTS.queryOrdered(byChild: "likeCount").observeSingleEvent(of: .value, with: {
            snapshot in
            let arraySnapshot = (snapshot.children.allObjects as! [DataSnapshot]).reversed()
            arraySnapshot.forEach( { (child) in
                if let dict = child.value as? [String: Any] {
                    let post = Post.transformPostPhoto(dict: dict, key: child.key)
                    completion(post)
                }
            })
        })
    }
    
    func incrementLikes(postId: String, onSuccess: @escaping (Post) -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        let postRef = Api.Post.REF_POSTS.child(postId)
        postRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var post = currentData.value as? [String: AnyObject], let uid =  Api.User.CURRENT_USER?.uid {
                var likes: Dictionary<String, Bool>
                likes = post["likes"] as? [String : Bool] ?? [:]
                var likeCount = post["likeCount"] as? Int ?? 0
                if let _ = likes[uid] {
                    // If the key for the uid exists (post already liked)
                    // Decrement like counter and remove like node
                    likeCount -= 1
                    likes.removeValue(forKey: uid)
                }
                else {
                    // If the key for the uid doesn't exist (post not already liked)
                    // Increment the counter and add like node
                    likeCount += 1
                    likes[uid] = true
                }
                post["likeCount"] = likeCount as AnyObject?
                post["likes"] = likes as AnyObject?
                
                // Set value and report transaction success
                currentData.value = post
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
               onError(error.localizedDescription)
            }
            // Update like if a change was made
            if let dict = snapshot?.value as? [String: Any] {
                let post = Post.transformPostPhoto(dict: dict, key: snapshot!.key)
                onSuccess(post)
            }
        }
    }
    
}
