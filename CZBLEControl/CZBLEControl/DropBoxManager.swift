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
        
//        Dropbox.authorizedClient?.files.listFolder(path: <#T##String#>)
        
        createFolder {[unowned self] (success, errorMessage) in
//            if success {
//                let parameter = GTLUploadParameters(data: data, MIMEType: "text/plain")
//                let driveFile = GTLDriveFile()
//                driveFile.name = title
//                driveFile.parents = [self.BLEFolder.identifier]
//                let query = GTLQueryDrive.queryForFilesCreateWithObject(driveFile, uploadParameters: parameter)
//                self.serviceDrive.executeQuery(query, completionHandler: { (ticket, updatedFile, error) in
//                    if error != nil {
//                        print(error)
//                        completionHandler(success: false, errorMessage: "Upload file failed")
//                    } else {
//                        completionHandler(success: true, errorMessage: "Upload file successfully")
//                    }
//                })
//            } else {
//                completionHandler(success: false, errorMessage: errorMessage)
//            }
        }
        
    }
    
    func createFolder(completionHandler: statusMessageHandler) {
        Dropbox.authorizedClient?.files.listFolder(path: "", recursive: false, includeMediaInfo: false, includeDeleted: false, includeHasExplicitSharedMembers: false).response({ (response, error) in
            if let entries = response?.entries {
                for entry in entries {
                    print(entry.name + "\n" + entry.description)
                    
                    
                }
            }
        })
//        Dropbox.authorizedClient?.files.createFolder(path: <#T##String#>)
    }
    
    

}
