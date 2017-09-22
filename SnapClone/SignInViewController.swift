//
//  SignInViewController.swift
//  SnapClone
//
//  Created by Jack Howard on 7/3/17.
//  Copyright © 2017 JackHowa. All rights reserved.
//

import UIKit
import Firebase

// need db for specifying the db call
import FirebaseDatabase

// getting weird errors associated to signIn without specified
// pods from firebase
// via https://stackoverflow.com/questions/37345465/use-of-unresolved-identifier-firauth-swift-2-firebase-3-x

import FirebaseAuth

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // Check whether the user is already logged in
        // help via stack https://stackoverflow.com/questions/41531271/checking-firebase-current-signed-in-user-via-listener-in-ios
        // getting nil though :(
//        Auth.auth().addStateDidChangeListener { auth, user in
//            if let user = user {
//                // User is signed in.
//                self.signIn()
//            } else {
//                // No user is signed in.
//            }
//        }
    }
    
    
    // we're logging in and registering now
    // this will be easier than handling both on different pages
    
    @IBAction func signInTapped(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!, completion:
            { (user, error) in
                if error != nil {
                    self.wrongPassword(title: "Login Error", message: "Either wrong email or password.")
                } else {
                    //                    print("Signed in successfully")
                    self.performSegue(withIdentifier: "signInSegue", sender: nil)
                }
        })
    }
    
    func wrongPassword(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler: { (action) in
            // what to do when button clicked
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func newUser(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Thanks", style: UIAlertActionStyle.default, handler: { (action) in
            // what to do when button clicked
            alert.dismiss(animated: true, completion: nil)
            //        print("Signed in successfully")
            self.performSegue(withIdentifier: "signInSegue", sender: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func signIn() {
        self.performSegue(withIdentifier: "signInSegue", sender: nil)
    }
}


