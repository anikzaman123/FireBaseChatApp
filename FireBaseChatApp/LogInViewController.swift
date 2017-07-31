//
//  LogInViewController.swift
//  FireBaseChatApp
//
//  Created by Anik Zaman on 4/20/17.
//  Copyright © 2017 Anik Zaman. All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseAuth

class LogInViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {

    
    @IBOutlet weak var aninymousLogin: UIButton!
    
    @IBOutlet weak var locationButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        aninymousLogin.layer.borderWidth = 2.0
        aninymousLogin.layer.borderColor = UIColor.white.cgColor
        aninymousLogin.layer.cornerRadius = 8
        
        
        locationButton.layer.borderWidth = 6
        locationButton.layer.borderColor = UIColor.white.cgColor
        locationButton.layer.cornerRadius = 25
        
        GIDSignIn.sharedInstance().clientID = "507767798287-2f2m6a702ct6j5ujr043eeqbp9cjilpj.apps.googleusercontent.com"
    
        GIDSignIn.sharedInstance().uiDelegate = self
        
        GIDSignIn.sharedInstance().delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
      
        print("testing")
        super.viewDidAppear(animated)
        print(FIRAuth.auth()?.currentUser)
        
        FIRAuth.auth()?.addStateDidChangeListener({ (auth: FIRAuth, user: FIRUser?) in
            if user != nil {
                print(user)
                Helper.helper.switchToNavigationController()
            } else {
                print("unauthorized")
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func loginAnonymouslyDidTapped(_ sender: Any) {
        
        Helper.helper.loginAnonymously()

    }
    

    @IBAction func googleLoginDidTapped(_ sender: Any) {
        
        GIDSignIn.sharedInstance().signIn()
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        print(user.authentication)
        
        Helper.helper.loginwithGoogle(authentication: user.authentication)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
