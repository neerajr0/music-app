//
//  SignInViewController.swift
//  Music App
//
//  Created by Neeraj Ramachandran on 5/30/19.
//  Copyright © 2019 Neeraj Ramachandran. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        
    }
}

