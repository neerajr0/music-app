//
//  UserApi.swift
//  Music App
//
//  Created by Neeraj Ramachandran on 7/22/19.
//  Copyright © 2019 Neeraj Ramachandran. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import Firebase
// Handles database tasks related to users
class UserApi {
    // Firebase reference object pointing to users location
    var REF_USERS = Database.database().reference().child("users")
    
    // Look up a user by username
    func observeUserByUsername(username: String, completion: @escaping (User) -> Void) {
        REF_USERS.queryOrdered(byChild: "username_lowercase").queryEqual(toValue: username).observeSingleEvent(of: .childAdded, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any]{ // Casts snapshot as optional dictionary with string keys
                let user = User.transformUser(dict: dict, key: snapshot.key)
                completion(user)
            }
        })
    }
    
    // Method to look up a user
    func observeUser(withId uid: String, completion: @escaping (User) -> Void){
        // Doesn't listen to modification if we don't scroll the view
        // As opposed to general observe method, which observes all changes
        // of a specific type
        REF_USERS.child(uid).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any]{ // Casts snapshot as optional dictionary with string keys
                let user = User.transformUser(dict: dict, key: snapshot.key)
                completion(user)
            }
        })
    }
    
    // Method to look up current user
    func observeCurrentUser(completion: @escaping (User) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        REF_USERS.child(currentUser.uid).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any]{ // Casts snapshot as optional dictionary with string keys
                let user = User.transformUser(dict: dict, key: snapshot.key)
                completion(user)
            }
        })
    }
    
    func observeUsers(completion: @escaping (User) -> Void) {
        REF_USERS.observe(.childAdded, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any]{ // Casts snapshot as optional dictionary with string keys
                let user = User.transformUser(dict: dict, key: snapshot.key)
                if user.id! != Api.User.CURRENT_USER?.uid {  // Only observes non-current users
                     completion(user)
                }
            }
        })
    }
    
    func queryUsers(withText text: String, completion: @escaping (User) -> Void) {
        // Orders users by lowercase username, prioritized based on text in search bar (queryStarting)
        // Query ending: limits the end of the queried user
        // \u{f8ff} guarantees any word with the text at the beginning will rank lower lexically
        // Ex. ab and abc rank lower than ab with tail, but ac ranks higher than ab with the tail
        // Tail is border in this case: anything beyond that won't satisfy query
        REF_USERS.queryOrdered(byChild: "username_lowercase").queryStarting(atValue: text).queryEnding(atValue: text+"\u{f8ff}").queryLimited(toFirst: 10).observeSingleEvent(of: .value, with: {
            snapshot in
            // Iterator that goes through the users queried
            snapshot.children.forEach({ (s) in
                // Snapshot array element converted into a Firebase snapshot object
                let child = s as! DataSnapshot
                if let dict = child.value as? [String: Any]{ // Casts snapshot as optional dictionary with string keys
                    let user = User.transformUser(dict: dict, key: child.key)
                    completion(user)
                }
            })
        })
    }
    
    var CURRENT_USER: Firebase.User? {
        if let currentUser = Auth.auth().currentUser {
            return currentUser
        }
        return nil
    }
    
    // Firebase reference object pointing to current user
    var REF_CURRENT_USER: DatabaseReference? {
        guard let currentUser = Auth.auth().currentUser else {
            return nil
        }
        return REF_USERS.child(currentUser.uid)
    }
}

