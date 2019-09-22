//
//  HelperService.swift
//  Music App
//
//  Created by Neeraj Ramachandran on 7/24/19.
//  Copyright © 2019 Neeraj Ramachandran. All rights reserved.
//

import Foundation
import FirebaseStorage
import FirebaseDatabase
class HelperService {
    
    // Uploads media data to storage
    // Then stores post information on the database
    static func uploadDataToServer(data: Data, videoUrl: URL? = nil, ratio: CGFloat, caption: String, onSuccess: @escaping () -> Void) {
        // Uploads videos
        if let videoUrl = videoUrl {
            self.uploadVideoToFirebaseStorage(videoUrl: videoUrl, onSuccess: { (videoUrl) in
                // Uploads video thumbnail to storage
                uploadImageToFirebaseStorage(data: data, onSuccess: { (thumbnailImageUrl) in
                    sendDataToDatabase(photoUrl: thumbnailImageUrl, videoUrl: videoUrl, ratio: ratio, caption: caption, onSuccess: onSuccess)
                })
            })
            //      self.senddatatodatabase
        } else {
            // Otherwise uploads photos
            uploadImageToFirebaseStorage(data: data) { (photoUrl) in
                self.sendDataToDatabase(photoUrl: photoUrl, ratio: ratio, caption: caption, onSuccess: onSuccess)
            }
        }
    }
    
    static func uploadVideoToFirebaseStorage(videoUrl: URL, onSuccess: @escaping (_ videoUrl: String) -> Void) {
        let videoIdString = NSUUID().uuidString
        let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("posts").child(videoIdString)
        storageRef.putFile(from: videoUrl, metadata: nil) { (metadata, error) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            storageRef.downloadURL(completion: {(url, error) in
                if error != nil {
                    return
                }
                else {
                    let videoUrl = url?.absoluteString
                    onSuccess(videoUrl!)
                }
            })
        }
    }
    
    static func uploadImageToFirebaseStorage(data: Data, onSuccess: @escaping (_ imageUrl: String) -> Void) {
        let photoIdString = NSUUID().uuidString
        let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("posts").child(photoIdString)
        storageRef.putData(data, metadata: nil) { (metadata, error) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            storageRef.downloadURL(completion: {(url, error) in
                if error != nil {
                    return
                }
                else {
                    let photoUrl = url?.absoluteString
                    onSuccess(photoUrl!)
                }
            })
        }
    }
    
    static func sendDataToDatabase(photoUrl: String, videoUrl: String? = nil, ratio: CGFloat, caption: String, onSuccess: @escaping () -> Void ) {
        // Stores photo on Firebase
        let newPostId = Api.Post.REF_POSTS.childByAutoId().key
        let newPostReference = Api.Post.REF_POSTS.child(newPostId!)
        
        guard let currentUser = Api.User.CURRENT_USER else {
            // returns if user is nil
            return
        }
        
        // currentUser must be non-nil to assign currentUserId
        let currentUserId = currentUser.uid
        
        // Divides caption into array of individual words
        let words = caption.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        
        // Identifies hashtags among words
        for var word in words {
            // If word is a hashtag
            if word.hasPrefix("#") {
                // Remove punctuation (node keys can't have # symbol)
                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                // Push the hashtag to the database in lowercase form
                let newHashTagRef = Api.HashTag.REF_HASHTAG.child(word.lowercased()).child(newPostId!)
                newHashTagRef.setValue(true)
            }
        }
        
        // Get timestamp of a post
        let timestamp = Int(Date().timeIntervalSince1970)
        
        var dict = ["uid": currentUserId, "photoUrl": photoUrl, "caption": caption, "likeCount": 0, "ratio": ratio, "timestamp": timestamp ] as [String : Any]
        
        // If videoUrl isn't null
        if let videoUrl = videoUrl {
            dict["videoUrl"] = videoUrl
        }
        
        newPostReference.setValue(dict, withCompletionBlock: {
            (error, ref) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            
            // Links a post to the feed database of the current user once shared
            Api.Feed.REF_FEED.child(Api.User.CURRENT_USER!.uid).child(newPostId!).setValue(true)
            
            //Retrieve followers from the database and store in an array
            Api.Follow.REF_FOLLOWERS.child(Api.User.CURRENT_USER!.uid).observeSingleEvent(of: .value, with: { snapshot in
                let arraySnapshot = snapshot.children.allObjects as! [DataSnapshot]
                arraySnapshot.forEach({ (child) in
                    // For each follower, update their feed to include the post
                    Api.Feed.REF_FEED.child(child.key).updateChildValues(["\(newPostId)": true])
                     // Push notification info to database
                    // Notification -> UserId (all followers of user who posted) -> User who posted -> notification data
                    let newNotificationId = Api.Notification.REF_NOTIFICATION.child(child.key).childByAutoId().key
                    let newNotificationReference = Api.Notification.REF_NOTIFICATION.child(child.key).child(newNotificationId!)
                    // Push notification info to database
                    newNotificationReference.setValue(["from": Api.User.CURRENT_USER!.uid, "type": "feed", "objectId": newPostId, "timestamp": timestamp])
                })
            })
            
            // Adds post to user's posts on database
            let myPostRef = Api.MyPosts.REF_MYPOSTS.child(currentUserId).child(newPostId!)
            myPostRef.setValue(true, withCompletionBlock: { (error, ref) in
                if error != nil {
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
            })
            ProgressHUD.showSuccess("Success")
            onSuccess()
        })
    }
    
}
