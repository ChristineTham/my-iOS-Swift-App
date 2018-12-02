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
    
    @IBOutlet weak var connectButton: UIBarButtonItem!
    @IBOutlet weak var userNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        

    }

    @IBAction func connectButtonPressed(_ sender: UIBarButtonItem) {
        let clientId = ApplicationConstants.clientId
        let scopes = ApplicationConstants.scopes
        
        authentication.connectToGraph(withClientId: clientId, scopes: scopes) {
            (error) in
            
            if let graphError = error {
                switch graphError {
                case .nsErrorType(let nsError):
                    print(NSLocalizedString("ERROR", comment: ""), nsError.localizedDescription)
                }
            }
            else {
                self.getUserInfo() { (user) in
                    print("USER_INFO_LOADED")
                    self.userNameLabel.text = user.displayName
                }
            }
        }
        
        MSGraphClient.setAuthenticationProvider(authentication.authenticationProvider)
    }
    
    func getUserInfo(with completion: @escaping (_ grapUser: MSGraphUser) ->Void){
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
                completion(userInfo)
            }
        }
    }
    
}

