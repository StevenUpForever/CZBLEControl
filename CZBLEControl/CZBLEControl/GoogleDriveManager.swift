//
//  GoogleDriveManager.swift
//  CZBLEControl
//
//  Created by Steven Jia on 8/9/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
//

import UIKit
import GoogleAPIClient
import GTMOAuth2

class GoogleDriveManager: NSObject {
    
    static let sharedManager: GoogleDriveManager = {
        let manager = GoogleDriveManager()
        return manager
    }()
    
    private let serviceDrive = GTLServiceDrive()
    
    override init() {
        serviceDrive.shouldFetchNextPages = true
        serviceDrive.retryEnabled = true
        if let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName(kKeyChainItemName, clientID: kClientId, clientSecret: nil) {
            serviceDrive.authorizer = auth
        }
    }
    
    private let kKeyChainItemName = "CZBLEControl Google Drive"
    private let kClientId = "628215016696-m3b5glkere874v5es45os8mfr23conhd.apps.googleusercontent.com"
    private let scopes = [kGTLAuthScopeDriveMetadata, kGTLAuthScopeDriveFile]
    
    func authorizeGoogleAccount(targetViewController: UIViewController, completionHandler: (authSuccess: Bool) -> Void) {
        if let authorizer = serviceDrive.authorizer, canAuth = authorizer.canAuthorize where canAuth {
            completionHandler(authSuccess: true)
        } else {
            let authViewController = GTMOAuth2ViewControllerTouch.controllerWithScope(scopes.joinWithSeparator(" "), clientID: kClientId, clientSecret: nil, keychainItemName: kKeyChainItemName) { (authController, authResult, error) in
                if error != nil {
                    self.serviceDrive.authorizer = nil
                    completionHandler(authSuccess: false)
                } else {
                    self.serviceDrive.authorizer = authResult
                    authController.dismissViewControllerAnimated(true, completion: nil)
                    completionHandler(authSuccess: true)
                }
            }
            if authViewController is UIViewController {
                targetViewController.presentViewController(authViewController as! UIViewController, animated: true, completion: nil)
            }
        }
    }
    
    func isAuthorized() -> Bool {
        if let authorizer = serviceDrive.authorizer, canAuth = authorizer.canAuthorize where canAuth {
            return true
        } else {
            return false
        }
    }
    
    func deAuthorizeUser() {
        serviceDrive.authorizer = nil
        GTMOAuth2ViewControllerTouch.removeAuthFromKeychainForName(kKeyChainItemName)
    }
    
//    func fetchFiles() {
//        output.text = "Getting files..."
//        let query = GTLQueryDrive.queryForFilesList()
//        query.pageSize = 10
//        query.fields = "nextPageToken, files(id, name)"
//        service.executeQuery(
//            query,
//            delegate: self,
//            didFinishSelector: "displayResultWithTicket:finishedWithObject:error:"
//        )
//    }
//    
//    // Parse results and display
//    func displayResultWithTicket(ticket : GTLServiceTicket,
//                                 finishedWithObject response : GTLDriveFileList,
//                                                    error : NSError?) {
//        
//        if let error = error {
//            showAlert("Error", message: error.localizedDescription)
//            return
//        }
//        
//        var filesString = ""
//        
//        if let files = response.files() where !files.isEmpty {
//            filesString += "Files:\n"
//            for file in files as! [GTLDriveFile] {
//                filesString += "\(file.name) (\(file.identifier))\n"
//            }
//        } else {
//            filesString = "No files found."
//        }
//        
//        output.text = filesString
//    }
//    
//    
//    // Creates the auth controller for authorizing access to Drive API
//    
//    private func createAuthController() -> GTMOAuth2ViewControllerTouch {
//        let scopeString = scopes.joinWithSeparator(" ")
//        return GTMOAuth2ViewControllerTouch(
//            scope: scopeString,
//            clientID: kClientId,
//            clientSecret: nil,
//            keychainItemName: kKeyChainItemName,
//            delegate: self,
//            finishedSelector: "viewController:finishedWithAuth:error:"
//        )
//    }
//    
//    // Handle completion of the authorization process, and update the Drive API
//    // with the new credentials.
//    func viewController(vc : UIViewController,
//                        finishedWithAuth authResult : GTMOAuth2Authentication, error : NSError?) {
//        
//        if let error = error {
//            service.authorizer = nil
//            showAlert("Authentication Error", message: error.localizedDescription)
//            return
//        }
//        
//        service.authorizer = authResult
//        dismissViewControllerAnimated(true, completion: nil)
//    }
//    
//    // Helper for showing an alert
//    
//    func showAlert(title : String, message: String) {
//        let alert = UIAlertController(
//            title: title,
//            message: message,
//            preferredStyle: UIAlertControllerStyle.Alert
//        )
//        let ok = UIAlertAction(
//            title: "OK",
//            style: UIAlertActionStyle.Default,
//            handler: nil
//        )
//        alert.addAction(ok)
//        presentViewController(alert, animated: true, completion: nil)
//    }

}
