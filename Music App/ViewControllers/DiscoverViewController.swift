//
//  DiscoverViewController.swift
//  Music App
//
//  Created by Neeraj Ramachandran on 6/9/19.
//  Copyright © 2019 Neeraj Ramachandran. All rights reserved.
//

import UIKit

class DiscoverViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var posts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        // Updates top posts every time view loads
        loadTopPosts()
    }
    
    @IBAction func refresh_TouchUpInside(_ sender: Any) {
        loadTopPosts()
    }
    
    // Shows most popular posts
    func loadTopPosts() {
        // Loading message
        ProgressHUD.show("Loading...", interaction: false)
        // Removes previously queried data
        // Here in the array
        self.posts.removeAll()
        // Here in the view
        self.collectionView.reloadData()
        Api.Post.observeTopPosts { (post) in
            self.posts.append(post)
            self.collectionView.reloadData()
            ProgressHUD.dismiss()
        }
    }
    
    // Prepares the Detail VC for a segue from Discover VC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Discover_DetailSegue" {
            let detailVC = segue.destination as!  DetailViewController
            let postId = sender as! String
            detailVC.postId = postId
        }
    }
    
}

// Allows controller to adopt collection view data source protocol
extension DiscoverViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Number of posts
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        let post = posts[indexPath.row]
        cell.post = post
        cell.delegate = self
        return cell
    }

}

extension DiscoverViewController: UICollectionViewDelegateFlowLayout {
    
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

extension DiscoverViewController: PhotoCollectionViewCellDelegate {
    func goToDetailVC(postId: String) {
      performSegue(withIdentifier: "Discover_DetailSegue", sender: postId)
    }
}
