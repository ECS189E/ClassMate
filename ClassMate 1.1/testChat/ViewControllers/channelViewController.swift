//
//  channelViewController.swift
//  testChat
//
//  Created by Min Duan on 11/23/18.
//

import Foundation
import UIKit
import Firebase
import GoogleSignIn


class channelViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var signIn: GIDSignIn?
    var userID = ""
    var channels = [ChatRoom?]()
    @IBOutlet weak var channelView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveChannels()
        
    }
    
    func retrieveChannels() {
        let docRef = Firestore.firestore().collection("users").document(self.userID)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let channelListString = document.data() as! [String: Any]
                let channelList = channelListString["channels"] as! [String]
                self.initializeChannels(using: channelList)
                self.channelView.reloadData()
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func initializeChannels(using channelList: [String]) {
        //for loop
        for channel in channelList
        {
            let chatroom = ChatRoom.init(name: channel)
            self.channels.append(chatroom)
        }
    }
    
    @IBAction func signOut(_ sender: UIButton) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        GIDSignIn.sharedInstance().signOut()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(self.channels)
        return channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let channel = self.channels[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "channelCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "channelCell")
        
        cell.textLabel?.text = channel?.name
        
        return cell
    }
    
}
