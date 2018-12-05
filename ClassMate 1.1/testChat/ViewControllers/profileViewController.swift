//
//  profileViewController.swift
//  testChat
//
//  Created by Andy Li on 11/28/18.
//

import UIKit
import MessageKit
import MessageInputBar
import Firebase
import GoogleSignIn

class profileViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDataSource, UITableViewDelegate {
    
    var signIn: GIDSignIn?
    var userID = ""
    var userName = ""
    var classList = [String]()
    let pickerData: [String] = ["Freshman", "Sophomore", "Junior", "Senior", "Super Senior"]
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var yearPicker: UIPickerView!
    @IBOutlet weak var classTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initializeProfile()
        self.yearPicker.delegate = self
        self.yearPicker.dataSource = self
        self.classTableView.delegate = self
        self.classTableView.dataSource = self
        
    }
    
    func initializeProfile() {
        let docRef = Firestore.firestore().collection("users").document(self.userID)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                guard let data = document.data() else { return }
                
                // Update username
                self.userNameTextField.text = self.userName
                guard var year = data["year"] as? Int else { return }
                
                // -1 represents an unset year. Display as 0th row by default
                if year == -1 {
                    year = 0
                }
                self.yearPicker.selectRow(year, inComponent: 0, animated: false)
                
                // Update classes using channels list
                guard let channels = data["channels"] as? [String] else { return }
                
                self.classList = channels
                self.classList.sort()
                self.classTableView.reloadData()
                
            } else {
                print("Document does not exist")
            }
        }
    }
    
    
    // classroom table view functions
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let classTaken = self.classList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileClassCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "profileClassCell")
        cell.textLabel?.text = classTaken
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    // end class room table view functions

    
    // yearPicker functions
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Updates year to database if changed
        Firestore.firestore().collection("users").document(self.userID).updateData([
            "year": row
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        
    }
    // end yearPicker functions
    
    
    // textField functions
    @IBAction func nameEditingDidEnd(_ sender: Any) {
        guard let newName = userNameTextField.text else { return }
        if newName != "" {
            Firestore.firestore().collection("users").document(self.userID).updateData([
                "userName": newName
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
        }
    }
    
    @IBAction func classesEditingDidEnd(_ sender: Any) {
        
    }
    //end textField functions
}
