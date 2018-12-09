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
    
    var userID = ""
    var userName = ""
    var email = ""
    var channels = [ChatRoom?]()
    var channelList = [String]()
    var locationManager: CLLocationManager!
    
    // Maybe this should be on the database
    var classrooms = [
        "ECS189E": Classroom(course: "ECS189E", locationName: "Art Hall", days: [2,4,6], time: 9...10, latitude: 37.785834, longitude: -122.406417),
        "Anywhere Class": Classroom(course: "Anywhere class", locationName: "Will prompt anywhere", days: [1,2,3,4,5,6,7], time: 1...24, latitude: 37.785834, longitude: -122.406417),
    ]
    
    @IBOutlet weak var channelView: UITableView!
    @IBOutlet weak var registerNewClass: UIBarButtonItem!
    @IBOutlet weak var profileButton: UIBarButtonItem!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isToolbarHidden = false
        
        getCurrentLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        channelView.tableFooterView = UIView()
        getUsername()
        retrieveChannels()
    }
    
    // Fetch username from server
    func getUsername() {
        let docRef = Firestore.firestore().collection("users").document(self.userID)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                guard let data = document.data() else { return }
                
                if let userName = data["userName"] as? String {
                    self.userName = userName
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func retrieveChannels() {
        let docRef = Firestore.firestore().collection("users").document(self.userID)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                guard let channelListString = document.data() else { return }
                self.channelList = channelListString["channels"] as! [String]
                self.initializeChannels(using: self.channelList)
                self.channelView.reloadData()
            } else {
                print("Document does not exist")
            }
        }
    }
    
    // change chatroom from [String] to [ChatRoom]
    func initializeChannels(using channelList: [String]) {
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
            Firestore.firestore().collection("users").document(userID).updateData([
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
                guard let memberListString = document.data() else { return }
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
    
    // Begins listening to user's location, calls locationManager()
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
    
    // Checks user's current location against location of all classes in directory
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        manager.stopUpdatingLocation()
        
        for course in classrooms {
            if userWithinDistance(userLocation: userLocation, classLocation: course.value.location, delta: 0.001) {
                if classInSession(classroom: course.value) {
                    joinClassFromLocation(classroom: course.key)
                }
            } else {
                // Not near any class
            }
        }
    }
    
    // Calculates whether two coordinates close within a delta
    func userWithinDistance(userLocation: CLLocation, classLocation: CLLocation, delta: Double) -> Bool {
        let userLat = userLocation.coordinate.latitude
        let userLon = userLocation.coordinate.longitude
        let classLat = classLocation.coordinate.latitude
        let classLon = classLocation.coordinate.longitude
        
        if abs(userLat - classLat) < delta && abs(userLon - classLon) < delta {
            return true
        } else {
            return false
        }
    }
    
    func classInSession(classroom: Classroom) -> Bool {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let day = Date().dayNumberOfWeek()!

        // TODO: Find better way to check for time
        if classroom.days.contains(day) && classroom.time.contains(hour) {
            return true
        } else {
            return false
        }
    }
    
    // Instantly join chat based on user's current class
    func joinClassFromLocation(classroom: String) {
        // Recommend current class to user if it has not been recommended before or currently joined
        let docRef = Firestore.firestore().collection("users").document(self.userID)
        
        var recommendedChannels: [String: Int] = [:]
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                guard let data = document.data() else { return }
                recommendedChannels = data["recommendedChannels"] as? [String: Int] ?? [:]
                
                // TODO: check current chatrooms
                // Check if classroom has been recommended before or currently joined
                if recommendedChannels[classroom] == nil {
                    // Classroom has never been recommended
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
                    
                    // Creates Alert to prompt user to join
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
    
    @IBAction func signOut(_ sender: UIButton) {
        let ac = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                GIDSignIn.sharedInstance().signOut()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
            self.dismiss(animated: true, completion: nil)
        }))
        present(ac, animated: true, completion: nil)
        
    }
    
    //channel table view functions
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
        
        // keep the username up to date
        self.getUsername()
        vc.channelName = channel?.name ?? " "
        vc.email = self.email
        vc.username = self.userName
        navigationController!.pushViewController(vc, animated: true)
    }
    // end channel table view functions
    
    
    @IBAction func toProfile(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let profileVC = storyboard.instantiateViewController(
            withIdentifier: "profileViewController") as! profileViewController
        
        profileVC.userID = userID
        profileVC.userName = userName
        
        if (navigationController != nil) {
            navigationController?.pushViewController(profileVC, animated: true)
        } else {
            print("Cannot find navigation controller.")
        }
    }
}

extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
    
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self).capitalized
    }
}
