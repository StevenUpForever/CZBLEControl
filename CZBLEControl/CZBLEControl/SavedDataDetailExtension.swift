//
//  SavedDataDetailExtension.swift
//  CZBLEControl
//
//  Created by Steven Jia on 9/8/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
//

import Foundation
import GoogleAPIClient
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
        
        if let googleFile = sourceObj as? GTLDriveFile {
            
            navigationItem.title = googleFile.name
            
            GoogleDriveManager.sharedManager.readFileContent(sourceObj as! GTLDriveFile, completionHandler: handleFileContentResponse)
        } else if let dropboxFile = sourceObj as? Files.Metadata {
            
            navigationItem.title = dropboxFile.name
            
            DropBoxManager.sharedManager.readFileContent(sourceObj as! Files.Metadata, completionHandler: handleFileContentResponse)
            
        }
        
    }
    
}
