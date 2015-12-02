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
        let username = usernameTextField?.text
        let password = passwordTextField?.text
        let email = emailTextField?.text
        
        if username?.characters.count < 5 {
            let usernameAlert = UIAlertController(title: "请注意", message: "用户名长度需大于5个字符", preferredStyle: .Alert)
            usernameAlert.addAction(UIAlertAction(title: "返回", style: .Cancel, handler: nil))
            self.presentViewController(usernameAlert, animated: true, completion: nil)
            return
        }
        else if password?.characters.count < 7 {
            let passwordAlert = UIAlertController(title: "请注意", message: "密码长度至少为7个字符", preferredStyle: .Alert)
            passwordAlert.addAction(UIAlertAction(title: "返回", style: .Cancel, handler: nil))
            self.presentViewController(passwordAlert, animated: true, completion:  nil)
            return
        }
        else if ((email?.containsString("@")) == false) {
            let errAlert = UIAlertController(title: "请求格式不正确", message: "请输入正确email", preferredStyle: .Alert)
            errAlert.addAction(UIAlertAction(title: "重写", style: .Cancel, handler: nil))
            self.presentViewController(errAlert, animated: true, completion: nil)
            return
        }
        else {
            let requestBody = ["username":usernameTextField.text!, "password":passwordTextField.text!, "email":emailTextField.text!]
            let spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
            spinner.startAnimating()
            self.view.addSubview(spinner)
            LoginManager.signupForHTTP(requestBody, VC: self, spinner: spinner)
        }
    }

}
