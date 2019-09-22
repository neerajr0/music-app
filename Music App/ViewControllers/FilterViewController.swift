//
//  FilterViewController.swift
//  Music App
//
//  Created by Neeraj Ramachandran on 8/5/19.
//  Copyright © 2019 Neeraj Ramachandran. All rights reserved.
//

import UIKit

protocol FilterViewControllerDelegate {
    func updatePhoto(image: UIImage)
}

class FilterViewController: UIViewController {

    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var filterPhoto: UIImageView!
    var delegate: FilterViewControllerDelegate?
    var selectedImage: UIImage!
    
    // Array of filter names
    var CIFilterNames = [
        "CIPhotoEffectChrome",
        "CIPhotoEffectFade",
        "CIPhotoEffectInstant",
        "CIPhotoEffectNoir",
        "CIPhotoEffectProcess",
        "CIPhotoEffectTonal",
        "CIPhotoEffectTransfer",
        "CISepiaTone"
    ]
    
    // Avoids image distortion
    var context = CIContext(options: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Sets filtered photo to selected image
        filterPhoto.image = selectedImage

        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancelBtn_TouchUpInside(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextBtn_TouchUpInside(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        // Updates photo on Create VC to filtered one
        delegate?.updatePhoto(image: self.filterPhoto.image!)
        
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        // Draws image in rectangle
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }

}

extension FilterViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    // Number of filters
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CIFilterNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollectionViewCell", for: indexPath) as! FilterCollectionViewCell
        // Resizes cell image to avoid long buffering times
        let newImage = resizeImage(image: selectedImage, newWidth: 150)
        // Applies filter to image
        let ciImage = CIImage(image: newImage)
        let filter = CIFilter(name: CIFilterNames[indexPath.item])
        filter?.setValue(ciImage, forKey: kCIInputImageKey )
        if let filteredImage = filter?.value(forKey: kCIOutputImageKey) as? CIImage {
            // Avoids image distortion
            let result = context.createCGImage(filteredImage, from: filteredImage.extent)
            // Sets filter photo of cell to selected image
            cell.filterPhoto.image = UIImage(cgImage: result!)
        }
        return cell
    }
    
    // Identifies which filter was selected
    // Filters large photo appropriately
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let ciImage = CIImage(image: selectedImage)
        let filter = CIFilter(name: CIFilterNames[indexPath.item])
        filter?.setValue(ciImage, forKey: kCIInputImageKey )
        if let filteredImage = filter?.value(forKey: kCIOutputImageKey) as? CIImage {
            // Avoids image distortion
            let result = context.createCGImage(filteredImage, from: filteredImage.extent)
            // Sets filter photo of cell to selected image
            self.filterPhoto.image = UIImage(cgImage: result!, scale: 1, orientation: selectedImage.imageOrientation)
        }
    }
    
}
