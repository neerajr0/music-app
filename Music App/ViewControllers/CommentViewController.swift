//
//  CommentViewController.swift
//  Music App
//
//  Created by Neeraj Ramachandran on 7/19/19.
//  Copyright © 2019 Neeraj Ramachandran. All rights reserved.
//

import UIKit
class CommentViewController: UIViewController {

    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var constraintToBottom: NSLayoutConstraint!
    
    var postId: String!
    var comments = [Comment]()
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Comment"
        tableView.dataSource = self
        tableView.estimatedRowHeight = 77
        tableView.rowHeight = UITableView.automaticDimension
        empty()
        handleTextField()
        loadComments()
        // Prevents keyboard from hiding text field
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        // Notifies comment view controller when keyboard is dismissed
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Shows keyboard when touches begin
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        // Specifies what the listener (i.e. comment view controller) should do after receiving notification
        let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        UIView.animate(withDuration: 0.3) {
            // Moves the comment view up to the height of the keyboard frame
            self.constraintToBottom.constant = keyboardFrame!.height
            // Forces layout after adjusting view
            self.view.layoutIfNeeded()
        }
        
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            // Moves the comment view back down
            self.constraintToBottom.constant = 0
            // Forces layout after adjusting view
            self.view.layoutIfNeeded()
        }
    }
    
    func loadComments() {
        // Observes the addition of a comment to a post
        Api.Post_Comment.REF_POST_COMMENTS.child(self.postId).observe(.childAdded, with: {
            snapshot in
            
            Api.Comment.observeComments(withPostId: snapshot.key, completion: {
                comment in
                // Looks up all users at once to prevent database retrieval when scrolling
                // Stores in array of users
                self.fetchUser(uid: comment.uid!, completed: {
                    // Appends each dictionary to an array of posts
                    self.comments.append(comment)
                    // Reloads the table view
                    self.tableView.reloadData()
                })
            })
        })
    }
    
    func fetchUser(uid: String, completed: @escaping () -> Void) {
        
        Api.User.observeUser(withId: uid, completion: {
            user in
            self.users.append(user)
            // We only want to append a new post and reload the table view
            // After we've appended a new user to the user's array
            completed()
        })
    }
    
    func handleTextField() {
        // Ensure text fields are filled out
        commentTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControl.Event.editingChanged)
    }
    
    // Highlights send button if each text field contains text
    @objc func textFieldDidChange(){
        if let commentText = commentTextField.text, !commentText.isEmpty {
            // If there is text in the comment field
            sendButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
            sendButton.isEnabled = true
            return
        }
        // If there isn't text in the comment field
        sendButton.setTitleColor(UIColor.lightGray, for: UIControl.State.normal)
        sendButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hides tab bar in comment view
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    @IBAction func sendButton_TouchUpInside(_ sender: Any) {
        // Stores comment on Database
        let commentsReference = Api.Comment.REF_COMMENTS
        let newCommentId = commentsReference.childByAutoId().key
        let newCommentReference = commentsReference.child(newCommentId!)
        guard let currentUser = Api.User.CURRENT_USER else {
            // returns if user is nil
            return
        }
        // currentUser must be non-nil to assign currentUserId
        let currentUserId = currentUser.uid
        newCommentReference.setValue(["uid": currentUserId,  "commentText": commentTextField.text!], withCompletionBlock: {
            (error, ref) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            
            // Divides comment into array of individual words
            let words = self.commentTextField.text!.components(separatedBy: CharacterSet.whitespacesAndNewlines)
            
            // Identifies hashtags among words
            for var word in words {
                // If word is a hashtag
                if word.hasPrefix("#") {
                    // Remove punctuation (node keys can't have # symbol)
                    word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                    // Push the hashtag to the database in lowercase form
                    let newHashTagRef = Api.HashTag.REF_HASHTAG.child(word.lowercased()).child(self.postId)
                    newHashTagRef.setValue(true)
                }
            }
            
            // Creates a child reference of the post in the post-to-comments root database
            let postCommentRef = Api.Post_Comment.REF_POST_COMMENTS.child(self.postId).child(newCommentId!)
            postCommentRef.setValue(true, withCompletionBlock: { (error, ref) in
                if error != nil {
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
            })
            // Clears comment input if there is no error
            self.empty()
            // Hides keyboard
            self.view.endEditing(true)
        })
    }
    
    func empty() {
        self.commentTextField.text = ""
        self.sendButton.isEnabled = false
        sendButton.setTitleColor(UIColor.lightGray, for: UIControl.State.normal)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Comment_ProfileSegue" {
            let profileVC = segue.destination as! ProfileUserViewController
            let userId = sender as! String
            profileVC.userId = userId
        }
        
        if segue.identifier == "Comment_HashTagSegue" {
            let hashTagVC = segue.destination as! HashTagViewController
            let tag = sender as! String
            hashTagVC.tag = tag
        }
    }
}

extension CommentViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentTableViewCell
        let comment = comments[indexPath.row]
        let user = users[indexPath.row]
        cell.comment = comment
        cell.user = user
        cell.delegate = self
        return cell
    }
}

extension CommentViewController: CommentTableViewCellDelegate {
    func goToProfileUserVC(userId: String) {
        performSegue(withIdentifier: "Comment_ProfileSegue", sender: userId)
    }
    
    func goToHashTag(tag: String) {
        performSegue(withIdentifier: "Comment_HashTagSegue", sender: tag)
    }
}


