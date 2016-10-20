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
            completionHandler(false, "Data cannot be transferred to file")
        }
    }
    
    func saveWriteAndValueData(_ title: String, writeArray: [(String, String)], valueArray: [(String, String)], completionHandler: @escaping statusMessageHandler) {
        let dataStr = "Write Value\n\n" + tupleJoinStr(writeArray) + "Read Value\n\n" + tupleJoinStr(valueArray)
        if let data = dataStr.data(using: String.Encoding.utf8) {
            uploadData(title, data: data, completionHandler: completionHandler)
        } else {
            completionHandler(false, "Data cannot be transferred to file")
        }
    }
    
    fileprivate func uploadData(_ title: String, data: Data, completionHandler: @escaping statusMessageHandler) {
        createFolder {(success, errorMessage) in
            if success {
                DropboxClientsManager.authorizedClient?.files.upload(path: "/\(kFolderName)/\(title).txt", input: data).response(completionHandler: { (metaData, error) in
                    if error != nil {
                        completionHandler(false, "Upload file failed")
                    } else if metaData != nil {
                        completionHandler(true, "Upload file successfully")
                    } else {
                        completionHandler(false, "File data unavailable")
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
                completionHandler(false, "Error when chenck file list")
            } else if let entries = response?.entries {
                var folderExisted = false
                for entry in entries {
                    if entry.name == kFolderName {
                        self.DropboxFolder = entry
                        folderExisted = true
                        completionHandler(true, "Folder existed")
                        return
                    }
                }
                if !folderExisted {
                    DropboxClientsManager.authorizedClient?.files.createFolder(path: "/\(kFolderName)").response(completionHandler: { (fileMetaData, error) in
                        if error != nil {
                            completionHandler(false, "Create folder failed")
                        } else if fileMetaData != nil {
                            self.DropboxFolder = fileMetaData!
                            completionHandler(true, "Create folder successfully")
                        } else {
                            completionHandler(false, "Folder data unavailable")
                        }
                    })
                }
            } else {
                completionHandler(false, "No data available")
            }
        })
    }
    
    func loadFileList(_ completionHandler: @escaping (_ success: Bool, _ dataArray: [Files.Metadata]?, _ errorMessage: String?) -> Void) {
        DropboxClientsManager.authorizedClient?.files.listFolder(path: "/\(kFolderName)", recursive: false, includeMediaInfo: false, includeDeleted: false, includeHasExplicitSharedMembers: false).response(completionHandler: { (response, error) in
            if error != nil {
                completionHandler(false, nil, "Error when chenck file list")
            } else if let filesList = response?.entries {
                let validTextList = filesList.filter({ (file) -> Bool in
                    file.name.hasSuffix(".txt")
                })
                completionHandler(true, validTextList, "Successfully get files list")
            } else {
                completionHandler(false, nil, "Error when chenck file list")
            }
        })
    }
    
    func readFileContent(_ fileObj: Files.Metadata, completionHandler: @escaping (_ success: Bool, _ dataArray: [[NSString]]?, _ errorMessage: String?) -> Void) {
        DropboxClientsManager.authorizedClient?.files.download(path: "/\(kFolderName)/\(fileObj.name)", rev: nil, overwrite: true, destination: { (url, urlResponse) -> URL in
            let pathStr = NSTemporaryDirectory() + fileObj.name
            return NSURL(fileURLWithPath: pathStr) as URL
        }).response(completionHandler: { (response, error) in
            if error != nil {
                completionHandler(false, nil, "Failed to read file content")
            } else if let (_, url) = response {
                if let data = NSData(contentsOf: url) {
                    if let dataString = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue) {
                        completionHandler(true, dataString.parseToDataTableView(), "Parse file content successfully")
                    } else {
                        completionHandler(false, nil, "Failed to parse file content")
                    }
                } else {
                    completionHandler(false, nil, "Failed to transfer file content")
                }
            } else {
                completionHandler(false, nil, "Failed to read file content")
            }
        })
    }
    
    func deleteFile(_ fileObj: Files.Metadata, completionHandler: @escaping statusMessageHandler) {
        DropboxClientsManager.authorizedClient?.files.delete(path: "/\(kFolderName)/\(fileObj.name)").response(completionHandler: { (response, error) in
            if error != nil {
                completionHandler(false, "Failed to delete the file")
            } else {
                completionHandler(true, "Successfully delete the file")
            }
        })
    }
    
}
