//
//  CommentTableViewCell.swift
//  Music App
//
//  Created by Neeraj Ramachandran on 7/19/19.
//  Copyright © 2019 Neeraj Ramachandran. All rights reserved.
//

import UIKit
import KILabel
protocol CommentTableViewCellDelegate {
    func goToProfileUserVC(userId: String)
    func goToHashTag(tag: String)
}

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var commentLabel: KILabel!
    
    var delegate: CommentTableViewCellDelegate?
   
    var comment: Comment?{
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
        commentLabel.text = comment?.commentText
        
        // When a hashtag is tapped
        commentLabel.hashtagLinkTapHandler = { label, string, range in
            // Drop first character of hashtag
            let tag = String(string.dropFirst())
            self.delegate?.goToHashTag(tag: tag)
        }
        
        // When a username mention is tapped
        commentLabel.userHandleLinkTapHandler = { label, string, range in
            // Drop first character of hashtag
            let mention = String(string.dropFirst())
            Api.User.observeUserByUsername(username: mention.lowercased(), completion: { (user) in
                self.delegate?.goToProfileUserVC(userId: user.id!)
            })
        }
        
    }
    
    func setupUserInfo() {
        nameLabel.text = user?.username
        if let photoUrlString = user?.profileImageUrl {
            let photoUrl = URL(string: photoUrlString)
            profileImageView.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "https___au.junkfreejune.org_themes_base_production_images_default-profile"))
        }       
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Clears name label and comment text
        // When cell has been loaded from memory
        nameLabel.text = ""
        commentLabel.text = ""
        // Tap gesture for name label
        let tapGestureForNameLabel = UITapGestureRecognizer(target: self, action: #selector(self.nameLabel_TouchUpInside))
        nameLabel.addGestureRecognizer(tapGestureForNameLabel)
        nameLabel.isUserInteractionEnabled = true
    }
    
    // Segues to user view when a name label is selected
    @objc func nameLabel_TouchUpInside() {
        if let id = user?.id {
            delegate?.goToProfileUserVC(userId: id)
        }
    }
    
    override func prepareForReuse() {
        // erases all old data before a cell is reused
        // Called before dequeuing cell, so good place to get rid of old data
        super.prepareForReuse()
        profileImageView.image = UIImage(named: "https___au.junkfreejune.org_themes_base_production_images_default-profile")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
