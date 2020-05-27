//
//  GoogleDriveManager.swift
//  CZBLEControl
//
//  Created by Steven Jia on 8/9/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST
import GTMAppAuth
import AppAuth

class GoogleDriveManager: NSObject {
    
    static let sharedManager = GoogleDriveManager()
    
    let driveService = GTLRDriveService()
    
    fileprivate var BLEFolder: GTLRDrive_File?

    override init() {
        super.init()
        
        driveService.isRetryEnabled = true
        
        AuthManager.shared.authGSuiteFromKeyChain()
        
        driveService.authorizer = AuthManager.shared.authorization
    }
    
    var isAuthorized: Bool {
        if let authorization = AuthManager.shared.authorization,
            authorization.canAuthorize() {
            return true
        } else {
            return false
        }
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
                let parameter = GTLRUploadParameters(data: data, mimeType: "text/plain")
                let driveFile = GTLRDrive_File()
                driveFile.name = title
                if let identifier = self.BLEFolder?.identifier {
                    driveFile.parents = [identifier]
                }

                let query = GTLRDriveQuery_FilesCreate.query(withObject: driveFile, uploadParameters: parameter)
                self.driveService.executeQuery(query, completionHandler: { (ticket, updatedFile, error) in
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
    
    func loadFiles(_ completionHandler: @escaping (_ success: Bool, _ errorMessage: String?, _ files:[GTLRDrive_File]?) -> Void) {
        let query = GTLRDriveQuery_FilesList.query()
        query.q = "'\(self.BLEFolder?.identifier ?? "")' in parents and mimeType = 'text/plain'"
        self.driveService.executeQuery(query) { (ticket, files, error) in
            if error != nil {
                print(error ?? "Error")
                
                let errorDescription: String
                if ticket.statusCode == 404 {
                    errorDescription = "No CZBLEControl folder found in the drive."
                } else {
                    errorDescription = "load files failed"
                }
                completionHandler(false, NSLocalizedString(errorDescription, comment: ""), nil)
            } else if let fileList = files as? GTLRDrive_FileList {
                if let filesArray = fileList.files {
                    completionHandler(true, NSLocalizedString("Load data successfully", comment: ""), filesArray)
                } else {
                    completionHandler(false, NSLocalizedString("No file to show", comment: ""), nil)
                }
            } else {
                completionHandler(false, NSLocalizedString("Load data failed", comment: ""), nil)
            }
        }
    }
    
    func readFileContent(_ driveFile: GTLRDrive_File, completionHandler: @escaping (_ success: Bool, _ dataArray: [[NSString]]?, _ errorMessage: String?) -> Void) {
        let fetcher = driveService.fetcherService.fetcher(withURLString: "https://www.googleapis.com/drive/v3/files/\(driveFile.identifier ?? "")?alt=media")
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
    
    func deleteFile(_ driveFile: GTLRDrive_File, completionHandler: @escaping statusMessageHandler) {
        if let identifier = driveFile.identifier {
            let query = GTLRDriveQuery_FilesDelete.query(withFileId: identifier)
            driveService.executeQuery(query) { (ticket, files, error) in
                if error != nil {
                    completionHandler(false, NSLocalizedString("Failed to delete the file", comment: ""))
                } else {
                    completionHandler(true, NSLocalizedString("Successfully delete the file", comment: ""))
                }
            }
        } else {
            completionHandler(false, NSLocalizedString("No such file associated to this file identifier", comment: ""))
        }
    }
    
    //MARK: Helper methods
    
    fileprivate func createFolder(_ completionHandler: @escaping statusMessageHandler) {
        let query = GTLRDriveQuery_FilesList.query()
        query.q = "mimeType = 'application/vnd.google-apps.folder' and trashed = false"
        driveService.executeQuery(query) { [weak self] (checkTicket, files, checkError) in
            guard let strongSelf = self else {
                return
            }
            if checkError != nil {
                completionHandler(false, NSLocalizedString("Cannot find correct folder", comment: ""))
            } else {
                if let tempFileList = files as? GTLRDrive_FileList {
                    if let fileList = tempFileList.files {
                        var folderExisted = false
                        for folderFile in fileList {
                            if folderFile.name == kFolderName {
                                strongSelf.BLEFolder = folderFile
                                folderExisted = true
                                completionHandler(true, NSLocalizedString("Correct folder found", comment: ""))
                                return
                            }
                        }
                        if folderExisted == false {
                            let folder = GTLRDrive_File()
                            folder.name = kFolderName
                            folder.mimeType = "application/vnd.google-apps.folder"
                            let newFolderQuery = GTLRDriveQuery_FilesCreate.query(
                                withObject: folder,
                                uploadParameters: nil)
                            strongSelf.driveService.executeQuery(newFolderQuery) {[weak self] (ticket, updatedFile, error) in
                                guard let strongSelf = self else {
                                    return
                                }
                                if error == nil {
                                    if let properFile = updatedFile as? GTLRDrive_File {
                                        strongSelf.BLEFolder = properFile
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
