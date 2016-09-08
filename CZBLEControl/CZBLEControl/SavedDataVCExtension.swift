//
//  SavedDataVCExtension.swift
//  CZBLEControl
//
//  Created by Steven Jia on 9/8/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
//

import Foundation

extension SavedDataTableViewController {
    
    func loadProperDataSource(type: savedDataSource) {
        
        indicator.showAnimated(true)
        
        switch type {
        case .iCloudDrive:
            break
        case .GoogleDrive:
            loadGoogleDriveFilesWithAuthorize()
        case .Dropbox:
            break
        case .localDrive: 
            break
        }
    }
    
    //MARK: Google Drive Stack
    
    private func loadGoogleDriveFilesWithAuthorize() {
        let googleDriveManager = GoogleDriveManager.sharedManager
        if googleDriveManager.isAuthorized() {
            loadGoogleDriveFiles(googleDriveManager)
        } else {
            googleDriveManager.authorizeGoogleAccount(self, completionHandler: { (authSuccess) in
                if authSuccess {
                    self.loadGoogleDriveFiles(googleDriveManager)
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.indicator.hideAnimated(true)
                        CustomAlertController.showCancelAlertController("Authorize google user failed", message: nil, target: self)
                    })
                }
            })
        }
    }
    
    private func loadGoogleDriveFiles(googleDriveManager: GoogleDriveManager) {
        googleDriveManager.loadFiles { (success, errorMessage, files) in
            if success {
                self.googleDriveArray = files!
                dispatch_async(dispatch_get_main_queue(), {
                    self.indicator.hideAnimated(true)
                    self.tableView.reloadData()
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.indicator.hideAnimated(true)
                    CustomAlertController.showCancelAlertController(errorMessage, message: nil, target: self)
                })
            }
        }
    }
    
}
