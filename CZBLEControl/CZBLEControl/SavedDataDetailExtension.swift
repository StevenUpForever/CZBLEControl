//
//  SavedDataDetailExtension.swift
//  CZBLEControl
//
//  Created by Steven Jia on 9/8/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
//

import Foundation
import GoogleAPIClientForREST
import SwiftyDropbox

extension SavedDataDetailTableViewController {
    
    func loadProperFileContent() {
        
        indicator.show(animated: true)
        
        let handleFileContentResponse = { (success: Bool, dataArray: [[NSString]]?, errorMessage: String?) in
            if success && dataArray != nil {
                self.dataSourceArray = dataArray!
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
        
        if let googleFile = sourceObj as? GTLRDrive_File {
            navigationItem.title = googleFile.name
            GoogleDriveManager.sharedManager.readFileContent(googleFile, completionHandler: handleFileContentResponse)
        } else if let dropboxFile = sourceObj as? Files.Metadata {
            navigationItem.title = dropboxFile.name
            DropBoxManager.sharedManager.readFileContent(dropboxFile, completionHandler: handleFileContentResponse)
        } else if let localFile = sourceObj as? DataList {
            navigationItem.title = localFile.name
            if let localDatas = localFile.listToData {
                for data in localDatas {
                    if let ble = data as? BLEData {
                        if ble.section == 0 {
                            coreDataWriteValues.append(ble)
                        } else {
                            coreDataReadvalues.append(ble)
                        }
                    }
                }
            }
            DispatchQueue.main.async(execute: {
                self.indicator.hide(animated: true)
                self.tableView.reloadData()
            })
        }
    }
    
}
