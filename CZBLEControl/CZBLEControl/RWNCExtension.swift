//
//  RWNCExtension.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 9/4/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


extension RWNCTableViewController: UITextFieldDelegate {
    
    func showFileNameAlertController() {
        let alertController = UIAlertController(title: "Please enter your file name", message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter file name here"
            self.fileNameTextField = textField
            self.fileNameTextField!.addTarget(self, action: #selector(self.textFieldValueChanged), for: .editingChanged)
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        submitAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            DispatchQueue.main.async(execute: {
                self.showDriveActionSheet()
            })
        })
        submitAction!.isEnabled = false
        alertController.addAction(submitAction!)
        present(alertController, animated: true, completion: nil)
    }
    
    func showDriveActionSheet() {
        let alertController = UIAlertController(title: "Where would you like to save?", message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Google Drive", style: .default, handler: { (action) in
            DispatchQueue.main.async(execute: {
                self.indicator!.show(animated: true)
            })
            self.viewModel.uploadToGoogleDrive(self.fileName ?? "Default file", target: self, completionHandler: { (success, errorMessage) in
                DispatchQueue.main.async(execute: {
                    self.indicator!.hide(animated: true)
                    CustomAlertController.showCancelAlertController(errorMessage, message: nil, target: self)
                })
            })
        }))
        alertController.addAction(UIAlertAction(title: "Dropbox", style: .default, handler: { (action) in
            DispatchQueue.main.async(execute: {
                self.indicator!.show(animated: true)
            })
            self.viewModel.uploadToDropbox(self.fileName ?? "Default file", target: self, completionHandler: { (success, errorMessage) in
                DispatchQueue.main.async(execute: {
                    self.indicator!.hide(animated: true)
                    CustomAlertController.showCancelAlertController(errorMessage, message: nil, target: self)
                })
            })
        }))
        alertController.addAction(UIAlertAction(title: "Local Drive", style: .default, handler: { (action) in
            DispatchQueue.main.async(execute: {
                self.indicator!.show(animated: true)
            })
            self.viewModel.saveDataToCoreData(self.fileName ?? "Default file", completionHandler: { (success, errorMessage) in
                DispatchQueue.main.async(execute: {
                    self.indicator!.hide(animated: true)
                    CustomAlertController.showCancelAlertController(errorMessage, message: nil, target: self)
                })
            })
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK: Custom Selectors
    
    func textFieldValueChanged() {
        if fileNameTextField != nil {
            fileName = self.fileNameTextField?.text
            if fileNameTextField!.text != nil && fileNameTextField!.text?.characters.count > 0 {
                if submitAction != nil {
                    submitAction!.isEnabled = true
                }
            } else {
                if submitAction != nil {
                    submitAction!.isEnabled = false
                }
            }
        }
    }
    
}
