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

class profileViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var signIn: GIDSignIn?
    var userID = ""
    var userName = ""
    let pickerData: [String] = ["Freshman", "Sophomore", "Junior", "Senior", "Super Senior"]
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var yearPicker: UIPickerView!
    @IBOutlet weak var classesTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initializeProfile()
        self.yearPicker.delegate = self
        self.yearPicker.dataSource = self
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
                
                let classes = channels.joined(separator: ",")
                self.classesTextField.text = classes
                    
                 
                
            } else {
                print("Document does not exist")
            }
        }
    }
    
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
