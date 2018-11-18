//
//  LHKakaoLoginButton.swift
//  LoginHelper-iOS
//
//  Created by kchshin on 2018. 10. 24..
//  Copyright © 2018년 kcs. All rights reserved.
//

import UIKit

class KKakaoLoginButton : KOLoginButton{
    
    /// 카카오 로그인 버튼 클릭 이벤트 처리
    /// - Detail : 카카오 로그인 버튼 클릭 시 profile 정보를 넘겨줍니다.
    /// - Parameters:
    ///   - view: 카카오 로그인 화면이 추가될 rootView
    ///   - handler: 카카오 로그인 후 넘어오는 정보
//    func actionSigninButton(view: UIViewController, completion handler: @escaping KOSessionTaskUserMeCompletionHandler){
//        let session : KOSession = KOSession.shared()
//
//        if session.isOpen(){
//            session.close()
//        }
//
//        session.presentingViewController = view
//        session.open(completionHandler: { (error) in
//            session.presentingViewController = nil;
//            //, authType: KOAuthType.talk, nil
//            // 카카오 로그인 화면에서 벋어날 시 호출.
//            if error != nil {
//                print("Kakao login Error Massage : \(error?.localizedDescription ?? "")")
//            }else if session.isOpen(){
//                KOSessionTask.userMeTask(completion: handler)
//            }else{
//                print("Kakao login Error Massage : isn't open")
//            }
//        })
//    }
    
    func checkRequestKakao() -> Bool{
        let session : KOSession = KOSession.shared()
        
        return session.isOpen()
    }
    
    
    /// 카카오 로그인 버튼 클릭 시 사용자 정보 호출
    ///
    /// - Parameters:
    ///   - view: 카카오 버튼 표시할 View
    ///   - handler: 카카오 정보 가져왔을 시 이벤트 핸들러
    func actionSigninButton(view: UIViewController, completion handler: @escaping (_ result: KOUser?, _ error: Error?)->()){
        let session : KOSession = KOSession.shared()
        
        if session.isOpen(){
            session.close()
        }
        
        session.presentingViewController = view
        session.open(completionHandler: { (error) in
            session.presentingViewController = nil;
            
            // 카카오 로그인 화면에서 벋어날 시 호출.
            if error != nil {
                print("Kakao login Error Massage : \(error?.localizedDescription ?? "")")
            }else if session.isOpen(){
                
                KOSessionTask.meTask(completionHandler: { (profile, error_task) in
                    let info: KOUser? = profile as? KOUser
                    
                    if  info == nil {
                        handler(nil, error_task)
                        return
                    }
                    
                    DispatchQueue.main.async(execute: { () -> Void in
                        handler(info, nil)
                    })
                })
            }else{
                print("Kakao login Error Massage : isn't open")
            }
        })
    }
}
