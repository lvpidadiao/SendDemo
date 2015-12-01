//
//  SignupViewController.swift
//  SendDemo
//
//  Created by ProfessorTrevor on 15/11/20.
//  Copyright © 2015年 ProfessorTrevor. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setCurrentViewController(self)
    }

    @IBAction func signupAction(sender: UIButton) {
        let requestBody = ["username":usernameTextField.text!, "password":passwordTextField.text!, "email":emailTextField.text!]
        let spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        spinner.startAnimating()
        self.view.addSubview(spinner)
        LoginManager.signupForHTTP(requestBody, VC: self, spinner: spinner)
    }

}
