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

class LoginViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate{

    @IBOutlet weak var signInButton: GIDSignInButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
//        GIDSignIn.sharedInstance().signIn()
//        if GIDSignIn.sharedInstance().currentUser != nil {
//            GIDSignIn.sharedInstance().signIn()
//        }
       
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.loginViewController = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        
        
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
                return
            }

            self.gotoMainViewController(user: user)
        }
    }
    
    func gotoMainViewController(user: User!){
        let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainViewID" ) as! MainViewController
        mainVC.user = user
        self.present(mainVC, animated: true, completion: nil)
    }
}

