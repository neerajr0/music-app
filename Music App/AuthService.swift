//
//  AuthService.swift
//  Music App
//
//  Created by Neeraj Ramachandran on 7/11/19.
//  Copyright © 2019 Neeraj Ramachandran. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
class AuthService{
    
    static func signIn(email: String, password: String, onSuccess: @escaping () -> Void, onError: @escaping(_ errorMessage: String?) -> Void){
        Auth.auth().signIn(withEmail: email, password: password, completion: {(authResult: AuthDataResult?, error: Error?) in
            if error != nil{
                onError(error!.localizedDescription)
                return
            }
            onSuccess()
        })
    }
    
    static func signUp(username: String, email: String, password: String, imageData: Data, onSuccess: @escaping () -> Void, onError: @escaping(_ errorMessage: String?) -> Void){
        Auth.auth().createUser(withEmail: email, password: password, completion: {(authResult: AuthDataResult?, error: Error?) in
            if error != nil{
                onError(error!.localizedDescription)
                return
            }
            
            let uid = authResult?.user.uid
            let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("profile_image").child(uid!)
            
            // Stores profile image to Firebase
            storageRef.putData(imageData, metadata: nil, completion: {(metadata, error) in
                if error != nil{
                    print(error!.localizedDescription)
                    return
                }
                storageRef.downloadURL(completion: {(url, error) in
                    if error != nil{
                        return
                    }
                    else{
                        let profileImageUrl = url?.absoluteString
                        self.setUserInformation(profileImageUrl: profileImageUrl!, username: username, email: email, uid: uid!, onSuccess: onSuccess)
                    }
                })
            })
        })
    }
    
    static func setUserInformation(profileImageUrl: String, username: String, email: String, uid: String, onSuccess: @escaping () -> Void){
        let ref = Database.database().reference()
        let usersReference = ref.child("users")
        let newUserReference = usersReference.child(uid)
        newUserReference.setValue(["username": username, "username_lowercase": username.lowercased(), "email": email, "profileImageUrl": profileImageUrl])
        onSuccess()
    }
    
    // When user information is updated in settings
    static func updateUserInfo(username: String, email: String, imageData: Data, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        
        // Updates authenticating email (so user can log in with new email)
        Api.User.CURRENT_USER?.updateEmail(to: email, completion: { (error) in
            if error != nil {
                onError(error!.localizedDescription)
            } else {
                let uid = Api.User.CURRENT_USER?.uid
                let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("profile_image").child(uid!)
                
                // Stores profile image URL to Firebase
                storageRef.putData(imageData, metadata: nil, completion: {(metadata, error) in
                    if error != nil{
                        print(error!.localizedDescription)
                        return
                    }
                    storageRef.downloadURL(completion: {(url, error) in
                        if error != nil{
                            return
                        }
                        else{
                            let profileImageUrl = url?.absoluteString
                            // Updates database for current user
                            self.updateDatabase(profileImageUrl: profileImageUrl!, username: username, email: email, onSuccess: onSuccess, onError: onError)
                        }
                    })
                })
            }
        })
        

    }
    
    static func updateDatabase(profileImageUrl: String, username: String, email: String, onSuccess: @escaping () -> Void, onError: @escaping(_ errorMessage: String?) -> Void) {
        // Updates the user info for the current user using Firebase updateChildValues method
        let dict = ["username": username, "username_lowercase": username.lowercased(), "email": email, "profileImageUrl": profileImageUrl]
        Api.User.REF_CURRENT_USER?.updateChildValues(dict, withCompletionBlock: { (error, ref) in
            if error != nil {
                onError(error!.localizedDescription)
            } else {
                onSuccess()
            }
        })
    }
    
    static func logout(onSuccess: @escaping () -> Void, onError: @escaping(_ errorMessage: String?) -> Void ) {
        do {
            try Auth.auth().signOut()
            onSuccess()
        } catch let logoutError {
            onError(logoutError.localizedDescription)
        }
    }
} 
