//
//  MyselfViewController.swift
//  SendDemo
//
//  Created by ProfessorTrevor on 15/11/5.
//  Copyright © 2015年 ProfessorTrevor. All rights reserved.
//

import UIKit

class MyselfViewController: UIViewController {
    
    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCurrentViewController(self)
        let defaults = NSUserDefaults.standardUserDefaults()
        let sessionToken = defaults.stringForKey(UserDefaultsKeys.SessionTokenKey)
        if sessionToken == nil{
            logoutButton.hidden = true
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setCurrentViewController(self)
    }

    @IBAction func logout(sender: UIButton) {
        LoginManager.logoutForHTTP(self)
    }
}
