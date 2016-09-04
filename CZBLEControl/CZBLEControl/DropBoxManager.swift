//
//  DropBoxManager.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 9/3/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
//

import UIKit
import SwiftyDropbox

protocol dropboxDelegate: class {
    func didSuccessfullyAuthorizeUser(token: DropboxAccessToken)
}

class DropBoxManager: NSObject {
    
    weak var delegate: dropboxDelegate?
    
    static let sharedManager: DropBoxManager = {
        let manager = DropBoxManager()
        return manager
    }()
    
    func authorizeUser(viewControllerTarget: UIViewController) {
        Dropbox.authorizeFromController(viewControllerTarget)
        
    }
    
    func deauthorizeUser() {
        Dropbox.unlinkClient()
    }
    
    func isAuthorized() -> Bool {
        return Dropbox.authorizedClient != nil
    }

}
