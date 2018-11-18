//
//  AppDelegate.swift
//  LoginModule
//
//  Created by sigong_shin on 2017. 6. 30..
//  Copyright © 2017년 kcs. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import GoogleSignIn
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, GIDSignInUIDelegate  {

    var window: UIWindow?
    public var loginViewController: LoginViewController!
    var databaseRef: DatabaseReference!


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        // 로그인 대리자 설정
        GIDSignIn.sharedInstance().clientID = "971652406403-3ic2cqgk62rjmg6a765cro3eiqvhhg38.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        
        // 데이터베이스 정보가져오기
        self.databaseRef = Database.database().reference()
        
        loginViewController = window!.rootViewController as! LoginViewController
        
        //Firebase 세팅
        if let sharedInstance = FBSDKApplicationDelegate.sharedInstance(){
            return sharedInstance.application(application, didFinishLaunchingWithOptions: launchOptions)
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        KOSession.handleDidEnterBackground()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        KOSession.handleDidBecomeActive()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: Google Login, Kakao Login
    // GIDSignIn 인스턴스의 handleURL 메소드를 호출하며 이 메소드는 애플리케이션이 인증 절차가 끝나고 받는 URL를 적절히 처리합니다.
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            if KOSession.isKakaoAccountLoginCallback(url) {
                return KOSession.handleOpen(url)
            }
            
            let googleSession = GIDSignIn.sharedInstance().handle(url,sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
            
            let facebookSession = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
            
            return googleSession || facebookSession
    }
    
    
    // ios 이상에서 앱 실행 시 해당 메소드를 구현해야 합니다.
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if KOSession.isKakaoAccountLoginCallback(url) {
            return KOSession.handleOpen(url)
        }
        
        let googleSession = GIDSignIn.sharedInstance().handle(url,
                                                              sourceApplication: sourceApplication,
                                                              annotation: annotation)
        let facebookSession = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        
        return googleSession || facebookSession
    }
        
    // 구글 로그인 프로세스를 처리합니다.
    // 여기서는 로그인 시도 시 구현된 ViewController에서 실행하도록 하였습니다.
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        
        loginViewController.sign(signIn!, didSignInFor: user, withError: error)
    }
    
    @nonobjc func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
                         withError error: NSError!) {
        // Perform any operations when the user disconnects from app here.
        // ...
        
        if let clintID = signIn.clientID {
            print("AppDelegate:signIn:clintID : \(clintID)")
        }
    }
    
    // 데이터베이스 참조 가져오기
    func getDatabaseRef() -> DatabaseReference! {
        guard databaseRef != nil else {
            return nil
        }
        
        return databaseRef
    }
    
    // 유저 등록
    func updateGoogleDB(uid: String?, userInfo: UserInfo){
        if let databaseRef =  getDatabaseRef() {
            let databaseRootChild = databaseRef.child("user_profiles").child(uid!)
            databaseRootChild.observeSingleEvent(of: .value, with: { (snapshot) in
                
                let snapshot = snapshot.value as? NSDictionary
                
                if(snapshot == nil){
                    
                    let id = userInfo.id.components(separatedBy: "@")
                    let addTargetId = Utils.changeStringToDoNotUseCharactorFormFireBase(targetString: id[0])
                    
                    databaseRootChild.child("name").setValue(userInfo.name)
                    databaseRootChild.child("email").setValue(userInfo.email)
                    databaseRootChild.child("id").setValue(addTargetId)
                    databaseRootChild.child("join_address").setValue(userInfo.joinAddress)
                    databaseRootChild.child("password").setValue(userInfo.password.base64Encoded())
                }
            })
        }
    }
    
    func addUserProfile(uid: String?, userInfo: UserInfo){
        //ID 존재여부 체크
        if let databaseRef =  getDatabaseRef() {
            
            //@ 앞에 id 부분만 선택. 특수 문자'.'을 '_'로 변경
            let idData = userInfo.id.components(separatedBy: "@")
            let targetId = Utils.changeStringToDoNotUseCharactorFormFireBase(targetString: idData[0])
            let loginAddress = userInfo.joinAddress
            
            let databaseRootChild = databaseRef.child("user_profiles")
            databaseRootChild.observeSingleEvent(of: .value, with: { (snapshot) in
                
                let snapshot = snapshot.value as? NSDictionary
                
                if(snapshot != nil){
                    
                    let existIds = snapshot?.allValues as! [NSDictionary]
                    for info in existIds{
                        if let joinAddress = info.value(forKey: "join_address") as? String{
                            if let id = info.value(forKey: "id") as? String{
                                if id == targetId && loginAddress == joinAddress{
                                    return
                                }
                            }
                        }
                    }
                }
                self.updateGoogleDB(uid: uid, userInfo: userInfo)
            })
        }
    }


}

