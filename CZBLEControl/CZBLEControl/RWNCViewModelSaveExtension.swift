//
//  RWNCViewModelSaveExtension.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 9/5/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
//

import UIKit
import SwiftyDropbox

extension RWNCViewModel: dropboxDelegate {
    
    //MARK: Google Drive
    
    func uploadToGoogleDrive(_ fileName: String, target: UIViewController, completionHandler: @escaping statusMessageHandler) {
        if googleDriveManager.isAuthorized() {
            googleDriveSaveData(fileName, completionHandler: completionHandler)
        } else {
            googleDriveManager.authorizeGoogleAccount(target, completionHandler: { [weak self] (authSuccess) in
                if let strongSelf = self , authSuccess {
                    strongSelf.googleDriveSaveData(fileName, completionHandler: completionHandler)
                } else {
                    completionHandler(false, "Authorize user failed")
                }
            })
        }
    }
    
    fileprivate func googleDriveSaveData(_ fileName: String, completionHandler: @escaping statusMessageHandler) {
        if identifier == .write {
            googleDriveManager.saveWriteAndValueData(fileName , writeArray: writeValueArray, valueArray: valueArray, completionHandler: completionHandler)
        } else {
            googleDriveManager.saveValueData(fileName , dataArray: valueArray, completionHandler: completionHandler)
        }
    }
    
    //MARK: Dropbox
    
    func uploadToDropbox(_ fileName: String, target: UIViewController, completionHandler: @escaping statusMessageHandler) {
        dropboxManager.delegate = self
        if dropboxManager.isAuthorized() {
            dropboxSaveData(fileName, completionHandler: completionHandler)
        } else {
            tempInfo = tempUploadInfo(tempFileName: fileName, tempTarget: target, completionHandler: completionHandler)
            dropboxManager.authorizeUser(target)
        }
    }
    
    fileprivate func dropboxSaveData(_ fileName: String, completionHandler: @escaping statusMessageHandler) {
        if identifier == .write {
            dropboxManager.saveWriteAndValueData(fileName , writeArray: writeValueArray, valueArray: valueArray, completionHandler: completionHandler)
        } else {
            dropboxManager.saveValueData(fileName , dataArray: valueArray, completionHandler: completionHandler)
        }
    }
    
    func didFinishAuthorizeUser(_ success: Bool, token: DropboxAccessToken?, error: OAuth2Error?, errorMessage: String?) {
        if success && tempInfo != nil {
            uploadToDropbox(tempInfo!.tempFileName, target: tempInfo!.tempTarget, completionHandler: tempInfo!.completionHandler)
        } else {
            if tempInfo != nil {
                CustomAlertController.showCancelAlertController(errorMessage, message: nil, target: tempInfo!.tempTarget)
            }
        }
    }
    
    func saveDataToCoreData(_ fileName: String, completionHandler: @escaping statusMessageHandler) {
        
    }
    
}
