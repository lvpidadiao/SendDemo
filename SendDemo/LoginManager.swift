//
//  LoginManager.swift
//  SendDemo
//
//  Created by ProfessorTrevor on 15/11/25.
//  Copyright © 2015年 ProfessorTrevor. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class LoginManager {
    
    class func loginForHTTP(requestBody:[String:String], VC: UIViewController, spinner: UIActivityIndicatorView? = nil)
    {
        Alamofire.request(.POST, URLForServer.LoginURL , parameters: requestBody , encoding: .JSON).responseJSON { response in
            let retstr = NSString(data: response.data!, encoding: NSUTF8StringEncoding)
            NSLog("\(retstr)")
            if spinner != nil {
                spinner!.stopAnimating()
            }
            let jsondata = JSON(data: response.data!)
            if let sessionToken = jsondata["sessionToken"].string {
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(sessionToken, forKey: UserDefaultsKeys.SessionTokenKey)
                defaults.synchronize()
            }
            if let error = jsondata["error"].string {
                let errLoginAC = UIAlertController(title: "登录出错了", message: error, preferredStyle: .Alert)
                errLoginAC.addAction(UIAlertAction(title: "返回", style: .Cancel, handler: nil))
                VC.presentViewController(errLoginAC, animated: true, completion: nil)
            }
            else{
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    VC.performSegueWithIdentifier("loginToTabBarControllerSegue", sender: nil)
                })
            }
            VC.view.userInteractionEnabled = true
        }
        VC.view.userInteractionEnabled = false
    }
    
    class func loginForSessionToken(VC: UIViewController)
    {
        let defautls = NSUserDefaults.standardUserDefaults()
        if let sessionToken = defautls.objectForKey(UserDefaultsKeys.SessionTokenKey){
            let requestBody = ["sessionToken":sessionToken]
            Alamofire.request(.POST, URLForServer.LoginURL, parameters: requestBody, encoding: .JSON).responseJSON { (response) -> Void in
                print(response)
                let jsondata = JSON(data: response.data!)
                if let error = jsondata["error"].string {
                    let code = jsondata["code"].int
                    print("error code is : \(code), error is \(error)")
                    dispatch_async(dispatch_get_main_queue()){
                        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Login")
                        VC.presentViewController(viewController, animated: true, completion: nil)
                    }
                }
                else
                {
                    if  !VC.isKindOfClass(MainContactsViewController) {
                        dispatch_async(dispatch_get_main_queue()){
                            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MainTabEntry")
                            VC.presentViewController(vc, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
        else {
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Login")
        
            VC.presentViewController(viewController, animated: false, completion: nil)

        }
    }
    
    class func signupForHTTP(requestBody:[String:String], VC: UIViewController, spinner: UIActivityIndicatorView? = nil)
    {
        Alamofire.request(.POST, URLForServer.SignupURL, parameters: requestBody, encoding: .JSON).responseJSON { (response) -> Void in
            let retstr = NSString(data: response.data!, encoding: NSUTF8StringEncoding)
            NSLog("\(retstr)")
            if spinner != nil {
                spinner?.stopAnimating()
            }
            let jsondata = JSON(data: response.data!)
//            if let error = jsondata["error"].string {
//                dispatch_async(dispatch_get_main_queue()){
//                    VC.view.userInteractionEnabled = true
//                    let errSignupVC = UIAlertController(title: "注册信息错误", message: error, preferredStyle: .Alert)
//                    errSignupVC.addAction(UIAlertAction(title: "返回", style: .Cancel, handler: nil))
//                    VC.presentViewController(errSignupVC, animated: true, completion: nil)
//                }
//            }
            if let sessionToken = jsondata["sessionToken"].string {
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(sessionToken, forKey: UserDefaultsKeys.SessionTokenKey)
                defaults.synchronize()
                loginForSessionToken(VC)
            }
            else {
                dispatch_async(dispatch_get_main_queue()){
                    let errSignupVC = UIAlertController(title: "注册信息错误", message: "网络做不到啊", preferredStyle: .Alert)
                    errSignupVC.addAction(UIAlertAction(title: "返回", style: .Cancel, handler: nil))
                    VC.presentViewController(errSignupVC, animated: true, completion: nil)
                }
            }
            VC.view.userInteractionEnabled = true
        }
        VC.view.userInteractionEnabled = false
    }
    
    class func logoutForHTTP(VC:UIViewController)
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let sessionToken = defaults.objectForKey(UserDefaultsKeys.SessionTokenKey){
            Alamofire.request(.POST, URLForServer.LogoutURL, parameters: ["sessionToken":sessionToken], encoding: .JSON).responseJSON{ response in
                let jsondata = JSON(data: response.data!)
                if let error = jsondata["error"].string {
                    let logoutAVC = UIAlertController(title: "登出错误", message: error, preferredStyle: .Alert)
                    logoutAVC.addAction(UIAlertAction(title: "返回", style: .Cancel, handler: nil))
                    VC.presentViewController(logoutAVC, animated: true, completion: nil)
                }
            }
        }
        else {
            let errAVC = UIAlertController(title: "登出错误", message: "没登陆就要登出啊，没拉屎就想吃饭？", preferredStyle: .Alert)
            errAVC.addAction(UIAlertAction(title: "返回", style: .Cancel, handler: nil))
            VC.presentViewController(errAVC, animated: true, completion: nil)
        }
    }
    
    
    class func passwordResetForHTTP(VC: UIViewController, requestBody: [String:String], spinner: UIActivityIndicatorView? = nil)
    {
        Alamofire.request(.POST, URLForServer.PasswordResetURL, parameters: requestBody, encoding: .JSON).responseJSON { (response) -> Void in
            let jsondata  = JSON(data: response.data!)
            
            if spinner != nil {
                spinner?.stopAnimating()
            }
            
            if let error = jsondata["error"].string {
                dispatch_async(dispatch_get_main_queue()) {
                    VC.view.userInteractionEnabled = true
                    let errVC = UIAlertController(title: "请求密码重设出错", message: error, preferredStyle: .Alert)
                    errVC.addAction(UIAlertAction(title: "返回", style: .Cancel, handler: nil))
                    VC.presentViewController(errVC, animated: true, completion: nil)
                }
            }
        }
        VC.view.userInteractionEnabled = false
    }
}
