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
        
        indicator.showAnimated(true)
        
        if sourceObj is GTLDriveFile {
            
            navigationItem.title = sourceObj.name
            
            GoogleDriveManager.sharedManager.readFileContent(sourceObj as! GTLDriveFile, completionHandler: { (success, dataArray, errorMessage) in
                self.parseResponse(success, dataArray: dataArray, errorMessage: errorMessage)
            })
        } else if sourceObj is Files.Metadata {
            
            navigationItem.title = sourceObj.name
            
            DropBoxManager.sharedManager.readFileContent(sourceObj as! Files.Metadata, completionHandler: { (success, dataArray, errorMessage) in
                self.parseResponse(success, dataArray: dataArray, errorMessage: errorMessage)
            })
            
        }
        
    }
    
    private func parseResponse(success: Bool, dataArray: [[NSString]]?, errorMessage: String?) {
        if success && dataArray != nil {
            self.dataSourceArray = dataArray!
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
