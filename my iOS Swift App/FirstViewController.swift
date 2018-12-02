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
                self.getProfile()
            }
        }

    }
    
    private func getProfile () {
        
    }
    
}

