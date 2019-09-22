//
//  ProfileUserViewController.swift
//  Music App
//
//  Created by Neeraj Ramachandran on 7/28/19.
//  Copyright © 2019 Neeraj Ramachandran. All rights reserved.
//

import UIKit
// Profile of another user
class ProfileUserViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var user: User!
    var posts: [Post] = []
    // User id of selected user
    var userId = ""
    var delegate: HeaderProfileCollectionReusableViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        // Applies height/width configuration to collection view
        collectionView.delegate = self
        fetchUser()
        fetchMyPosts()
    }
    
    func fetchUser() {
        Api.User.observeUser(withId: userId) {
            (user) in
            self.isFollowing(userId: user.id!, completed: {
                (value) in
                user.isFollowing = value
                // Sets instance user to observed user
                self.user = user
                // Sets title of view to username
                self.navigationItem.title = user.username
                self.collectionView.reloadData()
            })
        }
    }
    
    // Checks if current user is in list of followers of input user
    func isFollowing(userId: String, completed: @escaping (Bool) -> Void) {
        Api.Follow.isFollowing(userId: userId, completed: completed)
    }
    
    func fetchMyPosts() {
        Api.MyPosts.fetchMyPosts(userId: userId) { (key) in
            // Look up corresponding post
            Api.Post.observePost(withId: key, completion: {
                post in
                self.posts.append(post)
                // Reloads table view to display posts that were just queried
                self.collectionView.reloadData()
            })
        }
    }
    
    // Prepares the profile user VC for a segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // to Detail VC
        if segue.identifier == "ProfileUser_DetailSegue" {
            let detailVC = segue.destination as!  DetailViewController
            let postId = sender as! String
            detailVC.postId = postId
        }
    }
}

// Allows controller to adopt collection view data source protocol
extension ProfileUserViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Number of posts
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        let post = posts[indexPath.row]
        cell.post = post
        // The information displayed on the cell comes from Profile User VC
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerViewCell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderProfileCollectionReusableView", for: indexPath) as! HeaderProfileCollectionReusableView
        // Prevents assignment of user to nil
        if let user = self.user {
            headerViewCell.user = user
            // Assigns the delegate of the header profile to the delegate of
            // the profile user view controller
            headerViewCell.delegate = self.delegate
            // Assigns the current VC as the second delegate of the header profile
            headerViewCell.delegate2 = self
        }
        return headerViewCell
    }
}

extension ProfileUserViewController:HeaderProfileCollectionReusableViewDelegateSwitchSettingVC {
    func goToSettingVC() {
        performSegue(withIdentifier: "ProfileUser_SettingSegue", sender: nil)
    }
}

extension ProfileUserViewController: UICollectionViewDelegateFlowLayout {
    
    // Specifies spacing between rows of the collection view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    // Specifies spacing between cells in a row
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // Sets width and height of cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Sets width to 1/3 of screen width
        return CGSize(width: collectionView.frame.size.width / 3 - 1, height: collectionView.frame.size.width / 3 - 1)
    }
}

extension ProfileUserViewController: PhotoCollectionViewCellDelegate {
    func goToDetailVC(postId: String) {
        performSegue(withIdentifier: "ProfileUser_DetailSegue", sender: postId)
    }
}

