//
//  MSGraphController.swift
//  my iOS Swift App
//
//  Created by Chris Tham on 3/12/18.
//  Copyright © 2018 Hello Tham. All rights reserved.
//

import Foundation

class MSGraphController {
    static let clientId = "e810233c-a57b-4300-8c12-633a14c4dc26"
    static let scopes   = ["Files.ReadWrite","User.ReadBasic.All", "User.Read", "Mail.Read", "Calendars.Read", "Contacts.Read"]
    lazy var graphClient: MSGraphClient = {
        
        let client = MSGraphClient.defaultClient()
        return client!
    }()
    var me : MSGraphUser?
    var allUsers : [MSGraphUser]
    var myGroups : [MSGraphGroup]

    init (with authentication: Authentication) {
        MSGraphClient.setAuthenticationProvider(authentication.authenticationProvider)
        allUsers = []
        myGroups = []
    }
    
    // Returns select information about the signed-in user from Azure Active Directory. Applies to personal or work accounts
    func getMe(with completion: @escaping (_ result: Result) -> Void) {
        graphClient.me().request().getWithCompletion {
            (user: MSGraphUser?, error: Error?) in
            
            if let nsError = error {
                completion(.Failure(error: MSGraphError.NSErrorType(error: nsError as NSError)))
            }
            else {
                if let me = user {
                    self.me = me
                    let displayString = "Retrieval of user account information succeeded for \(String(user!.displayName!))"
                    completion(.Success(displayText: displayString))
                }
                else {
                    completion(.Failure(error: error!))
                }

            }
        }
    }
    
    // Returns all of the users in your tenant's directory.
    // Applies to personal or work accounts.
    // nextRequest is a subsequent request if there are more users to be loaded.
    func getUsers(with completion: @escaping (_ result: Result) -> Void) {
        graphClient.users().request().getWithCompletion {
            (userCollection: MSCollection?, nextRequest: MSGraphUsersCollectionRequest?, error: Error?) in
            
            if let nsError = error {
                completion(.Failure(error: MSGraphError.NSErrorType(error: nsError as NSError)))
            }
            else {
                var displayString = "List of users:\n"
                if let users = userCollection {
                    self.allUsers = []
                    
                    for user: MSGraphUser in users.value as! [MSGraphUser] {
                        displayString += user.displayName + "\n"
                        self.allUsers.append(user)
                    }
                }
                
                if let _ = nextRequest {
                    displayString += "Next request available for more users"
                }
                completion(.Success(displayText: displayString))
            }
        }
    }
}

// MARK: - Enum Result
enum Result {
    case Success(displayText: String?)
    case SuccessDownloadImage(displayImage: UIImage?)
    case Failure(error: Error)
}

// MARK: - Protocol Snippet
protocol Snippet {
    func execute(with completion:(_ result: Result) -> Void)
    
    var needAdminAccess: Bool { get }
    var name: String { get }
}

extension Snippet {
    func execute(with completion:(_ result: Result) -> Void) {
        assert(true, "Empty execution body")
    }
}

struct Snippets {
    
    static var graphClient: MSGraphClient = {
        return MSGraphClient.defaultClient()
    }()
}

enum MSGraphError: Error {
    case NSErrorType(error: NSError)
    case UnexpectecError(errorString: String)
}

// Gets a collection of groups that the signed-in user is a member of.
struct GetUserGroups: Snippet {
    let name = "Get user groups"
    let needAdminAccess: Bool = true
    
    func execute(with completion: @escaping (_ result: Result) -> Void) {
        
        Snippets.graphClient.me().memberOf().request().getWithCompletion {
            (userGroupCollection: MSCollection?,
            nextRequest: MSGraphUserMemberOfCollectionWithReferencesRequest?,
            error: Error?) in
            
            if let nsError = error {
                completion(.Failure(error: MSGraphError.NSErrorType(error: nsError as NSError)))
                return
            }
            
            var displayString = "List of groups: \n"
            
            if let userGroups = userGroupCollection {
                for userGroup: MSGraphDirectoryObject in userGroups.value as! [MSGraphDirectoryObject] {
                    guard let name = userGroup.dictionaryFromItem()["displayName"] else {
                        completion(.Failure(error: MSGraphError.UnexpectecError(errorString: "Display name not found")))
                        return
                    }
                    displayString += "\(name)\n"
                }
            }
            if let _ = nextRequest {
                displayString += "Next request available for more groups"
            }
            
            completion(.Success(displayText: displayString))
        }
    }
}
