//
//  ViewController.swift
//  PegasusPath
//
//  Created by Huey Padua on 2/28/18.
//  Copyright © 2018 Huey Padua. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {

    
    @IBOutlet weak var signinSelector: UISegmentedControl!
    
    @IBOutlet weak var signinLabel: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var firstTextField: UITextField!
    
    @IBOutlet weak var lastTextField: UITextField!
    
    @IBOutlet weak var signinButton: UIButton!
    
    var isSignIn:Bool = true
    
    var docRef: DocumentReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstTextField.isHidden = true
        lastTextField.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func signinSelectorChanged(_ sender: Any) {
        
        //Flip the boolean
        isSignIn = !isSignIn
        
        //Check the bool and set the button and labels
        if isSignIn {
            signinButton.setTitle("Login", for: .normal)
            firstTextField.isHidden = true
            lastTextField.isHidden = true
        }
        else  {
            signinButton.setTitle("Register", for: .normal)
            firstTextField.isHidden = false
            lastTextField.isHidden = false
        }
    }
    
    @IBAction func signinButtonTapped(_ sender: Any) {
        
        //TODO: Do some form validation on the email and password
        
        if let email = emailTextField.text, let pass = passwordTextField.text, email != "", pass != "" {
            
            //Check if it's sign in or register
            if isSignIn {
                //Sign in the user with Firebase
                Auth.auth().signIn(withEmail: email, password: pass, completion: { (user, error) in
                    
                    //Check  that user isn't nil
                    if user != nil {
                        //user is found, go to home screen
                        self.performSegue(withIdentifier: "goToHome", sender: self)
                    }
                    else {
                        AlertController.showAlert(self, title: "Error", message: (error?.localizedDescription)!)
                        return
                    }
                })
            }
            else {
                //Register the user with Firebase
                if let email = emailTextField.text, let pass = passwordTextField.text, let first = firstTextField.text, let last = lastTextField.text, email != "", pass != "", first != "", last != "" {
                    
                    Auth.auth().createUser(withEmail: email, password: pass, completion: { (user, error) in
                        
                        // Add user information to firestore database
                        let docRef = Firestore.firestore().collection("users").document()
                        let userID = docRef.documentID
                        
                        docRef.setData(["email": email, "firstname": first, "lastname": last, "uid": userID])
                    /*
                    // Check to see if data has been saved to database
                    self.docRef.setData() { (error) in
                        if let error = error {
                            print("Error: \(error.localizedDescription)")
                        }
                        else {
                            print("Data has been saved.")
                        }
                    }
                    */
                    //check that user isn't nil
                        if user != nil {
                            //user is found, go to homescreen
                            self.performSegue(withIdentifier: "goToHome", sender: self)
                        }
                        else {
                            //Error: check error and show message
                        }
                    })
                }
                else {
                    AlertController.showAlert(self, title: "Missing Info", message: "Please fill out all field.")
                    return
                }
            }
        }
        else {
            AlertController.showAlert(self, title: "Missing Info", message: "Please fill out all field.")
            return
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Dismiss the keyboard when the view is tapped on
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
}

class LogoutController: UIViewController {
    
    @IBOutlet weak var emailText: UILabel!
    
    @IBOutlet weak var uidText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = Auth.auth().currentUser
        if let user = user {
            let email = user.email
            let uid = user.uid

            emailText.text = "Email: \(email!)"
            uidText.text = "User ID: \(uid)"

        }

    }

    @IBAction func goBackButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "goBackSegue", sender: self)
    }
    @IBAction func signoutButtonTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "signoutSegue", sender: self)
            
        }
        catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

class AlertController {
    static func showAlert(_ inViewController: UIViewController, title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(action)
        inViewController.present(alert, animated: true, completion: nil)
    }
}

