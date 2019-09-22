//
//  SignUpViewController.swift
//  Music App
//
//  Created by Neeraj Ramachandran on 5/30/19.
//  Copyright © 2019 Neeraj Ramachandran. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //For username text field:
        
        // Set background color of usernametext field to black
        usernameTextField.backgroundColor = UIColor.clear
        
        // Make cursor white
        usernameTextField.tintColor = UIColor.white
        
        //Make text color white
        usernameTextField.textColor = UIColor.white
        
        //Make placeholder text translucent white
        usernameTextField.attributedPlaceholder = NSAttributedString(string: usernameTextField.placeholder!, attributes: [NSAttributedString.Key.foregroundColor: UIColor(white: 1.0, alpha: 0.6)])
        
        //Add line between text fields
        let bottomLayerUsername = CALayer()
        bottomLayerUsername.frame = CGRect(x: 0, y: 29, width: 1000, height: 0.6)
        bottomLayerUsername.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 25/255, alpha: 1).cgColor
        emailTextField.layer.addSublayer(bottomLayerUsername)
        
        
        // For email text field:
        
        // Set background color of email text field to black
        emailTextField.backgroundColor = UIColor.clear
        
        // Make cursor white
        emailTextField.tintColor = UIColor.white
        
        //Make text color white
        emailTextField.textColor = UIColor.white
        
        //Make placeholder text translucent white
        emailTextField.attributedPlaceholder = NSAttributedString(string: emailTextField.placeholder!, attributes: [NSAttributedString.Key.foregroundColor: UIColor(white: 1.0, alpha: 0.6)])
        
        //Add line between text fields
        let bottomLayerEmail = CALayer()
        bottomLayerEmail.frame = CGRect(x: 0, y: 29, width: 1000, height: 0.6)
        bottomLayerEmail.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 25/255, alpha: 1).cgColor
        emailTextField.layer.addSublayer(bottomLayerEmail)
        
        //For Password text field:
        
        // Set background color of password field to black
        passwordTextField.backgroundColor = UIColor.clear
        
        // Make cursor white
        passwordTextField.tintColor = UIColor.white
        
        //Make text color white
        passwordTextField.textColor = UIColor.white
        
        //Make placeholder text translucent white
        passwordTextField.attributedPlaceholder = NSAttributedString(string: passwordTextField.placeholder!, attributes: [NSAttributedString.Key.foregroundColor: UIColor(white: 1.0, alpha: 0.6)])
        
        //Add line between text fields
        let bottomLayerPassword = CALayer()
        bottomLayerPassword.frame = CGRect(x: 0, y: 29, width: 1000, height: 0.6)
        bottomLayerPassword.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 25/255, alpha: 1).cgColor
        passwordTextField.layer.addSublayer(bottomLayerPassword)
        
        // For profile image:
        profileImage.layer.cornerRadius = 75
        profileImage.clipsToBounds = true
    }
    
    @IBAction func dismiss_onClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
