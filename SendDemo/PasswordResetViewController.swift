//
//  PasswordResetViewController.swift
//  SendDemo
//
//  Created by ProfessorTrevor on 15/11/20.
//  Copyright © 2015年 ProfessorTrevor. All rights reserved.
//

import UIKit

class PasswordResetViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setCurrentViewController(self)
    }
    
    @IBAction func requestForPasswordReset(sender: UIButton) {
        let spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        spinner.startAnimating()
        self.view.addSubview(spinner)
        let reqBody = ["email": emailTextField.text!]
        LoginManager.passwordResetForHTTP(self, requestBody: reqBody, spinner: spinner)
    }
    
}
