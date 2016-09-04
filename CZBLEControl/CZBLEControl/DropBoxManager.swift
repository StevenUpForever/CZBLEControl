//
//  DropBoxManager.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 9/3/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
//

import UIKit
import SwiftyDropbox

class DropBoxManager: NSObject {
//    
//    func authorizeUser(viewControllerTarget: UIViewController, completionHandler: (authorizeSuccess: Bool) -> Void) {
//        if Dropbox.authorizedClient != nil {
//            completionHandler(authorizeSuccess: true)
//        } else {
//            Dropbox.authorizeFromController(viewControllerTarget)
//        }
//    }
    
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
