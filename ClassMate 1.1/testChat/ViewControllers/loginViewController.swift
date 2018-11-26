//
//  loginViewController.swift
//  testChat
//
//  Created by Min Duan on 11/23/18.
//

import Foundation
import UIKit
import GoogleSignIn
import Firebase

class loginViewController : UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {
    
    var ref: DocumentReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //GIDSignIn.sharedInstance().uiDelegate = self
        
        // TODO(developer) Configure the sign-in button look/feel
        // ...
        
        GIDSignIn.sharedInstance().clientID = "771197463282-b87trmajhetmgp1nlc294b5vs4sn7ofq.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
    }
    
    @IBAction func signInPushed(_ sender: GIDSignInButton) {
        GIDSignIn.sharedInstance().signIn()
        
        print("123")
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
            print("\(error.localizedDescription)")
            return
            
        } else {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            // ...
            createNewUser(id: idToken!, email: email!)
            
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        // ...
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
                // ...
                return
            }
            // User is signed in
            // ...
            
            let Storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let channelVC = self.storyboard?.instantiateViewController(withIdentifier: "channelViewController") as! channelViewController
            
            // Prepare the data that need to be fetched from the server for next view
            // ...
            
            // TODO: Fetch the data from the server
            
            
            self.present(channelVC, animated: true, completion: nil)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        print("dismissing Google SignIn")
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        print("presenting Google SignIn")
    }
    
    func createNewUser(id: String, email: String) {
        
        // Add a new document with a generated ID
        var ref: DocumentReference? = nil
        ref = Firestore.firestore().collection("users").addDocument(data: [
            "idToken": id,
            "userName": email,
            "channels": [String]()
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }

    }
}
