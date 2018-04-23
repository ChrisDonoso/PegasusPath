//
//  SignViewController.swift
//  PegasusPath
//
//  Created by Isaias Perez on 4/18/18.
//  Copyright © 2018 Christopher Donoso. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseAuth

class SignViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // Proceed to sign in
    @IBAction func signInButton(_ sender: Any) {
        //performSegue(withIdentifier: "logReturn", sender: self)
        
        //TODO: Do some form validation on the email and password
        if let email = emailTextField.text, let pass = passwordTextField.text, email != "", pass != "" {
            
            //Sign in the user with Firebase
            Auth.auth().signIn(withEmail: email, password: pass, completion: { (user, error) in
                
                //Check  that user isn't nil
                if let u = user {
                    //user is found, go to home screen
                    self.performSegue(withIdentifier: "loginSegue", sender: self)
                }
                else {
                    AlertController.showAlert(self, title: "Error", message: (error?.localizedDescription)!)
                    return
                }
            })
        }
        else {
            AlertController.showAlert(self, title: "Missing Info", message: "Please fill out all fields.")
            return
        }
    }
    
    // Dismiss the keyboard when the view is tapped on
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    class AlertController {
        static func showAlert(_ inViewController: UIViewController, title: String, message: String) {
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alert.addAction(action)
            inViewController.present(alert, animated: true, completion: nil)
        }
    }
    
    // No account, take user to sign up controller
    @IBAction func goSignUp(_ sender: Any) {
        performSegue(withIdentifier: "signToRegister", sender: self)
    }
    
}
    
