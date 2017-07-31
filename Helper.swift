//
//  Helper.swift
//  FireBaseChatApp
//
//  Created by Anik Zaman on 4/20/17.
//  Copyright © 2017 Anik Zaman. All rights reserved.
//

import Foundation
import FirebaseAuth
import UIKit
import GoogleSignIn
import FirebaseDatabase

class Helper {
    
    static let helper = Helper()
    
    func loginAnonymously() {
        
        FIRAuth.auth()?.signInAnonymously(completion: { (anonymousUser: FIRUser?, error: Error?) in
            
            if error == nil {
                
                print("UserId: \(anonymousUser!.uid)")
                
                let newUser = FIRDatabase.database().reference().child("users").child((anonymousUser!.uid))
                newUser.setValue(["displayName": "anonymous", "id": "\(anonymousUser!.uid)", "profileUrl": ""])
                self.switchToNavigationController()
                //self.switchToNavigationController()
            }
                
            else {
                print(error!.localizedDescription)
                return
            }
        })
    }
    
    func loginwithGoogle(authentication: GIDAuthentication) {
     
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        FIRAuth.auth()?.signIn(with: credential, completion: { (user: FIRUser?, error: Error?) in
            
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            else {
                print(user?.email)
                print(user?.displayName)
                print(user?.photoURL)
                
          
                let newUser = FIRDatabase.database().reference().child("users").child((user?.uid)!)
                newUser.setValue(["displayName": "\(user!.displayName!)", "id": "\(user!.uid)", "profileUrl": "\(user!.photoURL!)"])
                self.switchToNavigationController()
            }
        })
    }
    
    func switchToNavigationController() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let naviVC = storyboard.instantiateViewController(withIdentifier: "NavigationVC") as! UINavigationController
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        
        appdelegate.window?.rootViewController = naviVC

    }
}
