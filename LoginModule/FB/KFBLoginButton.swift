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
}
class KFBLoginButton: FBSDKLoginButton, FBSDKLoginButtonDelegate{
    //-------------------------------------------------------------------------------------------
    // MARK: - local variable
    //-------------------------------------------------------------------------------------------
    var info: KFBInfoDelegate?
    
    //-------------------------------------------------------------------------------------------
    // MARK: - local method
    //-------------------------------------------------------------------------------------------
    /// FB Login Button 초기화 합니다.
    ///
    /// - Parameters:
    ///   - loginButton: 로그인 버튼
    ///   - result: 로그인 정보
    ///   - error: 에러메시지
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        print("[LoginModule] Login Button")
        self.getFBUserData()
    }
    
    /// 현재 로그인 중인지 체크합니다.
    ///
    /// - return: 토큰 보유 유무
    func checkRequestFB()-> Bool{
        return (FBSDKAccessToken.current()) != nil
    }
    
    
    /// 로그인 정보를 가져옵니다.
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
    
    /// 로그인 버튼 초기화 및 Delegate 등록
    ///
    /// - Parameter fbInfo: Delegate 정보
    func actionSigninButton(fbInfo: KFBInfoDelegate){
        // Firebase
        loginBehavior = .web
        readPermissions = ["public_profile", "email"]
        delegate = self
        self.info = fbInfo
    }
}
