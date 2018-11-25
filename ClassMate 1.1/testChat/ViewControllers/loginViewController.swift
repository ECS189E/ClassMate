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

class loginViewController : UIViewController, GIDSignInUIDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //GIDSignIn.sharedInstance().uiDelegate = self

        // TODO(developer) Configure the sign-in button look/feel
        // ...
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    @IBAction func signInPushed(_ sender: GIDSignInButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        print("dismissing Google SignIn")
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        print("presenting Google SignIn")
    }
    
}
