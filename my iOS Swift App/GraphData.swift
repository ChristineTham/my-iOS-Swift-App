//
//  GraphData.swift
//  my iOS Swift App
//
//  Created by Chris Tham on 3/12/18.
//  Copyright © 2018 Hello Tham. All rights reserved.
//

import Foundation

class Office365Data {
    static let clientId = "e810233c-a57b-4300-8c12-633a14c4dc26"
    static let scopes   = ["Files.ReadWrite","User.ReadBasic.All", "User.Read", "Mail.Read", "Calendars.Read", "Contacts.Read"]
    lazy var graphClient: MSGraphClient = {
        
        let client = MSGraphClient.defaultClient()
        return client!
    }()
    var me : MSGraphUser
    var myGroups : [MSGraphGroup]

    init(with authentication: Authentication) {
        MSGraphClient.setAuthenticationProvider(authentication.authenticationProvider)
    }
}

// MARK: - Enum Result
enum Result {
    case Success(displayText: String?)
    case SuccessDownloadImage(displayImage: UIImage?)
    case Failure(error: MSGraphError)
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
