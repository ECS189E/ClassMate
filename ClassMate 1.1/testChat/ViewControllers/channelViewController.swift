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
import CoreLocation


class channelViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, registerViewDelegate, CLLocationManagerDelegate {
    
    
    var signIn: GIDSignIn?
    var userID = ""
    var userName = ""
    var channels = [ChatRoom?]()
    var channelList = [String]()
    var locationManager: CLLocationManager!
    @IBOutlet weak var channelView: UITableView!
    @IBOutlet weak var registerNewClass: UIBarButtonItem!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isToolbarHidden = false
        
        getCurrentLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        channelView.tableFooterView = UIView()
        retrieveChannels()
        joinClassFromLocation()
    }
    
    func retrieveChannels() {
        let docRef = Firestore.firestore().collection("users").document(self.userID)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let channelListString = document.data() as! [String: Any]
                self.channelList = channelListString["channels"] as! [String]
                self.initializeChannels(using: self.channelList)
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
    
    @IBAction func registerChatroom(_ sender: Any) {
        // Load and configure your view controller.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let registerVC = storyboard.instantiateViewController(
            withIdentifier: "registerViewController") as! registerViewController
        registerVC.delegate = self
        self.present(registerVC, animated: true, completion: nil)
    }
    
    // RegisterViewDelegate Protocols
    func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func join(classroom: String) {
        // check if channels already joined
        if channels.contains(where: {$0!.name == classroom}) != true {
            let chatroom = ChatRoom.init(name: classroom)
            self.channels.append(chatroom)
            self.channelList.append(classroom)
            self.channelView.reloadData()
            Firestore.firestore().collection("users").document(userID).setData([
                "userName": self.userName,
                "channels": self.channelList
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
        }
        // Check channels
        // If doesn't exist, create a new one in database
        addChannelToDatabase(which: classroom)
        // Add in members
        addMembersToDatabase(to: classroom)
    }
    
    func addChannelToDatabase(which channel: String) {
        let docRef = Firestore.firestore().collection("channels").document(channel)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists != true {
                docRef.setData([
                    "messages": [Message](),
                    ]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document successfully written!")
                        }
                }
            }
        }
    }
    
    func addMembersToDatabase(to classroom: String) {
        let docRef = Firestore.firestore().collection("members").document(classroom)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let memberListString = document.data() as! [String: Any]
                var memberList = memberListString["members"] as! [String]
                memberList.append(self.userID)
                docRef.setData([
                    "members": memberList,
                    ]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document successfully written!")
                        }
                }
            } else {
                docRef.setData([
                    "members": [self.userID],
                    ]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document successfully written!")
                        }
                }
            }
        }
    }
    
    // Instantly join chat based on user's current class
    func joinClassFromLocation() {
        let classroom = getClass()
        
        // Recommend current class to user if it has not been recommended before or currently joined
        let docRef = Firestore.firestore().collection("users").document(self.userID)
        
        var recommendedChannels: [String: Int] = [:]
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data() as! [String: Any]
                recommendedChannels = data["recommendedChannels"] as? [String: Int] ?? [:]
                
                // Check if classroom has been recommended before or currently joined
                // TODO: check current chatrooms
                if recommendedChannels[classroom] == nil {
                    recommendedChannels[classroom] = 1
                    
                    // Update database
                    Firestore.firestore().collection("users").document(self.userID).updateData([
                        "recommendedChannels": recommendedChannels
                    ]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document successfully written!")
                        }
                    }
                    
                    let ac = UIAlertController(title: nil, message: "Are you a student in \(classroom)?", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                    ac.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
                        self.join(classroom: classroom)
                        self.channelView.reloadData() // may be unnecessary
                    }))
                    self.present(ac, animated: true, completion: nil)
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    // Uses current location and time of user to get class
    func getClass() -> String {
        return "ECS189ee"
    }
    
    func getCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            //locationManager.startUpdatingHeading()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
        manager.stopUpdatingLocation()
        
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    
    
    @IBAction func signOut(_ sender: UIButton) {
        let ac = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                self.signIn?.signOut()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
            self.dismiss(animated: true, completion: nil)
        }))
        present(ac, animated: true, completion: nil)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let channel = self.channels[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "channelCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "channelCell")
        
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = channel?.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.channels.remove(at: indexPath.row)
            self.channelView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let channel = channels[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "chatViewController") as! chatViewController
        
        vc.channelName = channel?.name ?? " "
        vc.username = self.userName
        navigationController!.pushViewController(vc, animated: true)
    }
    
}
