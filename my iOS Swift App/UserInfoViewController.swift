//
//  FirstViewController.swift
//  my iOS Swift App
//
//  Created by Chris Tham on 30/11/18.
//  Copyright © 2018 Hello Tham. All rights reserved.
//

import UIKit

class UserInfoViewController: UIViewController {
    let authentication = Authentication()
    var graph : MSGraphController?
    
    @IBOutlet weak var connectButton: UIBarButtonItem!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var givenNameLabel: UILabel!
    @IBOutlet weak var surnameLabel: UILabel!
    @IBOutlet weak var principalNameLabel: UILabel!
    @IBOutlet weak var jobTitleLabel: UILabel!
    @IBOutlet weak var officeLocationLabel: UILabel!
    @IBOutlet weak var mobilePhoneLabel: UILabel!
    @IBOutlet weak var businessPhonesLabel: UILabel!
    @IBOutlet weak var preferredLanguageLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        connectButton.title = "Log In"
    }

    @IBAction func connectButtonPressed(_ sender: UIBarButtonItem) {
        let clientId = MSGraphController.clientId
        let scopes = MSGraphController.scopes
        
        if (connectButton.title == "Log In") {
            authentication.connectToGraph(withClientId: clientId, scopes: scopes) {
                (error) in
                
                if let graphError = error {
                    switch graphError {
                    case .NSErrorType(let nsError):
                        print(NSLocalizedString("ERROR", comment: ""), nsError.localizedDescription)
                    default:
                        print("Unexpected error")
                    }
                }
                else {
                    self.graph = MSGraphController(with: self.authentication)
                    self.graph?.getMe(with: { (result) in
                        switch (result) {
                        case .Success:
                            self.updateUserInfo((self.graph?.me)!)
                        default:
                            print("An error occured")
                        }
                    })
                }
            }
            
            connectButton.title = "Log Out"
        }
        else {
            authentication.disconnect()
            connectButton.title = "Log In"
        }
        
        
    }
    
    func updateUserInfo(_ user: MSGraphUser) {
        DispatchQueue.main.async(execute: {
            self.userNameLabel.text = user.displayName
            self.idLabel.text = user.entityId
            self.givenNameLabel.text = user.givenName
            self.surnameLabel.text = user.surname
            self.principalNameLabel.text = user.userPrincipalName
            
            var obj = user.dictionaryFromItem()!["jobTitle"]!
            if let jobTitle = obj as? String {
                self.jobTitleLabel.text = jobTitle
            }

            obj = user.dictionaryFromItem()!["officeLocation"]!
            if let officeLocation = obj as? String {
                self.officeLocationLabel.text = officeLocation
            }
            
            obj = user.dictionaryFromItem()!["mobilePhone"]!
            if let mobilePhone = obj as? String {
                self.mobilePhoneLabel.text = mobilePhone
            }
            
//            if let businessPhones = user.businessPhones {
//                self.businessPhonesLabel.text = "(not implemented)"
//            }
            
            self.emailLabel.text = user.mail
            self.preferredLanguageLabel.text = user.preferredLanguage
        })
    }    
}

