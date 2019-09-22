//
//  ActivityTableViewCell.swift
//  Music App
//
//  Created by Neeraj Ramachandran on 8/7/19.
//  Copyright © 2019 Neeraj Ramachandran. All rights reserved.
//

import UIKit

protocol ActivityTableViewCellDelegate {
    func goToDetailVC(postId: String)
    func goToProfileVC(userId: String)
}

class ActivityTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var photo: UIImageView!
    
    var delegate: ActivityTableViewCellDelegate?
    
    var notification: Notification?{
        didSet{
            // Eliminates need to pass post in as input to updateView
            // If this variable is set, then updateView is called
            updateView()
        }
    }
    
    var user : User? {
        didSet{
            // If this variable is set, then setupUserInfo() is called
            setupUserInfo()
        }
    }
    
    func updateView() {
        switch notification!.type! {
        case "feed":
            descriptionLabel.text = "added a new post"
            let postId = notification!.objectId!
            Api.Post.observePost(withId: postId, completion: {(post) in
                if let photoUrlString = post.photoUrl {
                    let photoUrl = URL(string: photoUrlString)
                    self.photo.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "https___au.junkfreejune.org_themes_base_production_images_default-profile"))
                }
            })
        case "follow":
            descriptionLabel.text = "followed you"
            self.photo.isHidden = true
        case "like":
            descriptionLabel.text = "liked your post"
            let postId = notification!.objectId!
            Api.Post.observePost(withId: postId, completion: {(post) in
                if let photoUrlString = post.photoUrl {
                    let photoUrl = URL(string: photoUrlString)
                    self.photo.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "https___au.junkfreejune.org_themes_base_production_images_default-profile"))
                }
            })
        default:
            print("")
        }
        
        if let timestamp = notification?.timestamp {
            let timestampDate = Date(timeIntervalSince1970: Double(timestamp))
            let now = Date()
            let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .weekOfMonth])
            let diff = Calendar.current.dateComponents(components, from: timestampDate, to: now )
            
            var timeText = ""
            
            // if a post was created less than a second ago
            if diff.second! <= 0 {
                timeText = "Now"
            }
            // If a post was created less than a minute ago
            if diff.second! > 0 && diff.minute! == 0 {
                timeText = "\(diff.second!)s"
            }
            // If a post was created less than an hour ago
            if diff.minute! > 0 && diff.hour! == 0 {
                timeText = "\(diff.minute!)m"
            }
            // If a post was created less than a day ago
            if diff.hour! > 0 && diff.day! == 0 {
                timeText = "\(diff.hour!)h"
            }
            // If a post was created less than a week ago
            if diff.day! > 0 && diff.weekOfMonth! == 0 {
                timeText = "\(diff.day!)d"
            }
            // If a post was created less than a month ago
            if diff.weekOfMonth! > 0 {
                timeText = "\(diff.weekOfMonth!)w"
            }
            
            timeLabel.text = timeText
            
        }
        
        // Tap Gesture recognizer for photo to segue to Detail VC
        let tapGestureForPhoto = UITapGestureRecognizer(target: self, action: #selector(self.cell_TouchUpInside))
        addGestureRecognizer(tapGestureForPhoto)
        isUserInteractionEnabled = true
        
    }
    
    // Segues to Detail VC or Profile VC
    @objc func cell_TouchUpInside() {
        if notification!.type! == "like" {
            delegate?.goToProfileVC(userId: notification!.from!)
            return
        }
        if let id = notification?.objectId {
            if notification!.type! == "follow" {
                delegate?.goToProfileVC(userId: id)
            }
            else {
                delegate?.goToDetailVC(postId: id)
            }
        }
    }
    
    func setupUserInfo() {
        nameLabel.text = user?.username
        // Retrieves user info
        if let photoUrlString = user?.profileImageUrl {
            let photoUrl = URL(string: photoUrlString)
            profileImage.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "https___au.junkfreejune.org_themes_base_production_images_default-profile"))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
