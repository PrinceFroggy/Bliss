//
//  FirebaseAuthManager.swift
//  Bliss
//
//  Created by Andrew Solesa on 2020-02-15.
//  Copyright © 2020 KSG. All rights reserved.
//

import FirebaseAuth
import UIKit

class FirebaseAuthManager
{
    func signIn(email: String, pass: String, completionBlock: @escaping (_ success: Bool) -> Void)
    {
        Auth.auth().signIn(withEmail: email, password: pass) { (result, error) in
            if let error = error, let _ = AuthErrorCode(rawValue: error._code)
            {
                completionBlock(false)
            }
            else
            {
                completionBlock(true)
            }
        }
    }
}
