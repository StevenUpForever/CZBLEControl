//
//  SavedDataVCExtension.swift
//  CZBLEControl
//
//  Created by Steven Jia on 9/8/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
//

import Foundation
import SwiftyDropbox

extension SavedDataTableViewController: dropboxDelegate {
    
    func loadProperDataSource(type: savedDataSource) {
        
        indicator.showAnimated(true)
        
        switch type {
        case .iCloudDrive:
            break
        case .GoogleDrive:
            navigationItem.title = "Google Drive"
            loadGoogleDriveFilesWithAuthorize()
        case .Dropbox:
            navigationItem.title = "Dropbox"
            loadDropboxFilesWithAuthorize()
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
                self.dataSourceArray = files!
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
    
    //MARK: Dropbox stack
    
    func loadDropboxFilesWithAuthorize() {
        let dropboxManager = DropBoxManager.sharedManager
        dropboxManager.delegate = self
        if dropboxManager.isAuthorized() {
            dropboxManager.loadFileList { (success, dataArray, errorMessage) in
                if success && dataArray != nil {
                    self.dataSourceArray = dataArray!
                    dispatch_async(dispatch_get_main_queue(), {
                        self.indicator.hideAnimated(true)
                        self.tableView.reloadData()
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.indicator.hideAnimated(true)
                        CustomAlertController.showCancelAlertController("Failed to get file list", message: nil, target: self)
                    })
                }
            }
        } else {
            dropboxManager.authorizeUser(self)
        }
    }
    
    func didFinishAuthorizeUser(success: Bool, token: DropboxAccessToken?, error: OAuth2Error?, errorMessage: String?) {
        if success {
            loadDropboxFilesWithAuthorize()
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                self.indicator.hideAnimated(true)
                CustomAlertController.showCancelAlertController("Authorize Dropbox user failed", message: nil, target: self)
            })
        }
    }
    
}
