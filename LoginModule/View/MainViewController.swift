//
//  MainViewController.swift
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

class MainViewController: UIViewController {
    var user: UserInfo!
    
    //-------------------------------------------------------------------------------------------
    // MARK: - IBOutlets
    //-------------------------------------------------------------------------------------------
    @IBOutlet var txtUserID: UITextField!
    
    //-------------------------------------------------------------------------------------------
    // MARK: - IBAction
    //-------------------------------------------------------------------------------------------
    @IBAction func btnLogout(_ sender: Any) {
        
        if user.joinAddress == "google" {
            let firebaseAuth = Auth.auth()
            do {
                try
                    firebaseAuth.signOut()
                    GIDSignIn.sharedInstance().signOut()
                    gotoLoginViewController()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
        }else if user.joinAddress == "facebook"{
            FBSDKAccessToken.setCurrent(nil)
                              gotoLoginViewController()
        }else if user.joinAddress == "kakao" {
            
        }
    }
    
    //-------------------------------------------------------------------------------------------
    // MARK: - override method
    //-------------------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard user != nil else {
            print("user nil")
            return
        }
        
        if user.email.isEmpty{
            txtUserID.text = user.email
        }else{
            txtUserID.text = user.id
        }
        txtUserID.text = user.email
        print("MainViewController:viewDidLoad user : \(String(describing: txtUserID.text))")
    }
    
    //-------------------------------------------------------------------------------------------
    // MARK: - local method
    //-------------------------------------------------------------------------------------------
    func gotoLoginViewController(){
        let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginViewID" ) as! LoginViewController
        self.present(loginVC, animated: true, completion: nil)
    }
}
