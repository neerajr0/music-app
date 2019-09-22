//
//  SearchViewController.swift
//  Music App
//
//  Created by Neeraj Ramachandran on 7/27/19.
//  Copyright © 2019 Neeraj Ramachandran. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    var searchBar = UISearchBar()
    // User array to cache searched users
    var users: [User] = []
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Sets SearchViewController as delegate of search bar
        searchBar.delegate = self
        
        // Configures search bar
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search"
        // Sets width of search bar to 60 pts less than screen width
        searchBar.frame.size.width = view.frame.size.width  - 60
        
        // Sets search bar as right button item
        let searchItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.rightBarButtonItem = searchItem
        
        // Default search to show users that view is loaded
        doSearch()
    }
    
    func doSearch() {
        if let searchText  = searchBar.text?.lowercased() {
            // Search results only contain newly queried users
            self.users.removeAll()
            self.tableView.reloadData()
            Api.User.queryUsers(withText: searchText, completion: { (user) in
                // Checks is current user is following queried user
                self.isFollowing(userId: user.id!, completed: {
                    (value) in
                    user.isFollowing = value
                    // Caches every user in a user array
                    self.users.append(user)
                    self.tableView.reloadData()
                })
            })
        }
    }
    
    func isFollowing(userId: String, completed: @escaping (Bool) -> Void) {
        Api.Follow.isFollowing(userId: userId, completed: completed)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Search_ProfileSegue" {
            let profileVC = segue.destination as! ProfileUserViewController
            let userId = sender as! String
            profileVC.userId = userId
            profileVC.delegate = self
        }
    }
    
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        doSearch()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        doSearch()
    }
}

extension SearchViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleTableViewCell", for: indexPath) as! PeopleTableViewCell
        // Extracts user at row of index path
        let user = users[indexPath.row]
        // Sets user property of cell to this user
        cell.user = user
        // Sets SearchViewController as delegate of cell
        cell.delegate = self
        return cell
    }
}

extension SearchViewController: PeopleTableViewCellDelegate {
    func goToProfileUserVC(userId: String) {
        performSegue(withIdentifier: "Search_ProfileSegue", sender: userId)
    }
}

extension SearchViewController: HeaderProfileCollectionReusableViewDelegate {
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
