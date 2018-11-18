//
//  ViewController.swift
//  LoginModel
//
//  Created by sigong_shin on 2017. 6. 9..
//  Copyright © 2017년 kcs. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate, KFBInfoDelegate{

    //-------------------------------------------------------------------------------------------
    // MARK: - IBOutlets
    //-------------------------------------------------------------------------------------------
    @IBOutlet var txtPwd: UITextField!
    @IBOutlet var txtID: UITextField!
    @IBOutlet var viewFaceBook: UIView!
   
    @IBOutlet weak var btnKakao: KKakaoLoginButton!
    @IBOutlet var bgContainerView: UIView!
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    @IBOutlet var loadingBar: UIActivityIndicatorView!
    
    //-------------------------------------------------------------------------------------------
    // MARK: - override
    //-------------------------------------------------------------------------------------------
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let appDelegate = getAppDelegate() {
            appDelegate.loginViewController = self
        }else{
            print("Appdelegate is nil")
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        bgContainerView.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UI 구분
        self.hideKeyboardWhenTappedAround()
        
        // Google Signin
        GIDSignIn.sharedInstance().uiDelegate = self
        
        // FaceBook
        initFB()
        
        // Firebase
//        GIDSignIn.sharedInstance().signIn()
//        if GIDSignIn.sharedInstance().currentUser != nil {
//            GIDSignIn.sharedInstance().signIn()
//        }
    }

    //-------------------------------------------------------------------------------------------
    // MARK: - local method
    //-------------------------------------------------------------------------------------------
    /// Facebook 로그인 설정
    func initFB(){
        let btnFaceBook = KFBLoginButton(frame: CGRect(x: 0, y: 0, width: viewFaceBook.frame.width, height: viewFaceBook.frame.height))
        btnFaceBook.actionSigninButton(fbInfo: self)
        if btnFaceBook.checkRequestFB(){
             print("[LoginModule] Login")
             btnFaceBook.getFBUserData()
        }else{
            print("[LoginModule] Log Out")
        }
        viewFaceBook.addSubview(btnFaceBook)
    }
    
    /// 페이스북 로그인 후 정보가 전달됩니다.
    ///
    /// - Parameters:
    ///   - connection: 연결 유무
    ///   - result: 고객 정보 리턴
    ///   - error: 에러 메시지
    func kFBInfoCompletionHandler(_ connection: FBSDKGraphRequestConnection?, _ result: Any, _ error: Error?) {
        if (error == nil){
            let dict = result as! [String : AnyObject]
            //print(result!)
            print(dict)
            var info = UserInfo()
            
            let facebookEmail = dict["email"] as! String
            info.email = facebookEmail
            print("[LoginModule] email = \(facebookEmail)")
            
            let facebookId = dict["id"] as! String
            info.id = facebookId
            print("[LoginModule] id = \(facebookId)")
            
            let facebookName = dict["name"] as! String
            info.name = facebookName
            print("[LoginModule] name = \(facebookName)")
            
            info.joinAddress = "facebook"
            info.password = ""
            
            let appDelegate = self.getAppDelegate()
            appDelegate?.addUserProfile(uid: appDelegate?.getDatabaseRef().childByAutoId().key, userInfo: info)
            self.gotoMainViewController(user: info)
        }
    }
    
    /// AppDelegate 가져오기
    ///
    /// - Returns: AppDelegate
    func getAppDelegate() -> AppDelegate!{
        return UIApplication.shared.delegate as! AppDelegate
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        
        loadingBar.startAnimating()
        
        if let err = error {
            print("LoginViewController:error = \(err)")
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                          accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (user, error) in
            // ...
            if let err = error {
                print("LoginViewController:error = \(err)")
                self.loadingBar.stopAnimating()
                return
            }
            
            if let appDelegate = self.getAppDelegate(){            
                let info = UserInfo(name: user?.displayName, email: user?.email, id: user?.email, password: "", joinAddress: "google")
                appDelegate.addUserProfile(uid: (user?.uid)!, userInfo: info)
                self.gotoMainViewController(user: info)
            }
         }
    }
    
    func gotoMainViewController(user: UserInfo){
        let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainViewID" ) as! MainViewController
        mainVC.user = user
        self.present(mainVC, animated: true, completion: nil)
        loadingBar.stopAnimating()
    }
    
    // Custom 로그인 시도
    func loginUserProfile(id: String?, pwd: String?){
        if let databaseRef = self.getAppDelegate().getDatabaseRef() {
            let databaseRootChild = databaseRef.child("user_profiles")
            databaseRootChild.observeSingleEvent(of: .value, with: { (snapshot) in
                
                let snapshot = snapshot.value as? NSDictionary
                
                if(snapshot != nil){
                    let userInfo = snapshot?.allValues as! [NSDictionary]
                    var idExist = false
                    
                    for info in userInfo{
                        //id 존재 유무 확인
                       if info.value(forKey: "id") as? String == id{
                            //커스텀 로그인인지 체크
                            if info.value(forKey: "join_address") as? String != "custom" {
                                self.showAlert(title: "error", msg: "회원 가입한 유저가 아닙니다.\n 구글, 카카오, 페이스북 유저인 경우 해당 버튼을 클릭 해주세요.")
                                return
                            }
                            
                            idExist = true
                            var infoPwd = info.value(forKey: "password") as? String
                            infoPwd = infoPwd?.base64Decoded()
                            if(infoPwd == pwd?.base64Decoded()){
                                let userInfo = UserInfo(name: info.value(forKey: "name") as? String, email: info.value(forKey: "email") as? String, id: id, password: infoPwd?.base64Encoded(), joinAddress: "custom")
                                Utils.showAlert(viewController: self, title: "info", msg: "로그인 성공!", handler: {(action: UIAlertAction!) in self.gotoMainViewController(user: userInfo)})
                                return
                            }else{
                                self.showAlert(title: "error", msg: "비밀번호가 일치하지 않습니다.")
                                return
                            }
                        }
                    }
                    
                    if !idExist {
                        self.showAlert(title: "error", msg: "ID가 없습니다.")
                    }
                }
            })
        }
    }
    
    @IBAction func loginAction(_ sender: Any) {
        let id = txtID.text!.components(separatedBy: "@")
        let targetId = Utils.changeStringToDoNotUseCharactorFormFireBase(targetString: id[0])
        loginUserProfile(id: targetId, pwd: txtPwd.text?.base64Encoded())
    }
    
    @IBAction func kakaoAction(_ sender: Any) {
        
        btnKakao.actionSigninButton(view: self) { (profile, error) in
            
            
            guard profile != nil else{
                return
            }
            
            DispatchQueue.main.async(execute: { () -> Void in
                print("SUCCESS GET PROFILE!!\n")
                
                guard (self.getAppDelegate()) != nil else{
                    return
                }

                //Google DB Update
                var info = UserInfo()
                info.joinAddress = "kakao"

                if let nickName = profile!.property(forKey: KOUserNicknamePropertyKey) as? String{
                    info.name = "\(nickName)"
                }
                
                if let value = profile!.email{
                    print("kakao email : \(value)\r\n")
                    info.email =  "\(value)"
                }
                
                if let value = profile!.id{
                    print("kakao email : \(value)\r\n")
                    info.id =  "\(value)"
                }
                
                print("READY FOR KAKAO PROFILE!!\n")

                let appDelegate = self.getAppDelegate()
                appDelegate?.addUserProfile(uid: appDelegate?.getDatabaseRef().childByAutoId().key, userInfo: info)
                self.gotoMainViewController(user: info)
                
                print("SAVE FOR KAKAO PROFILE!!\n")
            })
        }
    }
    
    func showAlert(title: String, msg: String){
         Utils.showAlert(viewController: self, title: title, msg: msg, handler: nil)
    }
}
