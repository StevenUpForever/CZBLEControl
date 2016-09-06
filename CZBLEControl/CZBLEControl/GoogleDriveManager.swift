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
    
    //MARK: Save data
    
    func saveValueData(title: String, dataArray: [(String, String)], completionHandler: (success: Bool) -> Void) {
        if let data = tupleJoinStr(dataArray).dataUsingEncoding(NSUTF8StringEncoding) {
            uploadData(title, data: data, completionHandler: completionHandler)
        } else {
            completionHandler(success: false)
        }
    }
    
    func saveWriteAndValueData(title: String, writeArray: [(String, String)], valueArray: [(String, String)], completionHandler: (success: Bool) -> Void) {
        let dataStr = tupleJoinStr(writeArray) + tupleJoinStr(valueArray)
        if let data = dataStr.dataUsingEncoding(NSUTF8StringEncoding) {
            uploadData(title, data: data, completionHandler: completionHandler)
        } else {
            completionHandler(success: false)
        }
    }
    
    private func tupleJoinStr(dataArray: [(String, String)]) -> String {
        var result = ""
        for tuple in dataArray {
            result.appendContentsOf(tuple.0 + "\n" + tuple.1 + "\n\n")
        }
        return result
    }
    
    private func uploadData(title: String, data: NSData, completionHandler: (success: Bool) -> Void) {
        let parameter = GTLUploadParameters(data: data, MIMEType: "text/plain")
        let driveFile = GTLDriveFile()
        driveFile.name = title
        let query = GTLQueryDrive.queryForFilesCreateWithObject(driveFile, uploadParameters: parameter)
        serviceDrive.executeQuery(query, completionHandler: { (ticket, updatedFile, error) in
            if error != nil {
                completionHandler(success: false)
            } else {
                completionHandler(success: true)
            }
        })
    }
    
    //MARK: Fetch data
    
    func loadFiles(completionHandler: (success: Bool, files :[GTLDriveFile]?) -> Void) {
        let query = GTLQueryDrive.queryForFilesList()
        query.q = "mimeType = 'text/plain'"
        serviceDrive.executeQuery(query) { (ticket, files, error) in
            if error != nil {
                completionHandler(success: false, files: nil)
            } else if let fileList = files as? GTLDriveFileList {
                if let filesArray = fileList.files as? [GTLDriveFile] {
                    completionHandler(success: true, files: filesArray)
                } else {
                    completionHandler(success: false, files: nil)
                }
            } else {
                completionHandler(success: false, files: nil)
            }
        }
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

}
