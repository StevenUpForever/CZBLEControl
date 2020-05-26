//
//  AppDelegate.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 16/4/3.
//  Copyright © 2016年 ChengzhiJia. All rights reserved.
//

import UIKit
import AppAuth
import GTMAppAuth
import SwiftyDropbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//        UIApplication.shared.statusBarStyle = .lightContent
        
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
        
        DropboxClientsManager.setupWithAppKey("9cc6hhoqm5u7ipn")
        
        //Thread wait for 1 second for Lauching screen
        
        Thread.sleep(forTimeInterval: 1.0)
        
        //Change navigation title Color and hide back button title
        
        UINavigationBar.appearance().tintColor = UIColor.white
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(
            UIOffset(
                horizontal: 0.0,
                vertical: -80.0),
            for: .default)
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        
        if let authResult = DropboxClientsManager.handleRedirectURL(url) {
            switch authResult {
            case .success(let token):
                DropBoxManager.sharedManager.delegate?.didFinishAuthorizeUser(true, token: token, error: nil, errorMessage: nil)
//                print("Success! User is logged into Dropbox with token: \(token)")
            case .cancel:
                DropBoxManager.sharedManager.delegate?.didFinishAuthorizeUser(false, token: nil, error: nil, errorMessage: NSLocalizedString("Login Cancelled", comment: ""))
//                print("Authorization flow was manually canceled by user.")
            case .error(let error, let description):
                DropBoxManager.sharedManager.delegate?.didFinishAuthorizeUser(false, token: nil, error: error, errorMessage: description)
                print("Error \(error): \(description)")
            }
        } else if AuthManager.shared.currentAuthorizationFlow?.resumeExternalUserAgentFlow(with: url) == true {
            AuthManager.shared.currentAuthorizationFlow = nil
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataManager.sharedInstance.saveContext()
    }

}

