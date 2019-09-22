//
//  PeopleViewController.swift
//  Music App
//
//  Created by Neeraj Ramachandran on 7/24/19.
//  Copyright © 2019 Neeraj Ramachandran. All rights reserved.
//

import UIKit

class PeopleViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var users: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUsers()
    }
    
    func loadUsers() {
        Api.User.observeUsers { (user) in
            self.isFollowing(userId: user.id!, completed: {
                (value) in
                user.isFollowing = value
                // Caches every user in a user array
                self.users.append(user)
                self.tableView.reloadData()
            })
        }
    }
    
    // Checks if current user is in list of followers of input user
    func isFollowing(userId: String, completed: @escaping (Bool) -> Void) {
        Api.Follow.isFollowing(userId: userId, completed: completed)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProfileSegue" {
            let profileVC = segue.destination as!  ProfileUserViewController
            let userId = sender as! String
            profileVC.userId = userId
            // NOTE: For any view that wants to know about follow stuff
            // in profile header, simply let that VC implement the header protocol
            // then set it to the delegate of profile
            profileVC.delegate = self
        }
    }
    
}
extension PeopleViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleTableViewCell", for: indexPath) as! PeopleTableViewCell
        // Extracts user at row of index path
        let user = users[indexPath.row]
        // Sets user property of cell to this user
        cell.user = user
        // Sets the PeopleTableView's delegate to the current cell
        cell.delegate = self
        return cell
    }
}

extension PeopleViewController: PeopleTableViewCellDelegate {
    func goToProfileUserVC(userId: String) {
        performSegue(withIdentifier: "ProfileSegue", sender: userId)
    }
}

extension PeopleViewController: HeaderProfileCollectionReusableViewDelegate {
    // Implements protocol of the delegate HeaderProfileCollectionReusableViewDelegate
    func updateFollowButton(forUser user: User) {
        // user is the user we got aftwer switching from people view to profile
        for u in self.users {
            // Is the user the input user of the method?
            if u.id == user.id {
                u.isFollowing = user.isFollowing
                self.tableView.reloadData()
            }
        }
    }
}
