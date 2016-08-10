//
//  GoogleDriveManager.swift
//  CZBLEControl
//
//  Created by Steven Jia on 8/9/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
//

import UIKit
import GoogleAPIClient
import GTMOAuth2

class GoogleDriveManager: NSObject {
    
    let kKeyChainItemName = "CZBLEControl Google Drive"
    let kClientId = "628215016696-m3b5glkere874v5es45os8mfr23conhd.apps.googleusercontent.com"
    let scopes = "https://www.googleapis.com/auth/drive.file"
    
    func authorizeGoogleAccount() {
        let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName(kKeyChainItemName, clientID: kClientId, clientSecret: nil)
        if auth.canAuthorize {
            
        } else {
            let authVC = GTMOAuth2ViewControllerTouch(scope: scopes, clientID: kClientId, clientSecret: nil, keychainItemName: kKeyChainItemName, completionHandler: { (GTAuthVCTouch, GTAuthAuthorization, error) in
                <#code#>
            })
        }

    }

}
