//
//  channelViewController.swift
//  testChat
//
//  Created by Min Duan on 11/23/18.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

class channelViewController : UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize database
        var ref: DatabaseReference!
        
        ref = Database.database().reference()
    }
}
