//
//  CreateViewController.swift
//  Music App
//
//  Created by Neeraj Ramachandran on 6/9/19.
//  Copyright © 2019 Neeraj Ramachandran. All rights reserved.
//

import UIKit
import AVFoundation
class CreateViewController: UIViewController {
    
    @IBOutlet weak var removeButton: UIBarButtonItem!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var shareButton: UIButton!
    
    var selectedImage: UIImage?
    var videoUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Presents image picker each time the photo is tapped
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleSelectPhoto))
        photo.addGestureRecognizer(tapGesture)
        photo.isUserInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handlePost()
    }
    
    func handlePost(){
        // Enables share button when image is selected 
        if selectedImage != nil{
            self.shareButton.isEnabled = true
            self.removeButton.isEnabled = true
            // Makes button black
            self.shareButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
            
        }
        else{
            // Otherwise, share button is disabled
            self.shareButton.isEnabled = false
            self.removeButton.isEnabled = false
            self.shareButton.backgroundColor = .lightGray
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func handleSelectPhoto(){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        // To pick videos
        // Specify media type (should be in dictionary form
        pickerController.mediaTypes = ["public.image", "public.movie"]
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func shareButton_TouchUpInside(_ sender: Any) {
        view.endEditing(true)
        ProgressHUD.show("Waiting...", interaction: false)
        let profileImg = self.selectedImage
        if let imageData = profileImg?.jpegData(compressionQuality: 0.1){
            let ratio = profileImg!.size.width / profileImg!.size.height
            HelperService.uploadDataToServer(data: imageData, videoUrl: self.videoUrl, ratio: ratio, caption: captionTextView.text!, onSuccess: {
                    // Clear input after pushing to database
                    self.clean()
                    // Returns to home view (index 0 of tab bar controller)
                    self.tabBarController?.selectedIndex = 0
                })
        } else {
            // If no photo was selected
            ProgressHUD.showError("Please select a profile picture")
        }
    }
    
    
    @IBAction func remove_TouchUpInside(_ sender: Any) {
        clean()
        handlePost()
    }
    
    func clean(){
        self.captionTextView.text = ""
        self.photo.image = UIImage(named: "placeholder-photo")
        self.selectedImage = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "filter_segue" {
            let filterVC = segue.destination as! FilterViewController
            // Sets image in filter VC to selected image from Create VC
            filterVC.selectedImage = self.selectedImage
            // Sets Create VC as a delegate of Filter VC
            filterVC.delegate = self
        }
    }
    
}

extension CreateViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // After choosing video
        if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            // If we can get a thumbnail from the video, we set the video url
            if let thumbnailImage = self.thumbnailImageForFileUrl(videoUrl) {
                // Ensures video and thumbnail are set together
                selectedImage = thumbnailImage
                photo.image = thumbnailImage
                self.videoUrl = videoUrl
            }
            // Dismisses photo library
            dismiss(animated: true, completion: nil)
        }
        
        // After choosing photo, assigns to profile image
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            selectedImage = image
            photo.image = image
            // After dismissing, segue to the filter view
            dismiss(animated: true, completion: {
            self.performSegue(withIdentifier: "filter_segue", sender: nil)
            })
        }
    }
    
    func thumbnailImageForFileUrl(_ fileUrl: URL) -> UIImage? {
        let asset = AVAsset(url: fileUrl)
        // Generates an image from a video
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        do {
            // Returns image for the video asset around time that is specified
            // Time make: need 6 units, 3 of which make up 1 second
            // Samples an image at second 2 of the video
            let thumbnailCGImage = try imageGenerator.copyCGImage(at : CMTimeMake(value: 6, timescale: 3), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        }
        catch let err {
            print(err)
        }
        return nil
    }
}

extension CreateViewController: FilterViewControllerDelegate {
    func updatePhoto(image: UIImage) {
        self.photo.image = image
        self.selectedImage = image
    }
}
