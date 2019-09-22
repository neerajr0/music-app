//
//  FollowApi.swift
//  Music App
//
//  Created by Neeraj Ramachandran on 7/24/19.
//  Copyright © 2019 Neeraj Ramachandran. All rights reserved.
//

import Foundation
import FirebaseDatabase
class FollowApi {
    
    // Node that stores followers of every user
    var REF_FOLLOWERS = Database.database().reference().child("followers")
    
    // Node that stores following of every user
    var REF_FOLLOWING = Database.database().reference().child("following")
    
    func followAction(withUser id: String) {
        // After following a user, updates feed to include posts of that user
        // Finds all posts shared by the followed user
        Api.MyPosts.REF_MYPOSTS.child(id).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                for key in dict.keys {
                    Database.database().reference().child("feed").child(Api.User.CURRENT_USER!.uid).child(key).setValue(true)
                }
            }
        })
        
        // Followers --> User (of cell) --> New follower (current user)
        REF_FOLLOWERS.child(id).child(Api.User.CURRENT_USER!.uid).setValue(true)
        // Following --> Current user --> User (of cell)
        REF_FOLLOWING.child(Api.User.CURRENT_USER!.uid).child(id).setValue(true)
        
        // Update the notification database
        // User to receive notification (followed) --> current user (follower)
        let newNotificationReference = Api.Notification.REF_NOTIFICATION.child(id).child(Api.User.CURRENT_USER!.uid)
        let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
        // Set the value of the new notification reference
        newNotificationReference.setValue(["from": Api.User.CURRENT_USER!.uid, "objectId": Api.User.CURRENT_USER!.uid, "type": "follow", "timestamp": timestamp])
        
    }
    
    func unfollowAction(withUser id: String) {
        // After unfollowing a user, updates feed to remove posts of that user
        // Finds all posts shared by the unfollowed user
        Api.MyPosts.REF_MYPOSTS.child(id).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                for key in dict.keys {
                    Database.database().reference().child("feed").child(Api.User.CURRENT_USER!.uid).child(key).removeValue()
                }
            }
        })
        
        // Followers --> User (of cell) --> Remove follower (current user)
        // Set null removes child from child list of its parent node
        REF_FOLLOWERS.child(id).child(Api.User.CURRENT_USER!.uid).setValue(NSNull())
        // Following --> Current user --> Remove user (of cell)
        REF_FOLLOWING.child(Api.User.CURRENT_USER!.uid).child(id).setValue(NSNull())
        
        // Update the notification database
        // User to receive notification (unfollowed) --> current user (unfollower)
        let newNotificationReference = Api.Notification.REF_NOTIFICATION.child(id).child(Api.User.CURRENT_USER!.uid)
        // Set the value of the new notification reference to null
        newNotificationReference.setValue(NSNull())
    }
    
    func isFollowing(userId: String, completed: @escaping (Bool) -> Void) {
        // Checks if current user is in list of followers of input user (i.e. not null)
        REF_FOLLOWERS.child(userId).child(Api.User.CURRENT_USER!.uid).observeSingleEvent(of: .value, with: {
            snapshot in
            if let _ = snapshot.value as? NSNull {
                completed(false)
            } else {
                completed(true)
            }
        })
    }
    
    func fetchCountFollowing(userId: String, completed: @escaping(Int) -> Void) {
        // Gets following count of a user
        REF_FOLLOWING.child(userId).observe(.value, with: {
            snapshot in
            let count = Int(snapshot.childrenCount)
            completed(count)
        })
    }
    
    func fetchCountFollowers(userId: String, completed: @escaping(Int) -> Void) {
        // Gets follower count of a user
        REF_FOLLOWERS.child(userId).observe(.value, with: {
            snapshot in
            let count = Int(snapshot.childrenCount)
            completed(count)
        })
    }
    
}
