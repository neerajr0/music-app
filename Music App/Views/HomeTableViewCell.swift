//
//  HomeTableViewCell.swift
//  Music App
//
//  Created by Neeraj Ramachandran on 7/17/19.
//  Copyright © 2019 Neeraj Ramachandran. All rights reserved.
//

import UIKit
import AVFoundation
import KILabel
protocol HomeTableViewCellDelegate {
    func goToCommentVC(postId: String)
    func goToProfileUserVC(userId: String)
    func goToHashTag(tag: String)
}

class HomeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var commentImageView: UIImageView!
    @IBOutlet weak var shareImageView: UIImageView!
    @IBOutlet weak var likeCountButton: UIButton!
    @IBOutlet weak var captionLabel: KILabel!
    @IBOutlet weak var heightConstraintPhoto: NSLayoutConstraint!
    @IBOutlet weak var volumeView: UIView!
    @IBOutlet weak var volumeButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    var delegate: HomeTableViewCellDelegate?
    // To play a video
    var player: AVPlayer?
    // Specifies how video should display on screen
    var playerLayer: AVPlayerLayer?
    
    var post: Post?{
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
    
    var isMuted = true
    
    func updateView(){
        captionLabel.text = post?.caption
        // When a hashtag is tapped
        captionLabel.hashtagLinkTapHandler = { label, string, range in
            // Drop first character of hashtag
            let tag = String(string.dropFirst())
            self.delegate?.goToHashTag(tag: tag)
        }
        
        // When a username mention is tapped
        captionLabel.userHandleLinkTapHandler = { label, string, range in
            // Drop first character of hashtag
            let mention = String(string.dropFirst())
            Api.User.observeUserByUsername(username: mention.lowercased(), completion: { (user) in
                self.delegate?.goToProfileUserVC(userId: user.id!)
            })
        }
        
        // Sets constraint height of post photo to height of the image
        if let ratio = post?.ratio {
            heightConstraintPhoto?.constant = UIScreen.main.bounds.width / ratio
            // Immediately updates frames
            layoutIfNeeded()
        }
        
        // Converts post URL to actual image
        if let photoUrlString = post?.photoUrl {
            let photoUrl = URL(string: photoUrlString)
            postImageView.sd_setImage(with: photoUrl, completed: nil)
        }
        if let videoUrlString = post?.videoUrl, let videoUrl = URL(string: videoUrlString) {
            // Shows volume view when post is a video
            self.volumeView.isHidden = false
            player = AVPlayer(url: videoUrl)
            playerLayer = AVPlayerLayer(player: player)
            // Renders video frame to that of the thumbnail
            playerLayer?.frame = postImageView.frame
            // Sets frame width to screen width to match storyboard constraints
            playerLayer?.frame.size.width = UIScreen.main.bounds.width
            // Adds layer as sublayer of cell
            self.contentView.layer.addSublayer(playerLayer!)
            // Puts volume view on top of video layer
            self.volumeView.layer.zPosition = 1
            player?.play()
            player?.isMuted = isMuted
        }
        
        if let timestamp = post?.timestamp {
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
        
        // Ensures reused cells are fed up-to-date data
        // By updating the self post instance
        self.updateLike(post: self.post!)
    
    }
    
    @IBAction func volumeBtn_TouchUpInside(_ sender: UIButton) {
        if isMuted {
            // Player is currently muted
            isMuted = !isMuted
            // Sets button image to volume icon
            volumeButton.setImage(UIImage(named: "volume"), for: UIControl.State.normal)
        } else {
            // Player is currently unmuted
            isMuted = !isMuted
            // Sets button image to mute icon
            volumeButton.setImage(UIImage(named: "mute"), for: UIControl.State.normal)
        }
        player?.isMuted = isMuted
    }
    
    func updateLike(post: Post){
        // If there is no likes node on the database for that post (post.likes = nil)
        // or if the post has not been liked by that user,
        // make like button unselected, otherwise make it selected
        let imageName = post.likes == nil || !post.isLiked! ? "heart_unselect_small" : "heart_red"
        likeImageView.image  = UIImage(named: imageName)
        // Sets custom text for number of likes
        guard let count = post.likeCount else {
            return
        }
        if count == 0 {
            likeCountButton.setTitle("Be the first to like this", for: UIControl.State.normal)
        }
        else if count == 1 {
            likeCountButton.setTitle("\(count) like", for: UIControl.State.normal)
        }
        else {
            likeCountButton.setTitle("\(count) likes", for: UIControl.State.normal)
        }
    }
    
    func setupUserInfo() {
        // Retrieves user info
        nameLabel.text = user?.username
        if let photoUrlString = user?.profileImageUrl {
            let photoUrl = URL(string: photoUrlString)
            profileImageView.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "https___au.junkfreejune.org_themes_base_production_images_default-profile"))
        }        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Placeholder text for name label
        // Only called when cell loads from memory
        nameLabel.text = ""
        captionLabel.text = ""
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.commentImageView_TouchUpInside))
        commentImageView.addGestureRecognizer(tapGesture)
        commentImageView.isUserInteractionEnabled = true
        
        let tapGestureForLikeImageView = UITapGestureRecognizer(target: self, action: #selector(self.likeImageView_TouchUpInside))
        likeImageView.addGestureRecognizer(tapGestureForLikeImageView)
        likeImageView.isUserInteractionEnabled = true
       
        let tapGestureForNameLabel = UITapGestureRecognizer(target: self, action: #selector(self.nameLabel_TouchUpInside))
        nameLabel.addGestureRecognizer(tapGestureForNameLabel)
        nameLabel.isUserInteractionEnabled = true
        
    }
    
    // Segues to user view when a user is selected
    @objc func nameLabel_TouchUpInside() {
        if let id = user?.id {
            delegate?.goToProfileUserVC(userId: id)
        }
    }
    
    @objc func likeImageView_TouchUpInside() {
        Api.Post.incrementLikes(postId: post!.id!, onSuccess: { (post) in
            self.updateLike(post: post)
            self.post?.likes = post.likes
            self.post?.isLiked = post.isLiked
            self.post?.likeCount = post.likeCount
            if post.uid != Api.User.CURRENT_USER?.uid {
                let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
                
                if post.isLiked! {
                    let newNotificationReference = Api.Notification.REF_NOTIFICATION.child(post.uid!).child(Api.User.CURRENT_USER!.uid)
                    newNotificationReference.setValue(["from": Api.User.CURRENT_USER!.uid, "objectId": post.id!, "type": "like", "timestamp": timestamp])
                } else {
                    let newNotificationReference = Api.Notification.REF_NOTIFICATION.child(post.uid!).child("\(post.id!)-\(Api.User.CURRENT_USER!.uid)")
                    newNotificationReference.removeValue()
                }
                
            }
        }) { (errorMessage) in
            ProgressHUD.showError(errorMessage)
        }
        
    }
    
    @objc func commentImageView_TouchUpInside() {
        if let id = post?.id {
            // Invoke protocol method to switch view
            delegate?.goToCommentVC(postId: id)
        }
    }
    
    override func prepareForReuse() {
        // erases all old data before a cell is reused
        // Called before dequeuing cell, so good place to get rid of old data
        super.prepareForReuse()
        // Hides volume view
        volumeView.isHidden = true
        profileImageView.image = UIImage(named: "https___au.junkfreejune.org_themes_base_production_images_default-profile")
        // Removes the player layer from the cell right before dequeuing it
        playerLayer?.removeFromSuperlayer()
        // Pauses video before dequeuing cell for reuse
        player?.pause()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
