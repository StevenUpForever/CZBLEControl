//
//  DropBoxManager.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 9/3/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
//

import UIKit
import SwiftyDropbox

protocol dropboxDelegate: class {
    func didFinishAuthorizeUser(_ success: Bool, token: DropboxAccessToken?, error: OAuth2Error?, errorMessage: String?)
}

class DropBoxManager: NSObject {
    
    weak var delegate: dropboxDelegate?
    
    static let sharedManager: DropBoxManager = {
        let manager = DropBoxManager()
        return manager
    }()
    
    func authorizeUser(_ viewControllerTarget: UIViewController) {
        DropboxClientsManager.authorizeFromController(UIApplication.shared,
                                                      controller: viewControllerTarget,
                                                      openURL: { (url: URL) -> Void in
                                                        UIApplication.shared.openURL(url)
        })
    }
    
    func deauthorizeUser() {
        DropboxClientsManager.unlinkClients()
    }
    
    func isAuthorized() -> Bool {
        return DropboxClientsManager.authorizedClient != nil
    }
    
    //Save Data
    
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
        createFolder {(success, errorMessage) in
            if success {
                DropboxClientsManager.authorizedClient?.files.upload(path: "/\(kFolderName)/\(title).txt", input: data).response(completionHandler: { (metaData, error) in
                    if error != nil {
                        completionHandler(false, NSLocalizedString("Upload file failed", comment: ""))
                    } else if metaData != nil {
                        completionHandler(true, NSLocalizedString("Upload file successfully", comment: ""))
                    } else {
                        completionHandler(false, NSLocalizedString("Data unavailable", comment: ""))
                    }
                })
            } else {
                completionHandler(false, errorMessage)
            }
        }
    }
    
    fileprivate var DropboxFolder: Files.Metadata!
    
    fileprivate func createFolder(_ completionHandler: @escaping statusMessageHandler) {
        DropboxClientsManager.authorizedClient?.files.listFolder(path: "", recursive: false, includeMediaInfo: false, includeDeleted: false, includeHasExplicitSharedMembers: false).response(completionHandler: { (response, error) in
            if error != nil {
                completionHandler(false, NSLocalizedString("Failed to download file", comment: ""))
            } else if let entries = response?.entries {
                var folderExisted = false
                for entry in entries {
                    if entry.name == kFolderName {
                        self.DropboxFolder = entry
                        folderExisted = true
                        completionHandler(true, NSLocalizedString("Correct folder found", comment: ""))
                        return
                    }
                }
                if !folderExisted {
                    DropboxClientsManager.authorizedClient?.files.createFolder(path: "/\(kFolderName)").response(completionHandler: { (fileMetaData, error) in
                        if error != nil {
                            completionHandler(false, NSLocalizedString("Create folder failed", comment: ""))
                        } else if fileMetaData != nil {
                            self.DropboxFolder = fileMetaData!
                            completionHandler(true, NSLocalizedString("Create folder successfully", comment: ""))
                        } else {
                            completionHandler(false, NSLocalizedString("Data unavailable", comment: ""))
                        }
                    })
                }
            } else {
                completionHandler(false, NSLocalizedString("Data unavailable", comment: ""))
            }
        })
    }
    
    func loadFileList(_ completionHandler: @escaping (_ success: Bool, _ dataArray: [Files.Metadata]?, _ errorMessage: String?) -> Void) {
        DropboxClientsManager.authorizedClient?.files.listFolder(path: "/\(kFolderName)", recursive: false, includeMediaInfo: false, includeDeleted: false, includeHasExplicitSharedMembers: false).response(completionHandler: { (response, error) in
            if error != nil {
                completionHandler(false, nil, NSLocalizedString("No file to show", comment: ""))
            } else if let filesList = response?.entries {
                let validTextList = filesList.filter({ (file) -> Bool in
                    file.name.hasSuffix(".txt")
                })
                completionHandler(true, validTextList, NSLocalizedString("Load data successfully", comment: ""))
            } else {
                completionHandler(false, nil, NSLocalizedString("Cannot query files", comment: ""))
            }
        })
    }
    
    func readFileContent(_ fileObj: Files.Metadata, completionHandler: @escaping (_ success: Bool, _ dataArray: [[NSString]]?, _ errorMessage: String?) -> Void) {
        DropboxClientsManager.authorizedClient?.files.download(path: "/\(kFolderName)/\(fileObj.name)", rev: nil, overwrite: true, destination: { (url, urlResponse) -> URL in
            let pathStr = NSTemporaryDirectory() + fileObj.name
            return NSURL(fileURLWithPath: pathStr) as URL
        }).response(completionHandler: { (response, error) in
            if error != nil {
                completionHandler(false, nil, NSLocalizedString("Load data failed", comment: ""))
            } else if let (_, url) = response {
                if let data = NSData(contentsOf: url) {
                    if let dataString = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue) {
                        completionHandler(true, dataString.parseToDataTableView(), NSLocalizedString("Load data successfully", comment: ""))
                    } else {
                        completionHandler(false, nil, NSLocalizedString("Load data failed", comment: ""))
                    }
                } else {
                    completionHandler(false, nil, NSLocalizedString("Data cannot be transferred to file", comment: ""))
                }
            } else {
                completionHandler(false, nil, NSLocalizedString("Load data failed", comment: ""))
            }
        })
    }
    
    func deleteFile(_ fileObj: Files.Metadata, completionHandler: @escaping statusMessageHandler) {
        DropboxClientsManager.authorizedClient?.files.delete(path: "/\(kFolderName)/\(fileObj.name)").response(completionHandler: { (response, error) in
            if error != nil {
                completionHandler(false, NSLocalizedString("Failed to delete the file", comment: ""))
            } else {
                completionHandler(true, NSLocalizedString("Successfully delete the file", comment: ""))
            }
        })
    }
    
}
