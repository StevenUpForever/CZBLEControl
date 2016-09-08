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
//        serviceDrive.shouldFetchNextPages = true
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
    
    func saveValueData(title: String, dataArray: [(String, String)], completionHandler: statusMessageHandler) {
        if let data = tupleJoinStr(dataArray).dataUsingEncoding(NSUTF8StringEncoding) {
            uploadData(title, data: data, completionHandler: completionHandler)
        } else {
            completionHandler(success: false, errorMessage: "Data cannot be transferred to file")
        }
    }
    
    func saveWriteAndValueData(title: String, writeArray: [(String, String)], valueArray: [(String, String)], completionHandler: statusMessageHandler) {
        let dataStr = tupleJoinStr(writeArray) + tupleJoinStr(valueArray)
        if let data = dataStr.dataUsingEncoding(NSUTF8StringEncoding) {
            uploadData(title, data: data, completionHandler: completionHandler)
        } else {
            completionHandler(success: false, errorMessage: "Data cannot be transferred to file")
        }
    }
    
    private func tupleJoinStr(dataArray: [(String, String)]) -> String {
        var result = ""
        for tuple in dataArray {
            result.appendContentsOf(tuple.0 + "\n" + tuple.1 + "\n\n")
        }
        return result
    }
    
    private func uploadData(title: String, data: NSData, completionHandler: statusMessageHandler) {
        
        createFolder {[unowned self] (success, errorMessage) in
            if success {
                let parameter = GTLUploadParameters(data: data, MIMEType: "text/plain")
                let driveFile = GTLDriveFile()
                driveFile.name = title
                driveFile.parents = [self.BLEFolder.identifier]
                let query = GTLQueryDrive.queryForFilesCreateWithObject(driveFile, uploadParameters: parameter)
                self.serviceDrive.executeQuery(query, completionHandler: { (ticket, updatedFile, error) in
                    if error != nil {
                        print(error)
                        completionHandler(success: false, errorMessage: "Upload file failed")
                    } else {
                        completionHandler(success: true, errorMessage: "Upload file successfully")
                    }
                })
            } else {
                completionHandler(success: false, errorMessage: errorMessage)
            }
        }
        
    }
    
    //MARK: Fetch data
    
    func loadFiles(completionHandler: (success: Bool, errorMessage: String?, files:[GTLDriveFile]?) -> Void) {
        createFolder {[unowned self] (success, errorMessage) in
            if success {
                let query = GTLQueryDrive.queryForFilesList()
                query.q = "'\(self.BLEFolder.identifier)' in parents and mimeType = 'text/plain'"
                self.serviceDrive.executeQuery(query) { (ticket, files, error) in
                    if error != nil {
                        print(error)
                        completionHandler(success: false, errorMessage: "Error when load file", files: nil)
                    } else if let fileList = files as? GTLDriveFileList {
                        if let filesArray = fileList.files as? [GTLDriveFile] {
                            completionHandler(success: true, errorMessage: "Load files successfully", files: filesArray)
                        } else {
                            completionHandler(success: false, errorMessage: "No file to show", files: nil)
                        }
                    } else {
                        completionHandler(success: false, errorMessage: "Error when load file", files: nil)
                    }
                }
            } else {
                completionHandler(success: false, errorMessage: errorMessage, files: nil)
            }
        }
    }
    
    func readFileContent(driveFile: GTLDriveFile) {
        let fetcher = serviceDrive.fetcherService.fetcherWithURLString("https://www.googleapis.com/drive/v3/files/\(driveFile.identifier)?alt=media")
        fetcher.beginFetchWithCompletionHandler { (data, error) in
            if data != nil {
                let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print(dataString)
            }
        }
//        GTMHTTPFetcher *fetcher =
//            [self.driveService.fetcherService fetcherWithURLString:self.driveFile.downloadUrl];
//        
//        [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
//            [alert dismissWithClickedButtonIndex:0 animated:YES];
//            if (error == nil) {
//            NSString* fileContent = [[NSString alloc] initWithData:data
//            encoding:NSUTF8StringEncoding];
//            self.textView.text = fileContent;
//            self.originalContent = [fileContent copy];
//            } else {
//            NSLog(@"An error occurred: %@", error);
//            [QEUtilities showErrorMessageWithTitle:@"Unable to load file"
//            message:[error description]
//            delegate:self];
//            }
//            }];
        
    }
    
    //MARK: Helper methods
    
    private var BLEFolder: GTLDriveFile!
    
    private func createFolder(completionHandler: statusMessageHandler) {
        let query = GTLQueryDrive.queryForFilesList()
        query.q = "mimeType = 'application/vnd.google-apps.folder' and trashed = false"
        serviceDrive.executeQuery(query) { [unowned self] (checkTicket, files, checkError) in
            if checkError != nil {
                completionHandler(success: false, errorMessage: "Error to find correct folder")
            } else {
                if let tempFileList = files as? GTLDriveFileList {
                    if let fileList = tempFileList.files as? [GTLDriveFile] {
                        var folderExisted = false
                        for folderFile in fileList {
                            if folderFile.name == kFolderName {
                                self.BLEFolder = folderFile
                                folderExisted = true
                                completionHandler(success: true, errorMessage: "Correct folder found")
                                return
                            }
                        }
                        if folderExisted == false {
                            let folder = GTLDriveFile()
                            folder.name = kFolderName
                            folder.mimeType = "application/vnd.google-apps.folder"
                            let newFolderQuery = GTLQueryDrive.queryForFilesCreateWithObject(folder, uploadParameters: nil)
                            self.serviceDrive.executeQuery(newFolderQuery) {[unowned self] (ticket, updatedFile, error) in
                                if error == nil {
                                    if let properFile = updatedFile as? GTLDriveFile {
                                        self.BLEFolder = properFile
                                        completionHandler(success: true, errorMessage: "Create folder successfully")
                                    } else {
                                        completionHandler(success: false, errorMessage: "Create folder failed")
                                    }
                                } else {
                                    completionHandler(success: false, errorMessage: "Create folder failed")
                                }
                            }
                        }
                    } else {
                        completionHandler(success: false, errorMessage: "Files are not correct type")
                    }
                } else {
                    completionHandler(success: false, errorMessage: "Files are not correct type")
                }
            }
        }
    }
    
}
