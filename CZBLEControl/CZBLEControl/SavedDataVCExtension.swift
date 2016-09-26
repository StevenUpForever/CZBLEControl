//
//  SavedDataVCExtension.swift
//  CZBLEControl
//
//  Created by Steven Jia on 9/8/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
//

import Foundation
import GoogleAPIClient
import SwiftyDropbox

extension SavedDataTableViewController: dropboxDelegate {
    
    func loadProperDataSource(_ type: savedDataSource) {
        
        indicator.label.text = "Loading files..."
        indicator.show(animated: true)
        
        switch type {
        case .iCloudDrive:
            break
        case .googleDrive:
            navigationItem.title = "Google Drive"
            loadGoogleDriveFilesWithAuthorize()
        case .dropbox:
            navigationItem.title = "Dropbox"
            loadDropboxFilesWithAuthorize()
        case .localDrive: 
            break
        }
    }
    
    func deleteData(_ indexPath: IndexPath) {
        
        indicator.label.text = "Deleting files..."
        indicator.show(animated: true)
        
        let handleDeleteResponse = { (success: Bool, errorMessage: String?) in
            if success {
                self.dataSourceArray.remove(at: (indexPath as NSIndexPath).row)
                DispatchQueue.main.async(execute: {
                    self.indicator.hide(animated: true)
                    self.tableView.deleteRows(at: [indexPath], with: .right)
                })
            } else {
                DispatchQueue.main.async(execute: {
                    self.indicator.hide(animated: true)
                    CustomAlertController.showCancelAlertController(errorMessage, message: nil, target: self)
                })
            }
        }
        
        if let googleFile = dataSourceArray[(indexPath as NSIndexPath).row] as? GTLDriveFile {
            GoogleDriveManager.sharedManager.deleteFile(googleFile, completionHandler: handleDeleteResponse)
        } else if let dropboxFile = dataSourceArray[indexPath.row] as? Files.Metadata {
            DropBoxManager.sharedManager.deleteFile(dropboxFile, completionHandler: handleDeleteResponse)
        }
        
    }
    
    //MARK: Google Drive Stack
    
    fileprivate func loadGoogleDriveFilesWithAuthorize() {
        let googleDriveManager = GoogleDriveManager.sharedManager
        if googleDriveManager.isAuthorized() {
            loadGoogleDriveFiles(googleDriveManager)
        } else {
            googleDriveManager.authorizeGoogleAccount(self, completionHandler: { (authSuccess) in
                if authSuccess {
                    self.loadGoogleDriveFiles(googleDriveManager)
                } else {
                    DispatchQueue.main.async(execute: {
                        self.indicator.hide(animated: true)
                        CustomAlertController.showCancelAlertController("Authorize google user failed", message: nil, target: self)
                    })
                }
            })
        }
    }
    
    fileprivate func loadGoogleDriveFiles(_ googleDriveManager: GoogleDriveManager) {
        googleDriveManager.loadFiles { (success, errorMessage, files) in
            if success {
                self.dataSourceArray = files!
                DispatchQueue.main.async(execute: {
                    self.indicator.hide(animated: true)
                    self.tableView.reloadData()
                })
            } else {
                DispatchQueue.main.async(execute: {
                    self.indicator.hide(animated: true)
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
                    DispatchQueue.main.async(execute: {
                        self.indicator.hide(animated: true)
                        self.tableView.reloadData()
                    })
                } else {
                    DispatchQueue.main.async(execute: {
                        self.indicator.hide(animated: true)
                        CustomAlertController.showCancelAlertController("Failed to get file list", message: nil, target: self)
                    })
                }
            }
        } else {
            dropboxManager.authorizeUser(self)
        }
    }
    
    func didFinishAuthorizeUser(_ success: Bool, token: DropboxAccessToken?, error: OAuth2Error?, errorMessage: String?) {
        if success {
            loadDropboxFilesWithAuthorize()
        } else {
            DispatchQueue.main.async(execute: {
                self.indicator.hide(animated: true)
                CustomAlertController.showCancelAlertController("Authorize Dropbox user failed", message: nil, target: self)
            })
        }
    }
    
}
