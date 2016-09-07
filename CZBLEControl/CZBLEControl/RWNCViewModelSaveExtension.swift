//
//  RWNCViewModelSaveExtension.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 9/5/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
//

import UIKit

extension RWNCViewModel {
    
    //MARK: Google Drive
    
    func uploadToGoogleDrive(fileName: String, target: UIViewController, completionHandler: statusMessageHandler) {
        if googleDriveManager.isAuthorized() {
            googleDriveSaveData(fileName, completionHandler: completionHandler)
        } else {
            googleDriveManager.authorizeGoogleAccount(target, completionHandler: { [weak self] (authSuccess) in
                if let strongSelf = self where authSuccess {
                    strongSelf.googleDriveSaveData(fileName, completionHandler: completionHandler)
                } else {
                    completionHandler(success: false, errorMessage: "Authorize user failed")
                }
            })
        }
    }
    
    private func googleDriveSaveData(fileName: String, completionHandler: statusMessageHandler) {
        if identifier == .write {
            googleDriveManager.saveWriteAndValueData(fileName ?? "Default file", writeArray: writeValueArray, valueArray: valueArray, completionHandler: completionHandler)
        } else {
            googleDriveManager.saveValueData(fileName ?? "Default file", dataArray: valueArray, completionHandler: completionHandler)
        }
    }
    
}
