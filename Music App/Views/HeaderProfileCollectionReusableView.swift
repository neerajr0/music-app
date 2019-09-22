//
//  HeaderProfileCollectionReusableView.swift
//  Music App
//
//  Created by Neeraj Ramachandran on 7/23/19.
//  Copyright © 2019 Neeraj Ramachandran. All rights reserved.
//

import UIKit
protocol HeaderProfileCollectionReusableViewDelegate {
    func updateFollowButton(forUser user: User)
}

protocol HeaderProfileCollectionReusableViewDelegateSwitchSettingVC {
    func goToSettingVC()
}

// Header of the profile user view (not the profile page)
class HeaderProfileCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var myPostsCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    // Need a delegate for each protocol
    var delegate: HeaderProfileCollectionReusableViewDelegate?
    var delegate2: HeaderProfileCollectionReusableViewDelegateSwitchSettingVC?
    
    var user: User? {
        didSet {
            updateView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        clear()
    }
    
    func updateView() {
        // Queries and displays current user information
        self.nameLabel.text = user!.username
        if let photoUrlString = user!.profileImageUrl {
            let photoUrl = URL(string: photoUrlString)
            self.profileImage.sd_setImage(with: photoUrl, completed: nil)
        }
        
        Api.MyPosts.fetchCountMyPosts(userId: user!.id!) { (count) in
            // Updates the post count for the user
            self.myPostsCountLabel.text = "\(count)"
        }
        
        Api.Follow.fetchCountFollowers(userId: user!.id!) { (count) in
            // Updates the follower count for the user
            self.followersCountLabel.text = "\(count)"
        }
        
        Api.Follow.fetchCountFollowing(userId: user!.id!) { (count) in
            // Updates the following count for the user
            self.followingCountLabel.text = "\(count)"
        }
        
        // If the user is the current user
        if user?.id == Api.User.CURRENT_USER?.uid {
            // Make the button say Edit Profile
            followButton.setTitle("Edit Profile", for: UIControl.State.normal)
            // Allows for segue to setting VC
            followButton.addTarget(self, action: #selector(self.goToSettingVC), for: UIControl.Event.touchUpInside)
        } else {
            // Otherwise change the button to say follow/following
            updateStateFollowButton()
        }
    }
    
    func clear() {
         // Clears default text labels
        self.nameLabel.text = ""
        self.myPostsCountLabel.text = ""
        self.followingCountLabel.text = ""
        self.followersCountLabel.text = ""
    }
    
    @objc func goToSettingVC() {
        delegate2?.goToSettingVC()
    }
    
    func updateStateFollowButton() {
        // Keeps button up-to-date when cell is reused
        if user!.isFollowing! {
            configureUnfollowButton()
        } else {
            configureFollowButton()
        }
    }
    
    func configureFollowButton() {
        // UI Elements of follow button
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor(red: 226/255, green: 228/255, blue: 232.255, alpha: 1).cgColor
        followButton.layer.cornerRadius = 5
        followButton.clipsToBounds = true
        followButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        followButton.backgroundColor = UIColor(red: 69/255, green: 142/255, blue: 255/255, alpha: 1)
        
        // Updates button to say follow
        self.followButton.setTitle("Follow", for: UIControl.State.normal)
        // Updates database if follow is pressed
        followButton.addTarget(self, action: #selector(self.followAction), for: UIControl.Event.touchUpInside)
    }
    
    func configureUnfollowButton() {
        // UI Elements of following button
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor(red: 226/255, green: 228/255, blue: 232.255, alpha: 1).cgColor
        followButton.layer.cornerRadius = 5
        followButton.clipsToBounds = true
        followButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
        followButton.backgroundColor = UIColor.clear
        
        // Updates button to say following
        self.followButton.setTitle("Following", for: UIControl.State.normal)
        // Updates database if following is pressed (i.e. unfollows)
        followButton.addTarget(self, action: #selector(self.unfollowAction), for: UIControl.Event.touchUpInside)
    }
    
    @objc func followAction() {
        // When follow is pressed
        // Updates cell user right after tapping the button, avoiding lag
        if user!.isFollowing! == false {
            Api.Follow.followAction(withUser: user!.id!)
            configureUnfollowButton()
            user!.isFollowing! = true
            // Updates PeopleTableViewCell to change following status
            // By using a delegate
            delegate?.updateFollowButton(forUser: user!)
        }
    }
    
    @objc func unfollowAction() {
        // When following is pressed
        // Updates cell user right after tapping the button, avoiding lag
        if user!.isFollowing! == true {
            Api.Follow.unfollowAction(withUser: user!.id!)
            configureFollowButton()
            user!.isFollowing! = false
            // Updates PeopleTableViewCell to change following status
            // By using a delegate
            delegate?.updateFollowButton(forUser: user!)
        }
    }
}

