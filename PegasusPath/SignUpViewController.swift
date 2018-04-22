//
//  SignUpViewController.swift
//  PegasusPath
//
//  Created by Isaias Perez on 4/18/18.
//  Copyright © 2018 Christopher Donoso. All rights reserved.
//
import UIKit
import Firebase
import FirebaseAuth

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var firstTextField: UITextField!
    @IBOutlet weak var lastTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPassTextField: UITextField!
    
    var docRef: DocumentReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // Proceed and Register user
    @IBAction func SignUpDone(_ sender: Any) {
        //performSegue(withIdentifier: "signReturn", sender: self)
        
        //Register the user with Firebase
        guard let email = emailTextField.text,
            let pass = passwordTextField.text,
            let confirmPass = confirmPassTextField.text,
            let first = firstTextField.text,
            let last = lastTextField.text,
            email != "",
            pass != "",
            first != "",
            last != "",
            confirmPass != ""
            else {
                AlertController.showAlert(self, title: "Missing Info", message: "Please fill out all field.")
                return
        }
        guard pass == confirmPass
            else{
                AlertController.showAlert(self, title: "Error", message: "Passwords do not match")
                return
        }
        
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
            if let u = user {
                //user is found, go to homescreen
                self.performSegue(withIdentifier: "registerToHome", sender: self)
            }
                
            else {
                //Error: check error and show message
                AlertController.showAlert(self, title: "Error", message: (error?.localizedDescription)!)
                return
            }
        })
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Dismiss the keyboard when the view is tapped on
        firstTextField.resignFirstResponder()
        lastTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        confirmPassTextField.resignFirstResponder()
    }
    
    class AlertController {
        static func showAlert(_ inViewController: UIViewController, title: String, message: String) {
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alert.addAction(action)
            inViewController.present(alert, animated: true, completion: nil)
        }
    }
    
    // Already have an account, take user to sign in controller
    @IBAction func goSignIn(_ sender: Any) {
        performSegue(withIdentifier: "registerToLog", sender: self)
    }
    
}






