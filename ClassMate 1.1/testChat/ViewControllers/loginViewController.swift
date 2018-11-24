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

class loginViewController : UIViewController, GIDSignInUIDelegate
{

    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        
        // TODO(developer) Configure the sign-in button look/feel
        // ...
    }
    
    @IBAction func signInPushed(_ sender: GIDSignInButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    
}
