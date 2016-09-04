//
//  AccountManagerViewController.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 9/3/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
//

import UIKit
import SwiftyDropbox

class AccountManagerViewController: UIViewController, dropboxDelegate {

    @IBOutlet weak var googleDriveLabel: UILabel!
    @IBOutlet weak var dropBoxLabel: UILabel!
    
    private let googleDriveManager = GoogleDriveManager.sharedManager
    private let dropBoxManager = DropBoxManager.sharedManager
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dropBoxManager.delegate = self
        changeLabelState(self.googleDriveLabel, success: googleDriveManager.isAuthorized())
        changeLabelState(self.dropBoxLabel, success: dropBoxManager.isAuthorized())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func googleDriveAction(sender: UITapGestureRecognizer) {
        if googleDriveManager.isAuthorized() {
            CustomAlertController.showChooseAlertControllerWithBlock("Are you sure to logoff Google account?", message: nil, target: self, actionHandler: { (action) in
                self.googleDriveManager.deAuthorizeUser()
                dispatch_async(dispatch_get_main_queue(), {
                    self.changeLabelState(self.googleDriveLabel, success: false)
                })
            })
        } else {
            googleDriveManager.authorizeGoogleAccount(self) { (authSuccess) in
                dispatch_async(dispatch_get_main_queue(), { 
                    if authSuccess {
                        self.changeLabelState(self.googleDriveLabel, success: true)
                    } else {
                        self.changeLabelState(self.googleDriveLabel, success: false)
                        CustomAlertController.showCancelAlertController("Failed authorize Google user", message: nil, target: self)
                    }
                })
            }
        }
    }
    
    @IBAction func dropBoxAction(sender: UITapGestureRecognizer) {
        if dropBoxManager.isAuthorized() {
            CustomAlertController.showChooseAlertControllerWithBlock("Are you sure to logoff Dropbox account?", message: nil, target: self, actionHandler: { (action) in
                self.dropBoxManager.deauthorizeUser()
                dispatch_async(dispatch_get_main_queue(), {
                    self.changeLabelState(self.dropBoxLabel, success: false)
                })
            })
        } else {
            dropBoxManager.authorizeUser(self)
        }
    }
    
    //MARK: delegate
    
    func didSuccessfullyAuthorizeUser(token: DropboxAccessToken) {
        changeLabelState(self.dropBoxLabel, success: true)
    }
    
    private func changeLabelState(sender: UILabel, success:Bool) {
        sender.text = success ? "Logged In" : "Logged Off"
        sender.textColor = success ? UIColor.blackColor() : UIColor.redColor()
    }

}
