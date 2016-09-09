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
    func didFinishAuthorizeUser(success: Bool, token: DropboxAccessToken?, error: OAuth2Error?, errorMessage: String?)
}

class DropBoxManager: NSObject {
    
    weak var delegate: dropboxDelegate?
    
    static let sharedManager: DropBoxManager = {
        let manager = DropBoxManager()
        return manager
    }()
    
    func authorizeUser(viewControllerTarget: UIViewController) {
        Dropbox.authorizeFromController(viewControllerTarget)
    }
    
    func deauthorizeUser() {
        Dropbox.unlinkClient()
    }
    
    func isAuthorized() -> Bool {
        return Dropbox.authorizedClient != nil
    }
    
    //Save Data
    
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
    
    private func uploadData(title: String, data: NSData, completionHandler: statusMessageHandler) {
        createFolder {(success, errorMessage) in
            if success {
                Dropbox.authorizedClient?.files.upload(path: "/\(kFolderName)/\(title).txt", input: data).response({ (metaData, error) in
                    if error != nil {
                        completionHandler(success: false, errorMessage: "Upload file failed")
                    } else if metaData != nil {
                        completionHandler(success: true, errorMessage: "Upload file successfully")
                    } else {
                        completionHandler(success: false, errorMessage: "File data unavailable")
                    }
                })
            } else {
                completionHandler(success: false, errorMessage: errorMessage)
            }
        }
    }
    
    private var DropboxFolder: Files.Metadata!
    
    private func createFolder(completionHandler: statusMessageHandler) {
        Dropbox.authorizedClient?.files.listFolder(path: "", recursive: false, includeMediaInfo: false, includeDeleted: false, includeHasExplicitSharedMembers: false).response({ (response, error) in
            if error != nil {
                completionHandler(success: false, errorMessage: "Error when chenck file list")
            } else if let entries = response?.entries {
                var folderExisted = false
                for entry in entries {
                    if entry.name == kFolderName {
                        self.DropboxFolder = entry
                        folderExisted = true
                        completionHandler(success: true, errorMessage: "Folder existed")
                        return
                    }
                }
                if !folderExisted {
                    Dropbox.authorizedClient?.files.createFolder(path: "/\(kFolderName)").response({ (fileMetaData, error) in
                        if error != nil {
                            completionHandler(success: false, errorMessage: "Create folder failed")
                        } else if fileMetaData != nil {
                            self.DropboxFolder = fileMetaData!
                            completionHandler(success: true, errorMessage: "Create folder successfully")
                        } else {
                            completionHandler(success: false, errorMessage: "Folder data unavailable")
                        }
                    })
                }
            } else {
                completionHandler(success: false, errorMessage: "No data available")
            }
        })
    }
    
    func loadFileList(completionHandler: (success: Bool, dataArray: [Files.Metadata]?, errorMessage: String?) -> Void) {
        Dropbox.authorizedClient?.files.listFolder(path: "/\(kFolderName)", recursive: false, includeMediaInfo: false, includeDeleted: false, includeHasExplicitSharedMembers: false).response({ (response, error) in
            if error != nil {
                completionHandler(success: false, dataArray: nil, errorMessage: "Error when chenck file list")
            } else if let filesList = response?.entries {
                let validTextList = filesList.filter({ (file) -> Bool in
                    file.name.hasSuffix(".txt")
                })
                completionHandler(success: true, dataArray: validTextList, errorMessage: "Successfully get files list")
            } else {
                completionHandler(success: false, dataArray: nil, errorMessage: "Error when chenck file list")
            }
        })
    }
    
    func readFileContent(fileObj: Files.Metadata, completionHandler: (success: Bool, dataArray: [[NSString]]?, errorMessage: String?) -> Void) {
        Dropbox.authorizedClient?.files.download(path: "/\(kFolderName)/\(fileObj.name)", rev: nil, overwrite: true, destination: { (url, urlResponse) -> NSURL in
            let pathStr = NSTemporaryDirectory().stringByAppendingString(fileObj.name)
            return NSURL(fileURLWithPath: pathStr)
        }).response({ (response, error) in
            if error != nil {
                completionHandler(success: false, dataArray: nil, errorMessage: "Failed to read file content")
            } else if let (_, url) = response {
                if let data = NSData(contentsOfURL: url) {
                    if let dataString = NSString(data: data, encoding: NSUTF8StringEncoding) {
                        completionHandler(success: true, dataArray: dataString.parseToDataTableView(), errorMessage: "Parse file content successfully")
                    } else {
                        completionHandler(success: false, dataArray: nil, errorMessage: "Failed to parse file content")
                    }
                } else {
                    completionHandler(success: false, dataArray: nil, errorMessage: "Failed to transfer file content")
                }
            } else {
                completionHandler(success: false, dataArray: nil, errorMessage: "Failed to read file content")
            }
        })
    }
    
}
