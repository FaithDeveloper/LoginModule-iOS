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

class MainViewController: UIViewController {
    var user: UserInfo!
    
    @IBOutlet var txtUserID: UITextField!
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
        }
    }
    
    override
    func viewDidLoad() {
        super.viewDidLoad()
        
        guard user != nil else {
            print("user nil")
            return
        }
        
        txtUserID.text = user.email
        print("MainViewController:viewDidLoad user : \(String(describing: user?.email))")
    }
    
    func gotoLoginViewController(){
        let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginViewID" ) as! LoginViewController
        self.present(loginVC, animated: true, completion: nil)
    }
}
