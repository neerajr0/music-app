//
//  PhotoCollectionViewCell.swift
//  Music App
//
//  Created by Neeraj Ramachandran on 7/23/19.
//  Copyright © 2019 Neeraj Ramachandran. All rights reserved.
//

import UIKit
protocol PhotoCollectionViewCellDelegate {
    func goToDetailVC(postId: String)
}

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photo: UIImageView!
    
    // Delegate to transition to profile user VC
    var delegate: PhotoCollectionViewCellDelegate?
    
    var post: Post?{
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        // Converts post URL to actual image
        // Saves memory by downloading images from URLs
        // Right inside cells
        if let photoUrlString = post?.photoUrl {
            let photoUrl = URL(string: photoUrlString)
            photo.sd_setImage(with: photoUrl, completed: nil)
        }
        // Tap Gesture recognizer for photo to segue to Detail VC
        let tapGestureForPhoto = UITapGestureRecognizer(target: self, action: #selector(self.photo_TouchUpInside))
        photo.addGestureRecognizer(tapGestureForPhoto)
        photo.isUserInteractionEnabled = true
    }
    
    @objc func photo_TouchUpInside() {
        if let id = post?.id {
            delegate?.goToDetailVC(postId: id)
        }
    }
}
