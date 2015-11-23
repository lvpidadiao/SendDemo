//
//  LoginInScrollViewController.swift
//  SendDemo
//
//  Created by ProfessorTrevor on 15/10/28.
//  Copyright © 2015年 ProfessorTrevor. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SwiftyJSON
import AddressBook
import AddressBookUI
import CoreData
import CoreTelephony
import Contacts
import ContactsUI

class LoginInScrollViewController: UIViewController, NSURLSessionDataDelegate, UITextFieldDelegate {
    
    let store = (UIApplication.sharedApplication().delegate as! AppDelegate).contactStore
    var coreDataStack:CoreDataStack = {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).coreDataStack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerForKeyboardNotifications()
    }
    
    var activeField: UITextField!
    
    @IBOutlet var scrollView: UIScrollView!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        userName.delegate = self
        passWord.delegate = self
        
        let authorizationStatus = CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)
        switch authorizationStatus {
        case .Denied, .Restricted:
            displayCantAccessContactAlert()
        case .Authorized:
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                self.readContactFromAddressBookAndSave()
            })
            print("Authorized")
        case .NotDetermined:
            promptForAddressBookRequestAccess()
            print("Not Determined")
        }
    }
    
    //MARK: - Scroll text field to visible view area when keyboard show up 
    func registerForKeyboardNotifications()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWasShown(aNotification: NSNotification) {
        let info:NSDictionary = aNotification.userInfo!
        let kbSize = info.objectForKey(UIKeyboardFrameBeginUserInfoKey)?.CGRectValue.size
        
     //   print((kbSize?.height)!)
        
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, (kbSize?.height)!, 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect:CGRect = self.view.frame
        aRect.size.height -= (kbSize?.height)!
        
        if (!CGRectContainsPoint(aRect, activeField.frame.origin)) {
            self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
        }
    }
    
