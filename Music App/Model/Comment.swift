//
//  Comment.swift
//  Music App
//
//  Created by Neeraj Ramachandran on 7/20/19.
//  Copyright © 2019 Neeraj Ramachandran. All rights reserved.
//

import Foundation
class Comment {
    var commentText: String?    // Use optionals so anything missing in an initializer will be nil by default
    var uid: String?
}
extension Comment{
    static func transformComment(dict: [String: Any]) -> Comment {
        let comment = Comment()
        comment.commentText = dict["commentText"] as? String
        comment.uid = dict["uid"] as? String
        return comment
    }
    
}
