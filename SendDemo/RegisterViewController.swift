//
//  RegisterViewController.swift
//  SendDemo
//
//  Created by ProfessorTrevor on 15/6/23.
//  Copyright (c) 2015年 ProfessorTrevor. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import AddressBook
import AddressBookUI
import CoreData
import CoreTelephony
import Contacts
import ContactsUI

class RegisterViewController: UIViewController, NSURLSessionDataDelegate {

    let store = CNContactStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let authorizationStatus = CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)
//        switch authorizationStatus {
//        case .Denied, .Restricted:
//            displayCantAccessContactAlert()
//        case .Authorized:
//            readContactFromAddressBookAndSave()
//            print("Authorized")
//        case .NotDetermined:
//            promptForAddressBookRequestAccess()
//            print("Not Determined")
//        }
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
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
        
        
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).coreDataStack.context
        
        for contact in allContacts {
            let personName = CNContactFormatter.stringFromContact(contact, style: .FullName)
            print("the person name is \(personName!)")
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
            
            do {
                try managedObjectContext.save()
                print("success")
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
//        ABAddressBookRequestAccessWithCompletion(addressBookRef){
//            (granted: Bool, error: CFError!) in
//            dispatch_async(dispatch_get_main_queue()) {
//                if !granted {
//                    print("Just Denied")
//                    self.displayCantAccessContactAlert()
//                }
//                else {
//                    self.readContactFromAddressBookAndSave()
//                    print("Just authorized")
//                }
//            }
//        }
    }
    
    func displayCantAccessContactAlert() {
        let cantAccessContactAlert = UIAlertController(title: "Cann't Access AddressBook", message: "获取通讯录许可方可访问", preferredStyle: .Alert)
        cantAccessContactAlert.addAction(UIAlertAction(title: "Change Settings", style: .Default, handler: {action in
            self.openSettings()
        }))
        cantAccessContactAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        presentViewController(cantAccessContactAlert, animated: true, completion: nil)
    }
    
    
    
    @IBOutlet weak var userName: UITextField!

    @IBOutlet weak var passWord: UITextField!
    
    
    @IBAction func login(sender: AnyObject) {
        print("\(userName.text!)")
        print("\(passWord.text!)")
        
        // Old NSURLSession method
//        var url = NSURL(string: "http://192.168.0.108/login")
//        var request = NSMutableURLRequest(URL: url!)
//        var session = NSURLSession.sharedSession()
//        request.HTTPMethod = "POST"
//        
//        var params = ["username":"\(userName.text)", "password":"\(passWord.text)"]
//        
//        var e:NSError?
//        
//        println(params)
//        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &e)
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//        
//        
//        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
//            println("Response: \(response)")
//            println("Data: \(data)")
//            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
//            println("Body: \(strData)")
//            var e: NSError?
//            var json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &e)
//            
//            if e != nil {
//                println(e!.localizedDescription)
//                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
//                println("Error could not parse JSON: '\(jsonStr)'")
//            }
//            else {
//                if let parseJSON: AnyObject = json {
//                    var success = parseJSON["success"] as? Int
//                    println("Success: \(success)")
//                }
//                else {
//                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
//                    println("Error Could not parse JSON: \(jsonStr)")
//                }
//            }
//        })
//        task.resume()

        if self.userName.text == "" || self.passWord.text == "" {
            self.displayCantLoginAlert()
            return
            }
        
        let requestBody = ["type":"update", "userinfo":["username": "liutong", "phonenumber": "13825231242"]]
        
        Alamofire.request(.POST, "http://192.168.0.109/login", parameters: requestBody , encoding: .JSON)
            .response(){ (request, response, data, error) in
                print("request: \(request)")
                print("response: \(response)")
                print("data:    \(data)")
                let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("strData: \(strData)")
                print("error:   \(error)")

        }
        
        performSegueWithIdentifier("loginToContactTable", sender: nil)
    }
    
    func displayCantLoginAlert() {
        let displayEnterFullLoginController = UIAlertController(title: "Error", message: "Please enter username and password", preferredStyle: .Alert)
        displayEnterFullLoginController.addAction(UIAlertAction(title: "Return", style: .Cancel, handler: nil))
        self.presentViewController(displayEnterFullLoginController, animated: true, completion: nil)
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
        if segue.identifier == "loginToContactTable" {
            var destination = segue.destinationViewController
            if let tvc = destination as? UITabBarController{
                destination = (tvc.viewControllers![0] as! UINavigationController).visibleViewController!
                let otherNVC = tvc.viewControllers![1] as! UINavigationController
                otherNVC.tabBarItem.title = "刘通"
                otherNVC.tabBarItem.image = UIImage(named: "chat")
                otherNVC.tabBarItem.badgeValue = "new"
//                let width = tvc.tabBar.frame.size.width
//                let height = tvc.tabBar.frame.size.height
//                let tabBarImage = UIImage(named: "account")
//                let tabBarBGImageView = UIImageView(frame: CGRectMake(0, 0, width, height))
//                tabBarBGImageView.contentMode = .ScaleAspectFit
//                tabBarBGImageView.image = tabBarImage
//                tvc.tabBar.insertSubview(tabBarBGImageView, atIndex: 4)
             
            }
            
            
            if let contactVC = destination as? MainContactsViewController {
                contactVC.userLoginInfo.userName = userName.text
                contactVC.userLoginInfo.passWord = passWord.text
            }
        }
    }
}
