//
//  HomeViewController.swift
//  Music App
//
//  Created by Neeraj Ramachandran on 6/9/19.
//  Copyright © 2019 Neeraj Ramachandran. All rights reserved.
//

import UIKit
import SDWebImage
class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    var posts = [Post]()
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Adjusts table view height to caption length
        tableView.estimatedRowHeight = 530
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = self
        loadPosts()
    }
    
    func loadPosts(){
        
        // Adds all posts of current user to feed
        Api.Feed.observeFeed(withId: Api.User.CURRENT_USER!.uid) {
            (post) in
            guard let postUid = post.uid else {
                // Overlooks posts on database that don't have a uid
                return
            }
            // Looks up all users at once to prevent database retrieval when scrolling
            // Stores in array of users
            self.fetchUser(uid: postUid, completed: {
                // Appends each dictionary to an array of posts (at head, since newest first)
                self.posts.insert(post, at: 0)
                // Stops animating the loading indicator
                // self.activityIndicatorView.stopAnimating()
                // Reloads the table view
                self.tableView.reloadData()
            })
        }
        
        // Removes posts of an unfollowed user from the feed
        Api.Feed.observeFeedRemoved(withId: Api.User.CURRENT_USER!.uid) {
            (post) in
            self.posts = self.posts.filter { $0.id != post.id } // Keeps posts in the array whose id != remove post id
            self.users = self.users.filter { $0.id != post.uid} // Keeps users in the array whose id != remove post uid
            // Reloads the table view
            self.tableView.reloadData()
        }
    }
    
    func fetchUser(uid: String, completed: @escaping () -> Void) {
        Api.User.observeUser(withId: uid, completion: {
            user in
            self.users.insert(user, at: 0)
            // We only want to append a new post and reload the table view
            // After we've appended a new user to the user's array
            completed()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CommentSegue" {
            let commentVC = segue.destination as!  CommentViewController
            let postId = sender as! String
            commentVC.postId = postId
        }
        if segue.identifier == "Home_ProfileSegue" {
            let profileVC = segue.destination as! ProfileUserViewController
            let userId = sender as! String
            profileVC.userId = userId
        }
        if segue.identifier == "Home_HashTagSegue" {
            let hashTagVC = segue.destination as! HashTagViewController
            let tag = sender as! String
            hashTagVC.tag = tag
        }
        
    }
}
extension HomeViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! HomeTableViewCell
        let post = posts[indexPath.row]
        let user = users[indexPath.row]
        cell.post = post
        cell.user = user
        cell.delegate = self
        return cell
    }
}
// Extension to adopt delegate protocol for HomeTableViewCell
// HomeTableViewCell represents info from Home VC
extension HomeViewController: HomeTableViewCellDelegate {
    
    func goToCommentVC(postId: String) {
        // Segue to comment table view when tapping comment button
        performSegue(withIdentifier: "CommentSegue", sender: postId)
    }
    
    func goToProfileUserVC(userId: String) {
        performSegue(withIdentifier: "Home_ProfileSegue", sender: userId)
    }
    
    func goToHashTag(tag: String) {
        performSegue(withIdentifier: "Home_HashTagSegue", sender: tag)
    }
}
