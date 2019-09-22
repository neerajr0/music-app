//
//  DetailViewController.swift
//  Music App
//
//  Created by Neeraj Ramachandran on 8/1/19.
//  Copyright © 2019 Neeraj Ramachandran. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var postId = ""
    var post = Post()
    var user = User()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Adjusts table view height to caption length
        tableView.estimatedRowHeight = 530
        tableView.rowHeight = UITableView.automaticDimension
        loadPost()
    }
    
    // Downloads post information
    func loadPost() {
        Api.Post.observePost(withId: postId)  { (post) in
            guard let postUid = post.uid else {
                return
            }
            self.fetchUser(uid: postUid, completed: {
                self.post = post
                self.tableView.reloadData()
            })
        }
    }
    
    func fetchUser(uid: String, completed: @escaping () -> Void) {
        Api.User.observeUser(withId: uid, completion: {
            user in
            self.user = user
            completed()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Detail_CommentVC" {
            let commentVC = segue.destination as!  CommentViewController
            let postId = sender as! String
            commentVC.postId = postId
        }
        if segue.identifier == "Detail_ProfileUserSegue" {
            let profileVC = segue.destination as! ProfileUserViewController
            let userId = sender as! String
            profileVC.userId = userId
        }
        if segue.identifier == "Detail_HashTagSegue" {
            let hashTagVC = segue.destination as! HashTagViewController
            let tag = sender as! String
            hashTagVC.tag = tag
        }
    }
    
}

extension DetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Only need one row
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! HomeTableViewCell
        cell.post = post
        cell.user = user
        cell.delegate = self
        return cell
    }
}

// Extension to adopt delegate protocol for HomeTableViewCell
// HomeTableViewCell represents info from Detail VC
extension DetailViewController: HomeTableViewCellDelegate {
    
    func goToCommentVC(postId: String) {
        // Segue to comment table view when tapping comment button
        performSegue(withIdentifier: "Detail_CommentVC", sender: postId)
    }
    
    func goToProfileUserVC(userId: String) {
        performSegue(withIdentifier: "Detail_ProfileUserSegue", sender: userId)
    }

    func goToHashTag(tag: String) {
        performSegue(withIdentifier: "Detail_HashTagSegue", sender: tag)
    }
}

