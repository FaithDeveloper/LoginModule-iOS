//
//  File.swift
//  LoginModel
//
//  Created by MAC on 2017. 6. 23..
//  Copyright © 2017년 kcs. All rights reserved.
//

import Foundation
import Firebase
import GoogleSignIn

struct UserInfo {
    var name: String
    var email: String
    var id: String
    var password: String
    var joinAddress: String
    
    init(name: String?, email: String?, id: String?, password: String?, joinAddress: String?){
        self.name = name!
        self.email = email!
        self.id = id!
        self.password = password!
        self.joinAddress = joinAddress!
        
    }
    
    init(){
        self.name = ""
        self.email = ""
        self.id = ""
        self.password  = ""
        self.joinAddress  = ""

    }
}
