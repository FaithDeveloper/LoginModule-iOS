//
//  KFBLoginButton.swift
//  LoginModule
//
//  Created by kchshin on 2018. 11. 15..
//  Copyright © 2018년 kcs. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

protocol KFBInfoDelegate {
    func kFBInfoCompletionHandler(_ connection: FBSDKGraphRequestConnection?, _ result: Any, _ error: Error?)
    func kFBSDKAccessTokenCurrent(result: Bool)
}
class KFBLoginButton: FBSDKLoginButton, FBSDKLoginButtonDelegate{
    
    var info: KFBInfoDelegate?
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        print("[LoginModule] Login Button")
        self.initRequest()
    }
    
    func initRequest(){
        if((FBSDKAccessToken.current()) != nil){
//           FB Button Hidden
            getFBUserData()
        } else {
            getFBUserData()
        }
    }
    
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                self.info?.kFBInfoCompletionHandler(connection, result, error)
            })
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Logout Button")
        //todo..
    }
    
    func actionSigninButton(fbInfo: KFBInfoDelegate){
        // Firebase
        loginBehavior = .web
        readPermissions = ["public_profile", "email"]
        delegate = self
        self.info = fbInfo
    }
}
