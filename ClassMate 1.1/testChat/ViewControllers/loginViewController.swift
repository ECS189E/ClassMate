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
        
        // TODO: Use this to skip login view for existing users
        let user = GIDSignIn.sharedInstance()?.currentUser
        if user != nil {
            print("@@@@@@")
            print(user!)
            print("#####")
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let channelVC = storyboard.instantiateViewController(withIdentifier: "channelViewController") as! channelViewController
            
            // Prepare the data that need to be fetched from the server for next view
            // ...
            
            channelVC.userID = user!.userID
            print(channelVC.userID)
            channelVC.email = user!.profile.email
            
            let navController = UINavigationController(rootViewController:  channelVC)
            self.present(navController, animated:true, completion: nil)
        }
        GIDSignIn.sharedInstance().uiDelegate = self
        
    }
    
    @IBAction func signInPushed(_ sender: GIDSignInButton) {
        GIDSignIn.sharedInstance().signIn()
        
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
            let docRef = Firestore.firestore().collection("users").document(userId!)

            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    print("User already exists")
                } else {
                    self.createNewUser(id: userId!, email: email!)
                }
            }
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
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let channelVC = storyboard.instantiateViewController(withIdentifier: "channelViewController") as! channelViewController
            
            // Prepare the data that need to be fetched from the server for next view
            // ...
            
            // TODO: Fetch the data from the server
            
            channelVC.userID = user.userID!
            channelVC.email = user.profile.email!
            
            let navController = UINavigationController(rootViewController:  channelVC)
            self.present(navController, animated:true, completion: nil)
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
        Firestore.firestore().collection("users").document(id).setData([
            "userName": email,
            "email": email,
            "channels": [String](),
            "year": -1,
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }

    }
}
