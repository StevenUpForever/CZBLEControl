//
//  AccountManagerViewController.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 9/3/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
//

import UIKit
import SwiftyDropbox
import AppAuth
import GTMAppAuth
import GoogleAPIClientForREST

class AccountManagerViewController: UIViewController, dropboxDelegate {

    @IBOutlet weak var googleDriveLabel: UILabel!
    @IBOutlet weak var dropBoxLabel: UILabel!
    
    fileprivate let googleDriveManager = GoogleDriveManager.sharedManager
    fileprivate let dropBoxManager = DropBoxManager.sharedManager
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dropBoxManager.delegate = self
        changeLabelState(self.googleDriveLabel, success: googleDriveManager.isAuthorized)
        changeLabelState(self.dropBoxLabel, success: dropBoxManager.isAuthorized())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func googleDriveAction(_ sender: UITapGestureRecognizer) {
        if googleDriveManager.isAuthorized {
            CustomAlertController.showChooseAlertControllerWithBlock(NSLocalizedString("Are you sure to logoff Google account?", comment: ""), message: nil, target: self, actionHandler: { (action) in
                AuthManager.shared.deauthorizeGSuite()
                DispatchQueue.main.async(execute: {
                    self.changeLabelState(self.googleDriveLabel, success: false)
                })
            })
        } else {
            AuthManager.shared.authGSuite(self) { (authSuccess) in
                DispatchQueue.main.async(execute: { 
                    if authSuccess {
                        self.changeLabelState(self.googleDriveLabel, success: true)
                    } else {
                        self.changeLabelState(self.googleDriveLabel, success: false)
                        CustomAlertController.showCancelAlertController(NSLocalizedString("Failed authorize Google user", comment: ""), message: nil, target: self)
                    }
                })
            }
        }
    }
    
    @IBAction func dropBoxAction(_ sender: UITapGestureRecognizer) {
        if dropBoxManager.isAuthorized() {
            CustomAlertController.showChooseAlertControllerWithBlock(NSLocalizedString("Are you sure to logoff Dropbox account?", comment: ""), message: nil, target: self, actionHandler: { (action) in
                self.dropBoxManager.deauthorizeUser()
                DispatchQueue.main.async(execute: {
                    self.changeLabelState(self.dropBoxLabel, success: false)
                })
            })
        } else {
            dropBoxManager.authorizeUser(self)
        }
    }
    
    //MARK: delegate
    
    
    func didFinishAuthorizeUser(_ success: Bool, token: DropboxAccessToken?, error: OAuth2Error?, errorMessage: String?) {
        if success {
            changeLabelState(self.dropBoxLabel, success: true)
        } else {
            CustomAlertController.showCancelAlertController(errorMessage, message: nil, target: self)
        }
    }
    
    fileprivate func changeLabelState(_ sender: UILabel, success:Bool) {
        sender.text = success ? NSLocalizedString("Logged In", comment: "") : NSLocalizedString("Logged Off", comment: "")
        sender.textColor = success ? UIColor.black : UIColor.red
    }

}