//    func keyboardWasShown(aNotification: NSNotification) {
//        let info:NSDictionary = aNotification.userInfo!
//        let kbSize = info.objectForKey(UIKeyboardFrameBeginUserInfoKey)?.CGRectValue.size
//        
//        var bkgndRect = activeField.superview?.frame
//        bkgndRect!.size.height += (kbSize?.height)!
//        
//        activeField.superview!.frame = bkgndRect!
//        scrollView.setContentOffset(CGPointMake(0.0, activeField.frame.y - (kbSize?.height)!), animated: true)
//        
//    }
    
    func keyboardWillBeHidden(aNotification: NSNotification)
    {
        let contentInsets = UIEdgeInsetsZero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        activeField = nil
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField === userName {
            passWord.becomeFirstResponder()
        }
        else {
            performSegueWithIdentifier("loginToTabBarControllerSegue", sender: nil)
        }
        return true
    }
    
    // MARK: - operate CNContacts
    let contactStore = CNContactStore()
    
    func openSettings(){
        let url = NSURL(string: UIApplicationOpenSettingsURLString)
        UIApplication.sharedApplication().openURL(url!)
    }
    
    // read all contacts and save to CoreData
    func readContactFromAddressBookAndSave() {
        //check whether the CoreData has the original AddressBook
        let defaults = NSUserDefaults.standardUserDefaults()
        let isAddressBookStored = defaults.boolForKey("isAddressBookStored")
        if (isAddressBookStored == true){
            return
        }
        
        // get contacts
        
        let keysToFetch = [CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName), CNContactImageDataKey, CNContactPhoneNumbersKey]
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
        
        var allContacts = [CNContact]()
        
        do {
            try store.enumerateContactsWithFetchRequest(fetchRequest){ (contact, stop) -> Void in
                allContacts.append(contact)
            }
        }
        catch let error as NSError{
            print(error.localizedDescription)
        }
        
        
        let managedObjectContext = coreDataStack.context
        
        for contact in allContacts {
            let personName = CNContactFormatter.stringFromContact(contact, style: .FullName)
            print("the person name is \(personName!)")
            print("which identifier is \(contact.identifier)")
            var phoneNumber:String? = nil
            
            if contact.phoneNumbers.count > 0 {
                for phone in contact.phoneNumbers {
                    phoneNumber = (phone.value as! CNPhoneNumber).stringValue
                }
            }
            else {
                phoneNumber = nil
            }
            
            let people = NSEntityDescription.insertNewObjectForEntityForName("Contacts", inManagedObjectContext: managedObjectContext) as! Contacts
            people.phoneNumber = phoneNumber
            if contact.isKeyAvailable(CNContactImageDataKey) {
                people.portrait = contact.imageData
            }
            people.name = personName
            people.isUpdate = false
            people.isBusy = false
            people.personNameFirstLetter = getStringFirstLetter(personName!)
            people.identifier = contact.identifier
            
            do {
                try managedObjectContext.save()
            }
            catch {
                print("\(error)")
            }
        }
        
        defaults.setBool(true, forKey: "isAddressBookStored")
        
    }
    
    
    func getStringFirstLetter(s: String) -> String {
        let mutableString = NSMutableString(string: s)
        CFStringTransform(mutableString, nil, kCFStringTransformMandarinLatin, false)
        CFStringTransform(mutableString, nil, kCFStringTransformStripDiacritics, false)
        let pinyin = mutableString as String
        
        return pinyin.substringWithRange(pinyin.startIndex...pinyin.startIndex).uppercaseString
    }
    
    
    func promptForAddressBookRequestAccess(){
        store.requestAccessForEntityType(.Contacts) { (granted, error) -> Void in
            dispatch_async(dispatch_get_main_queue()){ () -> Void in
                if !granted{
                    print("Just denied")
                    self.displayCantAccessContactAlert()
                }
                else {
                    self.readContactFromAddressBookAndSave()
                    print("Just authorized")
                }
            }
        }
    }
    
    func displayCantAccessContactAlert() {
        let cantAccessContactAlert = UIAlertController(title: "Cann't Access AddressBook", message: "获取通讯录许可方可访问", preferredStyle: .Alert)
        cantAccessContactAlert.addAction(UIAlertAction(title: "Change Settings", style: .Default, handler: {action in
            self.openSettings()
        }))
        cantAccessContactAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        presentViewController(cantAccessContactAlert, animated: true, completion: nil)
    }
    
    
    // MARK: - For user login
    @IBOutlet weak var userName: UITextField!
    
    @IBOutlet weak var passWord: UITextField!
    
    
    @IBAction func login(sender: AnyObject) {
        let username = userName?.text
        let password = passWord?.text
        
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
        
        
        let requestBody = ["username":username!, "password":password!]
        
        Alamofire.request(.POST, "https://192.168.0.108/login", parameters: requestBody , encoding: .JSON).responseJSON { response in
            print("\(response.result.error?.localizedDescription)")
            let jsondata = JSON(response.result.value!)
            if let jsondata = response.result.value {
                print("Json: \(jsondata)")
            }
        }
        
        performSegueWithIdentifier("loginToTabBarControllerSegue", sender: nil)
    }
    
    func makeRequestBody(type: String, _ user: String, _ phoneNumber: String) -> Dictionary<String, AnyObject> {
        //需要真机实测，看是否可以获得电话号码
        let myPhoneNumber = NSUserDefaults.standardUserDefaults().stringForKey("SBFormattedPhoneNumber")
        print("MyPhoneNumber is \(myPhoneNumber)")
        return ["type":"update", "userinfo":["user": "liutong", "phoneNumber": "13825231242"]]
    }
    
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        print("Finished Task")
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "loginToTabBarControllerSegue" {
            var destination = segue.destinationViewController
            if let tvc = destination as? UITabBarController{
                destination = (tvc.viewControllers![0] as! UINavigationController).visibleViewController!
//                let otherNVC = tvc.viewControllers![1] as! UINavigationController
//                otherNVC.tabBarItem.title = "刘通"
//                otherNVC.tabBarItem.image = UIImage(named: "chat")
//                otherNVC.tabBarItem.badgeValue = "new"
//                //                let width = tvc.tabBar.frame.size.width
//                //                let height = tvc.tabBar.frame.size.height
//                //                let tabBarImage = UIImage(named: "account")
//                //                let tabBarBGImageView = UIImageView(frame: CGRectMake(0, 0, width, height))
//                //                tabBarBGImageView.contentMode = .ScaleAspectFit
//                //                tabBarBGImageView.image = tabBarImage
//                //                tvc.tabBar.insertSubview(tabBarBGImageView, atIndex: 4)
//                
            }
            
            
            if let contactVC = destination as? MainContactsViewController {
                contactVC.userLoginInfo.userName = userName.text
                contactVC.userLoginInfo.passWord = passWord.text
            }
        }
    }
    
    @IBAction func unwindToLoginScreen(segue: UIStoryboardSegue) {
        
    }

    @IBAction func clearInput(sender: UIButton) {
        userName.text?.removeAll()
        passWord.text?.removeAll()
        passWord.resignFirstResponder()
    }
}

