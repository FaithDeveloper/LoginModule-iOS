//
//  JoinViewcontroller.swift
//  LoginModel
//
//  Created by MAC on 2017. 6. 17..
//  Copyright © 2017년 kcs. All rights reserved.
//

import UIKit

class JoinViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet var bgContainerView: UIView!
    @IBOutlet var txtID: UITextField!
    @IBOutlet var txtPwd: UITextField!
    @IBOutlet var txtConfirm: UITextField!
    @IBOutlet var txtEmail: UITextField!
    @IBOutlet var txtUserName: UITextField!
    
    var txtArray: [UITextField]!
    
    var isCheckedID: Bool = false
    
    @IBAction func clickSignIn(_ sender: Any) {
        guard txtArray != nil && txtArray.count != 0 else {
            return
        }
        
        for inputField in txtArray {
            if (inputField.text?.isEmpty)! {
                showErrorAlert(title:"error", msg: "모두 입력해주세요.")
                return
            }
        }
        
        if !isCheckedID {
            showErrorAlert(title:"error", msg: "ID 중복 체크 확인해주세요.")
            return
        }
        
        if txtPwd.text != txtConfirm.text {
            showErrorAlert(title:"error", msg: "비밀번호가 일치하지 않습니다.")
            return
        }
        
        
//        let txtArrayEndIndex = txtArray.endIndex
//        let sliceUserInfoTextfeild = txtArray[1...txtArrayEndIndex]
//        for txtFiled in sliceUserInfoTextfeild {
//            if Utils.hasSpecialCharactor(targetString: txtFiled.text!){
//                self.showErrorAlert(title: "error", msg: "특수 문자를 사용할 수 없습니다.")
//            }
//        }
//        
        print("All input Data!!!!")
        //appDelegate.getDatabaseRef().childByAutoId().key  : auto create ID
        if let appDelegate = self.getAppDelegate(){
            let info = UserInfo(name: txtUserName.text, email: txtEmail.text, id: txtID.text, password: txtPwd.text, joinAddress: "custom")
            appDelegate.addUserProfile(uid: appDelegate.getDatabaseRef().childByAutoId().key, userInfo: info)
            gotoMainViewController(user: info)
        }
    }
    
    
    func getAppDelegate() -> AppDelegate!{
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func checkCorrentEmail(emailAddress: String) -> Bool{
        if emailAddress == "" || emailAddress.range(of:"@") == nil {
            self.showErrorAlert(title: "error", msg: "올바른 이메일을 입력해주세요.")
            return false
        }
        return true
    }
    
    
    
    @IBAction func clickCheckID(_ sender: Any) {
        
        
        //ID 중복체크
         if let databaseRef =  self.getAppDelegate().getDatabaseRef() {
            // 이메일 체크
            if(!checkCorrentEmail(emailAddress: txtID.text!)){
                self.isCheckedID = false
                return
            }
            
            //@ 앞에 id 부분만 선택. 특수 문자'.'을 '_'로 변경
            let id = txtID.text!.components(separatedBy: "@")
            let targetId = Utils.changeStringToDoNotUseCharactorFormFireBase(targetString: id[0])
            
            let databaseRootChild = databaseRef.child("user_profiles")
            databaseRootChild.observeSingleEvent(of: .value, with: { (snapshot) in
                
                let snapshot = snapshot.value as? NSDictionary
                
                if(snapshot != nil){
                    
                    let existIds = snapshot?.allValues as! [NSDictionary]
                    for info in existIds{
                        if let id = info.value(forKey: "id") as? String{
                            if id == targetId {
                            self.showErrorAlert(title: "error", msg: "아이디가 존재합니다.")
                            self.isCheckedID = false
                            return
                            }
                        }
                    }
                }
                Utils.showAlert(viewController: self  ,title: "info", msg: "해당 아이디 사용 가능합니다.", handler: {(action) in self.isCheckedID = true})
                
            })
        }
    }
    
    func showErrorAlert(title: String, msg: String){
          Utils.showAlert(viewController: self  ,title: title, msg: msg, handler: nil)
    }
    
    override
    func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case txtID:
            isCheckedID = false
        default:
            break
        }
        
        
        txtArray = [txtID, txtPwd, txtConfirm, txtEmail, txtUserName]
        for txtFiled in txtArray{
            txtFiled.delegate = self
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case txtID:
              break
        case txtEmail: break
        default:
            if Utils.hasSpecialCharactor(targetString: textField.text!){
                self.showErrorAlert(title: "error", msg: "특수 문자를 사용할 수 없습니다.")
            }
        }
    }
    
    override
    func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func gotoMainViewController(user: UserInfo){
        let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainViewID" ) as! MainViewController
        mainVC.user = user
        self.present(mainVC, animated: true, completion: nil)
    }}
