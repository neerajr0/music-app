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
    
    @IBOutlet weak var signInButton: UIButton!
    
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
        
        // Disable sign in button
        signInButton.isEnabled = false
        
        // Ensure text fields are filled out
        handleTextField()
    }
    
    // Dismisses keyboard when touching away
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // Automatically logs in if current user credentials are there
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Api.User.CURRENT_USER != nil {
            self.performSegue(withIdentifier: "signInToTabbarVC", sender: nil)
        }
    }
    
    func handleTextField(){
        emailTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControl.Event.editingChanged)
        passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControl.Event.editingChanged)
    }
    // Highlights sign-in button if each text field contains text
    @objc func textFieldDidChange(){
        guard let email = emailTextField.text, !email.isEmpty, let password = passwordTextField.text, !password.isEmpty else{
            signInButton.setTitleColor(UIColor.lightText, for: UIControl.State.normal)
            signInButton.isEnabled = false
            return
        }
        signInButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        signInButton.isEnabled = true
    }
    // Verifies that user exists when clicking on Sign In
    @IBAction func signInButton_TouchUpInside(_ sender: Any) {
        view.endEditing(true)
        ProgressHUD.show("Waiting", interaction: false)
        AuthService.signIn(email: emailTextField.text!, password: passwordTextField.text!, onSuccess: {
            ProgressHUD.showSuccess("Success")
            // Changes to tab bar controller after user authentication
            self.performSegue(withIdentifier: "signInToTabbarVC", sender: nil)
        }, onError: {error in
            ProgressHUD.showError(error!)
        })
    }
} 

