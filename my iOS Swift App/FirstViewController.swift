//
//  FirstViewController.swift
//  my iOS Swift App
//
//  Created by Chris Tham on 30/11/18.
//  Copyright © 2018 Hello Tham. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    let authentication: Authentication = Authentication()
    lazy var graphClient: MSGraphClient = {
        
        let client = MSGraphClient.defaultClient()
        return client!
    }()
    var userInfo : MSGraphUser?
    
    @IBOutlet weak var connectButton: UIBarButtonItem!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        connectButton.title = "Log In"
    }

    @IBAction func connectButtonPressed(_ sender: UIBarButtonItem) {
        let clientId = ApplicationConstants.clientId
        let scopes = ApplicationConstants.scopes
        
        if (connectButton.title == "Log In") {
            authentication.connectToGraph(withClientId: clientId, scopes: scopes) {
                (error) in
                
                if let graphError = error {
                    switch graphError {
                    case .nsErrorType(let nsError):
                        print(NSLocalizedString("ERROR", comment: ""), nsError.localizedDescription)
                    }
                }
                else {
                    self.getUserInfo()
                }
            }
                
            MSGraphClient.setAuthenticationProvider(authentication.authenticationProvider)
            
            connectButton.title = "Log Out"
        }
        else {
            connectButton.title = "Log In"
            authentication.disconnect()
        }
        
        
    }
    
    func getUserInfo() {
        self.graphClient.me().request().getWithCompletion {
            (user: MSGraphUser?, error: Error?) in
            if let graphError = error {
                print(NSLocalizedString("ERROR", comment: ""), graphError)
            }
            else {
                guard let userInfo = user else {
                    print("USER_INFO_LOAD_FAILURE")
                    return
                }
                print("USER_INFO_LOADED")
                self.userInfo = userInfo
                DispatchQueue.main.async(execute: {
                    self.userNameLabel.text = userInfo.displayName
                    self.emailLabel.text = userInfo.mail
                })
            }
        }
    }
    
}

