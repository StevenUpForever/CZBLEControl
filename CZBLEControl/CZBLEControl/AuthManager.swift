//
//  AuthManager.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 5/25/20.
//  Copyright © 2020 ChengzhiJia. All rights reserved.
//

import Foundation
import GoogleAPIClientForREST
import AppAuth
import GTMAppAuth


/// The centralized auth manager that manage authorizations for all 3rd platforms
///
/// - the auth may use not only in the G-suite/dropbox viewController but also over the applicantion
class AuthManager {
    
    static let shared = AuthManager()
    
    // G-Suite auth
    var currentAuthorizationFlow: OIDExternalUserAgentSession?
    var authorization: GTMAppAuthFetcherAuthorization?

    private let kKeyChainItemName: String
    private let kClientId: String
    private let kRedirectURI: String
    
    init() {
        kKeyChainItemName = "CZBLEControl Google Drive"
        kClientId = "628215016696-ifrnd8sbuhria5ses99avkddu5ps0jdo.apps.googleusercontent.com"
        kRedirectURI = "com.googleusercontent.apps.628215016696-ifrnd8sbuhria5ses99avkddu5ps0jdo:/oauthredirect"
    }
    
    func saveAuthGSuite(_ auth: GTMAppAuthFetcherAuthorization) {
        authorization = auth
        GTMAppAuthFetcherAuthorization.save(auth, toKeychainForName: kKeyChainItemName)
        GoogleDriveManager.sharedManager.driveService.authorizer = auth
    }
    
    func deauthorizeGSuite() {
        authorization = nil
        GTMAppAuthFetcherAuthorization.removeFromKeychain(forName: kKeyChainItemName)
    }
    
    @discardableResult func authGSuiteFromKeyChain() -> Bool {
        if let auth = GTMAppAuthFetcherAuthorization(fromKeychainForName: kKeyChainItemName) {
            authorization = auth
            
            return true
        }
        return false
    }
    
    func authGSuite(_ targetViewController: UIViewController,
                    completionHandler: @escaping (Bool) -> Void) {
        guard !authGSuiteFromKeyChain() else {
            return
        }
        let configuration = GTMAppAuthFetcherAuthorization.configurationForGoogle()
        if let url = URL(string: kRedirectURI) {
            let request = OIDAuthorizationRequest(
                configuration: configuration,
                clientId: kClientId,
                scopes: [
                    kGTLRAuthScopeDriveMetadata,
                    kGTLRAuthScopeDriveFile,
                    kGTLRAuthScopeDrive,
                    OIDScopeOpenID,
                    OIDScopeProfile
                ],
                redirectURL: url,
                responseType: OIDResponseTypeCode,
                additionalParameters: nil)

            currentAuthorizationFlow = OIDAuthState.authState(
                byPresenting: request,
                presenting: targetViewController.parent ?? targetViewController,
                callback: { (authState, error) in
                    if let authState = authState {
                        self.saveAuthGSuite(GTMAppAuthFetcherAuthorization(authState: authState))
                        print("Got GTM authorization tokens. Access token: \(authState.lastTokenResponse?.accessToken ?? "No lastTokenResponse")")

                        completionHandler(true)
                    } else if let error = error {
                        self.deauthorizeGSuite()
                        print("GTM auth error: \(error.localizedDescription)")
                        completionHandler(false)
                    }
            })
        }
    }
    
}
