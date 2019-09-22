//
//  ActivityViewController.swift
//  Music App
//
//  Created by Neeraj Ramachandran on 6/9/19.
//  Copyright © 2019 Neeraj Ramachandran. All rights reserved.
//

import UIKit

class ActivityViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    // Array of notification objects
    var notifications = [Notification]()
    
    // Array of user objects
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadNotifications()
    }
    
    func loadNotifications() {
        guard let currentUser = Api.User.CURRENT_USER else {
            return
        }
        Api.Notification.observeNotification(withId: currentUser.uid, completion: {
            notification in
            guard let uid = notification.from else {
                return
            }
            // Looks up all users at once to prevent database retrieval when scrolling
            // Stores in array of users
            self.fetchUser(uid: uid, completed: {
                // Appends each dictionary to an array of posts (at head, since newest first)
                self.notifications.insert(notification, at: 0)
                // Stops animating the loading indicator
                // self.activityIndicatorView.stopAnimating()
                // Reloads the table view
                self.tableView.reloadData()
            })
        })
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
        if segue.identifier == "Activity_DetailSegue" {
            let detailVC = segue.destination as! DetailViewController
            let postId = sender as! String
            detailVC.postId = postId
        }
        if segue.identifier == "Activity_ProfileSegue" {
            let profileVC = segue.destination as! ProfileUserViewController
            let userId = sender as! String
            profileVC.userId = userId
        }
    }
    
}

extension ActivityViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityTableViewCell", for: indexPath) as! ActivityTableViewCell
        let notification = notifications[indexPath.row]
        let user = users[indexPath.row]
        cell.notification = notification
        cell.user = user
        cell.delegate = self
        return cell
    }
}

extension ActivityViewController: ActivityTableViewCellDelegate {
    func goToDetailVC(postId: String) {
        performSegue(withIdentifier: "Activity_DetailSegue", sender: postId)
    }
    func goToProfileVC(userId: String){
        performSegue(withIdentifier: "Activity_ProfileSegue", sender: userId)
    }
}

