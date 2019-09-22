//
//  ProfileViewController.swift
//  Music App
//
//  Created by Neeraj Ramachandran on 6/9/19.
//  Copyright © 2019 Neeraj Ramachandran. All rights reserved.
//

import UIKit
// Profile of the current user
class ProfileViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var user: User!
    var posts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Configures collection view, cells, and header
        collectionView.dataSource = self
        // Applies height/width configuration to collection view
        collectionView.delegate = self
        fetchUser()
        fetchMyPosts()
    }
    
    func fetchUser() {
        Api.User.observeCurrentUser { (user) in
            self.user = user
            // Sets title of view to username
            self.navigationItem.title = user.username
            self.collectionView.reloadData()
        }
    }
    
    func fetchMyPosts() {
        guard let currentUser = Api.User.CURRENT_USER else {
            return
        }
        // Observe any new posts shared by current user
        Api.MyPosts.REF_MYPOSTS.child(currentUser.uid).observe(.childAdded, with: {
            snapshot in
            // Look up corresponding post
            Api.Post.observePost(withId: snapshot.key, completion: {
                post in
                self.posts.append(post)
                // Reloads table view to display posts that were just queried
                self.collectionView.reloadData()
            })
        })
    }
    
    // Prepares the profile VC for a segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // to Setting VC
        if segue.identifier == "Profile_SettingSegue" {
            let settingVC = segue.destination as!  SettingTableViewController
            settingVC.delegate = self
        }
        // or to Detail VC
        if segue.identifier == "Profile_DetailSegue" {
            let detailVC = segue.destination as!  DetailViewController
            let postId = sender as! String
            detailVC.postId = postId
        }
    }
    
}

// Allows controller to adopt collection view data source protocol
extension ProfileViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Number of posts
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        let post = posts[indexPath.row]
        cell.post = post
        // The information displayed on the cell comes from
        // Profile VC
        cell.delegate = self
        return cell
    }
    
    // Feeds data to header
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerViewCell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderProfileCollectionReusableView", for: indexPath) as! HeaderProfileCollectionReusableView
        // Prevents assignment of user to nil
        if let user = self.user {
            headerViewCell.user = user
            headerViewCell.delegate2 = self
        }
        return headerViewCell
    }
    
}

extension ProfileViewController: HeaderProfileCollectionReusableViewDelegateSwitchSettingVC {
    
    func goToSettingVC() {
        performSegue(withIdentifier: "Profile_SettingSegue", sender: nil)
    }
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    
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

// Extension for profile to implement Setting Table VC protocol
extension ProfileViewController: SettingTableViewControllerDelegate {
    func updateUserInfo() {
        self.fetchUser()
    }
}

// Extension for profile to implement Photo Collection View Cell protocol
extension ProfileViewController: PhotoCollectionViewCellDelegate {
    func goToDetailVC(postId: String) {
        performSegue(withIdentifier: "Profile_DetailSegue", sender: postId)
    }
}
