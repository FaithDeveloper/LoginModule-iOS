//
//  Utils.swift
//  LoginModel
//
//  Created by MAC on 2017. 6. 17..
//  Copyright © 2017년 kcs. All rights reserved.
//

import UIKit

//MARK: Base64 인코딩, 디코딩
extension String {
    //: ### Base64 encoding a string
    func base64Encoded() -> String? {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }
    
    //: ### Base64 decoding a string
    func base64Decoded() -> String? {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}

// MARK: 키보드 숨기기(단, 모든 클릭 시 키보드 숨기기 함수가 호출됨)
// 원하는 곳에 배치
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

class Utils {
    // 라운드뷰 설정
    class func changeBoxStyle(box: UIView, color: String){
        box.layer.borderColor = UIColor.darkGray.cgColor
        box.layer.borderWidth = 1
        box.layer.cornerRadius = 5
        box.backgroundColor = hexStringToUIColor(hex: color)
    }
    
    //MARK : 색상값 변경
    //색상 값 입력 시 UIColor로 리턴
    class func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    // MARK: 다이얼로그 관련 모듈
    //Alert Dialog
    class func showAlert(viewController: UIViewController?,title: String, msg: String, handler: ((UIAlertAction) -> Swift.Void)?){
        
        
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: handler)
        alertController.addAction(defaultAction)
        
        viewController?.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: Text 관련 모듈
    //특수 문자 삽입 시 '_'로 변경
    class func changeStringToDoNotUseCharactorFormFireBase(targetString: String)-> String{
        var changeString: String = ""
        //        let arrCharacterToReplace = [".","#","$","[","]"]
        let arrCharacterToReplace = ["."]
        for character in arrCharacterToReplace{
            changeString = targetString.replacingOccurrences(of: character, with: "_")
        }
        
        return changeString
    }
    
    //특수 문자가 삽입 되었는지 체크
    class func hasSpecialCharactor(targetString: String)-> Bool{

        let specialCharactor = [".","#","$","[","]", "@"]
        
        for character in specialCharactor{
            if targetString.range(of: character) != nil {
                return true
            }
        }
        return false
    }
}
