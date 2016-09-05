//
//  RWNCExtension.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 9/4/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
//

import UIKit

extension RWNCTableViewController: UITextFieldDelegate {
    
    func showFileNameAlertController() {
        let alertController = UIAlertController(title: "Please enter your file name", message: nil, preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Enter file name here"
            self.fileNameTextField = textField
            self.fileNameTextField!.addTarget(self, action: #selector(self.textFieldValueChanged), forControlEvents: .EditingChanged)
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        submitAction = UIAlertAction(title: "OK", style: .Default, handler: { (action) in
            dispatch_async(dispatch_get_main_queue(), {
                self.showDriveActionSheet()
            })
        })
        submitAction!.enabled = false
        alertController.addAction(submitAction!)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showDriveActionSheet() {
        let alertController = UIAlertController(title: "Where would you like to save?", message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: "iCloud Drive", style: .Default, handler: { (action) in
            
        }))
        alertController.addAction(UIAlertAction(title: "Google Drive", style: .Default, handler: { (action) in
            
        }))
        alertController.addAction(UIAlertAction(title: "Dropbox", style: .Default, handler: { (action) in
            
        }))
        alertController.addAction(UIAlertAction(title: "Local Disk", style: .Default, handler: { (action) in
            
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
            
        }))
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    //MARK: Custom Selectors
    
    func textFieldValueChanged() {
        if fileNameTextField != nil {
            fileName = self.fileNameTextField?.text
            if fileNameTextField!.text != nil && fileNameTextField!.text?.characters.count > 0 {
                if submitAction != nil {
                    submitAction!.enabled = true
                }
            } else {
                if submitAction != nil {
                    submitAction!.enabled = false
                }
            }
        }
    }
    
}
