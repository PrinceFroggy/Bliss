//
//  ViewController.swift
//  Bliss
//
//  Created by Andrew Solesa on 2020-02-03.
//  Copyright © 2020 KSG. All rights reserved.
//

import UIKit

class ViewControllerLogin: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var m: DataModelManager!
    
    var newPassword: String?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        loginButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 3)
        
        passwordTextField.rightView = loginButton
        passwordTextField.rightViewMode = .always
        passwordTextField.delegate = self
    }
    
    @IBAction func informationButtonPressed(_ sender: UIButton)
    {
        let md5Data = MD5(string: UIDevice.current.identifierForVendor!.uuidString)
        
        let md5Hex =  md5Data.map { String(format: "%02hhx", $0) }.joined()
        
        self.newPassword = "\(md5Hex)@gmail.com"
        
        self.passwordTextField.text = md5Hex
        
        let alert = UIAlertController(title: "PASSWORD GENERATED", message: "Your following password is: \(md5Hex)! SEND THIS PASSWORD WITH PAYMENT TO BE ADDED TO DATABASE.", preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton)
    {
        let loginManager = FirebaseAuthManager()

        if !self.passwordTextField.text!.isEmpty
        {
            loginManager.signIn(email: self.newPassword!, pass: "6666666") {[weak self] (success) in
                guard let `self` = self else { return }
                
                if (success)
                {
                    self.performSegue(withIdentifier: "showMainScreen", sender: self)
                }
                else
                {
                   let alert = UIAlertController(title: "LOGIN FAILED", message: "NO SUCH USER", preferredStyle: UIAlertController.Style.alert)

                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func MD5(string: String) -> Data {
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        
        return digestData
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "showMainScreen"
        {
           let nav = segue.destination as! UINavigationController
           let svc = nav.topViewController as! ViewControllerBliss
           
           svc.m = self.m
        }
    }
}

