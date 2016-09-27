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
            completionHandler(false, "Data cannot be transferred to file")
        }
    }
    
    func saveWriteAndValueData(_ title: String, writeArray: [(String, String)], valueArray: [(String, String)], completionHandler: @escaping statusMessageHandler) {
        let dataStr = "Write Value\n\n" + tupleJoinStr(writeArray) + "Read Value\n\n" +  tupleJoinStr(valueArray)
        if let data = dataStr.data(using: String.Encoding.utf8) {
            uploadData(title, data: data, completionHandler: completionHandler)
        } else {
            completionHandler(false, "Data cannot be transferred to file")
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
                        print(error)
                        completionHandler(false, "Upload file failed")
                    } else {
                        completionHandler(true, "Upload file successfully")
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
                            print(error)
                            completionHandler(false, "Error when load file", nil)
                        } else if let fileList = files as? GTLDriveFileList {
                            if let filesArray = fileList.files as? [GTLDriveFile] {
                                completionHandler(true, "Load files successfully", filesArray)
                            } else {
                                completionHandler(false, "No file to show", nil)
                            }
                        } else {
                            completionHandler(false, "Error when load file", nil)
                        }
                    }
                } else {
                    completionHandler(false, "Cannot query files", nil)
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
                completionHandler(false, nil, "Failed to download file")
            } else if data != nil {
                if let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) {
                    completionHandler(true, dataString.parseToDataTableView(), "Parse file content successfully")
                } else {
                    completionHandler(false, nil, "Failed to parse file content")
                }
            } else {
                completionHandler(false, nil, "Unknown error to download file")
            }
        }
    }
    
    func deleteFile(_ driveFile: GTLDriveFile, completionHandler: @escaping statusMessageHandler) {
        let query = GTLQueryDrive.queryForFilesDelete(withFileId: driveFile.identifier)
        serviceDrive.executeQuery(query!) { (ticket, files, error) in
            if error != nil {
                completionHandler(false, "Failed to delete the file")
            } else {
                completionHandler(true, "Successfully delete the file")
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
                completionHandler(false, "Error to find correct folder")
            } else {
                if let tempFileList = files as? GTLDriveFileList {
                    if let fileList = tempFileList.files as? [GTLDriveFile] {
                        var folderExisted = false
                        for folderFile in fileList {
                            if folderFile.name == kFolderName {
                                self.BLEFolder = folderFile
                                folderExisted = true
                                completionHandler(true, "Correct folder found")
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
                                        completionHandler(true, "Create folder successfully")
                                    } else {
                                        completionHandler(false, "Create folder failed")
                                    }
                                } else {
                                    completionHandler(false, "Create folder failed")
                                }
                            }
                        }
                    } else {
                        completionHandler(false, "Files are not correct type")
                    }
                } else {
                    completionHandler(false, "Files are not correct type")
                }
            }
        }
    }
    
}
