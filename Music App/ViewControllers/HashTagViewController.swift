//
//  HashTagViewController.swift
//  Music App
//
//  Created by Neeraj Ramachandran on 8/6/19.
//  Copyright © 2019 Neeraj Ramachandran. All rights reserved.
//

import UIKit

class HashTagViewController: UIViewController {
    
    // Array of queried posts
    var posts: [Post] = []
    var tag = ""
    
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "\(tag)"
        // Configures collection view, cells, and header
        collectionView.dataSource = self
        // Applies height/width configuration to collection view
        collectionView.delegate = self
        loadPosts()
    }
    
    func loadPosts() {
        Api.HashTag.fetchPosts(withTag: tag) { (postId) in
            Api.Post.observePost(withId: postId, completion: { (post) in
                self.posts.append(post)
                self.collectionView.reloadData()
            })
        }
    }
    
    // Prepares the hash tag VC for a segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // to Detail VC
        if segue.identifier == "HashTag_DetailSegue" {
            let detailVC = segue.destination as!  DetailViewController
            let postId = sender as! String
            detailVC.postId = postId
        }
    }
    
    
}

// Allows controller to adopt collection view data source protocol
extension HashTagViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Number of posts
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        let post = posts[indexPath.row]
        cell.post = post
        // The information displayed on the cell comes from
        // Profile VC
        cell.delegate = self
        return cell
    }
    
}

extension HashTagViewController: UICollectionViewDelegateFlowLayout {
    
    // Specifies spacing between rows of the collection view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    // Specifies spacing between cells in a row
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // Sets width and height of cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Sets width to 1/3 of screen width
        return CGSize(width: collectionView.frame.size.width / 3 - 1, height: collectionView.frame.size.width / 3 - 1)
    }
}

// Extension for hash tag to implement Photo Collection View Cell protocol
extension HashTagViewController: PhotoCollectionViewCellDelegate {
    func goToDetailVC(postId: String) {
        performSegue(withIdentifier: "HashTag_DetailSegue", sender: postId)
    }
}

