//
//  registerViewController.swift
//  testChat
//
//  Created by Weisu Yin on 11/27/18.
//

import UIKit

protocol registerViewDelegate {
    func cancel()
    func join(classroom: String)
}


class registerViewController: UIViewController, UITextFieldDelegate {

    var delegate: registerViewDelegate?
    @IBOutlet weak var joinTextField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var joinButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        joinTextField.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.view.endEditing(true)
        return true;
    }
    
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        self.delegate?.cancel()
    }
    
    @IBAction func joinTapped(_ sender: UIButton) {
        if let name = joinTextField.text {
            self.delegate?.join(classroom: name)
        } else {
            self.delegate?.cancel()
        }
    }
    
}
