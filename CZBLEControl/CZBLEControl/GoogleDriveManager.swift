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
    
    fileprivate let serviceDrive = GTLServiceDrive()
    
    override init() {
//        serviceDrive.shouldFetchNextPages = true
        serviceDrive.isRetryEnabled = true
        if let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychain(forName: kKeyChainItemName, clientID: kClientId, clientSecret: nil) {
            serviceDrive.authorizer = auth
        }
    }
    
    fileprivate let kKeyChainItemName = "CZBLEControl Google Drive"
    fileprivate let kClientId = "628215016696-m3b5glkere874v5es45os8mfr23conhd.apps.googleusercontent.com"
    fileprivate let scopes = [kGTLAuthScopeDriveMetadata, kGTLAuthScopeDriveFile]
    
    func authorizeGoogleAccount(_ targetViewController: UIViewController, completionHandler: @escaping (_ authSuccess: Bool) -> Void) {
        if let authorizer = serviceDrive.authorizer, let canAuth = authorizer.canAuthorize, canAuth {
            completionHandler(true)
        } else {
            let authViewController = GTMOAuth2ViewControllerTouch.controller(withScope: scopes.joined(separator: " "), clientID: kClientId, clientSecret: nil, keychainItemName: kKeyChainItemName) { (authController, authResult, error) in
                if error != nil {
                    self.serviceDrive.authorizer = nil
                    completionHandler(false)
                } else {
                    self.serviceDrive.authorizer = authResult
                    authController?.dismiss(animated: true, completion: nil)
                    completionHandler(true)
                }
            }
            if authViewController is UIViewController {
                targetViewController.present(authViewController as! UIViewController, animated: true, completion: nil)
            }
        }
    }
    
    func isAuthorized() -> Bool {
        if let authorizer = serviceDrive.authorizer, let canAuth = authorizer.canAuthorize, canAuth {
            return true
        } else {
            return false
        }
    }
    
    func deAuthorizeUser() {
        serviceDrive.authorizer = nil
        GTMOAuth2ViewControllerTouch.removeAuthFromKeychain(forName: kKeyChainItemName)
    }
    
    //MARK: Save data
    
    func saveValueData(_ title: String, dataArray: [(String, String)], completionHandler: @escaping statusMessageHandler) {
        if let data = tupleJoinStr(dataArray).data(using: String.Encoding.utf8) {
            uploadData(title, data: data, completionHandler: completionHandler)
        } else {
            completionHandler(false, NSLocalizedString("Data cannot be transferred to file", comment: ""))
        }
    }
    
    func saveWriteAndValueData(_ title: String, writeArray: [(String, String)], valueArray: [(String, String)], completionHandler: @escaping statusMessageHandler) {
        let dataStr = NSLocalizedString("Write Value", comment: "") + "\n\n" + tupleJoinStr(writeArray) + NSLocalizedString("Read Value", comment: "") + "\n\n" +  tupleJoinStr(valueArray)
        if let data = dataStr.data(using: String.Encoding.utf8) {
            uploadData(title, data: data, completionHandler: completionHandler)
        } else {
            completionHandler(false, NSLocalizedString("Data cannot be transferred to file", comment: ""))
        }
    }
    
    fileprivate func uploadData(_ title: String, data: Data, completionHandler: @escaping statusMessageHandler) {
        
        createFolder {[unowned self] (success, errorMessage) in
            if success {
                let parameter = GTLUploadParameters(data: data, mimeType: "text/plain")
                let driveFile = GTLDriveFile()
                driveFile.name = title
                driveFile.parents = [self.BLEFolder.identifier]
                let query = GTLQueryDrive.queryForFilesCreate(withObject: driveFile, uploadParameters: parameter)
                self.serviceDrive.executeQuery(query!, completionHandler: { (ticket, updatedFile, error) in
                    if error != nil {
                        print(error ?? "Error")
                        completionHandler(false, NSLocalizedString("Upload file failed", comment: ""))
                    } else {
                        completionHandler(true, NSLocalizedString("Upload file successfully", comment: ""))
                    }
                })
            } else {
                completionHandler(false, errorMessage)
            }
        }
        
    }
    
    //MARK: Fetch data
    
    func loadFiles(_ completionHandler: @escaping (_ success: Bool, _ errorMessage: String?, _ files:[GTLDriveFile]?) -> Void) {
        createFolder {[unowned self] (success, errorMessage) in
            if success {
                if let query = GTLQueryDrive.queryForFilesList() {
                    query.q = "'\(self.BLEFolder.identifier ?? "")' in parents and mimeType = 'text/plain'"
                    self.serviceDrive.executeQuery(query) { (ticket, files, error) in
                        if error != nil {
                            print(error ?? "Error")
                            completionHandler(false, NSLocalizedString("Load data failed", comment: ""), nil)
                        } else if let fileList = files as? GTLDriveFileList {
                            if let filesArray = fileList.files as? [GTLDriveFile] {
                                completionHandler(true, NSLocalizedString("Load data successfully", comment: ""), filesArray)
                            } else {
                                completionHandler(false, NSLocalizedString("No file to show", comment: ""), nil)
                            }
                        } else {
                            completionHandler(false, NSLocalizedString("Load data failed", comment: ""), nil)
                        }
                    }
                } else {
                    completionHandler(false, NSLocalizedString("Cannot query files", comment: ""), nil)
                }
            } else {
                completionHandler(false, errorMessage, nil)
            }
        }
    }
    
    func readFileContent(_ driveFile: GTLDriveFile, completionHandler: @escaping (_ success: Bool, _ dataArray: [[NSString]]?, _ errorMessage: String?) -> Void) {
        let fetcher = serviceDrive.fetcherService.fetcher(withURLString: "https://www.googleapis.com/drive/v3/files/\(driveFile.identifier ?? "")?alt=media")
        fetcher.beginFetch { (data, error) in
            if error != nil {
                completionHandler(false, nil, NSLocalizedString("Failed to download file", comment: ""))
            } else if data != nil {
                if let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) {
                    completionHandler(true, dataString.parseToDataTableView(), NSLocalizedString("Load data successfully", comment: ""))
                } else {
                    completionHandler(false, nil, NSLocalizedString("Load data failed", comment: ""))
                }
            } else {
                completionHandler(false, nil, NSLocalizedString("Unknown error to download file", comment: ""))
            }
        }
    }
    
    func deleteFile(_ driveFile: GTLDriveFile, completionHandler: @escaping statusMessageHandler) {
        let query = GTLQueryDrive.queryForFilesDelete(withFileId: driveFile.identifier)
        serviceDrive.executeQuery(query!) { (ticket, files, error) in
            if error != nil {
                completionHandler(false, NSLocalizedString("Failed to delete the file", comment: ""))
            } else {
                completionHandler(true, NSLocalizedString("Successfully delete the file", comment: ""))
            }
        }
    }
    
    //MARK: Helper methods
    
    fileprivate var BLEFolder: GTLDriveFile!
    
    fileprivate func createFolder(_ completionHandler: @escaping statusMessageHandler) {
        let query = GTLQueryDrive.queryForFilesList()
        query?.q = "mimeType = 'application/vnd.google-apps.folder' and trashed = false"
        serviceDrive.executeQuery(query!) { [unowned self] (checkTicket, files, checkError) in
            if checkError != nil {
                completionHandler(false, NSLocalizedString("Cannotfind correct folder", comment: ""))
            } else {
                if let tempFileList = files as? GTLDriveFileList {
                    if let fileList = tempFileList.files as? [GTLDriveFile] {
                        var folderExisted = false
                        for folderFile in fileList {
                            if folderFile.name == kFolderName {
                                self.BLEFolder = folderFile
                                folderExisted = true
                                completionHandler(true, NSLocalizedString("Correct folder found", comment: ""))
                                return
                            }
                        }
                        if folderExisted == false {
                            let folder = GTLDriveFile()
                            folder.name = kFolderName
                            folder.mimeType = "application/vnd.google-apps.folder"
                            let newFolderQuery = GTLQueryDrive.queryForFilesCreate(withObject: folder, uploadParameters: nil)
                            self.serviceDrive.executeQuery(newFolderQuery!) {[unowned self] (ticket, updatedFile, error) in
                                if error == nil {
                                    if let properFile = updatedFile as? GTLDriveFile {
                                        self.BLEFolder = properFile
                                        completionHandler(true, NSLocalizedString("Create folder successfully", comment: ""))
                                    } else {
                                        completionHandler(false, NSLocalizedString("Create folder failed", comment: ""))
                                    }
                                } else {
                                    completionHandler(false, NSLocalizedString("Create folder failed", comment: ""))
                                }
                            }
                        }
                    } else {
                        completionHandler(false, NSLocalizedString("Files are not in correct type", comment: ""))
                    }
                } else {
                    completionHandler(false, NSLocalizedString("Files are not in correct type", comment: ""))
                }
            }
        }
    }
    
}
