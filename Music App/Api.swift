
//
//  Api.swift
//  Music App
//
//  Created by Neeraj Ramachandran on 7/22/19.
//  Copyright © 2019 Neeraj Ramachandran. All rights reserved.
//

import Foundation
struct Api {
    static var User = UserApi()
    static var Post = PostApi()
    static var Comment = CommentApi()
    static var Post_Comment = Post_CommentApi()
    static var MyPosts = MyPostsApi()
    static var Follow = FollowApi()
    static var Feed = FeedApi()
    static var HashTag = HashTagApi()
    static var Notification  = NotificationApi()
}
