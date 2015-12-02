//
//  AppDelegate.swift
//  SendDemo
//
//  Created by ProfessorTrevor on 15/5/26.
//  Copyright (c) 2015年 ProfessorTrevor. All rights reserved.
//

import UIKit
import CoreData
import Contacts


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let contactStore = CNContactStore()
    lazy var coreDataStack = CoreDataStack()
    var reach: Reachability?
    var currentVC: UIViewController?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        // Programatically set the initial view controller using Storyboards
//        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
//        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let mainTabController = mainStoryboard.instantiateViewControllerWithIdentifier("MainTabEntry")
//        currentVC = mainTabController
//        self.window?.rootViewController = mainTabController
//        self.window?.makeKeyAndVisible()
        
        // 当通讯录变更时获取通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "contactChanged:", name: CNContactStoreDidChangeNotification, object: nil)
        
        // test reachability
        reach = Reachability.reachabilityForInternetConnection()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:", name: kReachabilityChangedNotification, object: nil)
        reach!.startNotifier()

        return true
    }
    
    
    func contactChanged(notification: NSNotification) {
        let defaults = NSUserDefaults.standardUserDefaults()
        let time = defaults.integerForKey("receiveContactChangeTimes")
        if time == 1 {
            print("i have change all the stuff")
            defaults.setInteger(0, forKey: "receiveContactChangeTimes")
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) { () -> Void in
            let contactManipulator = ContactsManipulater()
            let allContacts = contactManipulator.fetchAllContactsFromContactsStore()
            
            for contact in allContacts {
                
                //for debug
                let personName = CNContactFormatter.stringFromContact(contact, style: .FullName)
                print("person name is \(personName)")
                print("which identifier is \(contact.identifier)")
                
                let contactFromCoreData = contactManipulator.fetchOneContactForIdentifierForCoreData(contact.identifier)
                if let comparedContact = contactFromCoreData {
                    if comparedContact.name != personName{
                        comparedContact.name = personName
                        let phonetic = personName?.makeChinesePhonetic()
                        comparedContact.phoneticName = phonetic
                        comparedContact.personNameFirstLetter = phonetic!.substringWithRange(phonetic!.startIndex...phonetic!.startIndex).uppercaseString
                    }
                    if comparedContact.portrait !== contact.imageData{
                        comparedContact.portrait = contact.imageData
                    }
                    var phoneNumber:String? = nil
                    
                    if contact.phoneNumbers.count > 0 {
                        for phone in contact.phoneNumbers {
                            phoneNumber = (phone.value as! CNPhoneNumber).stringValue
                        }
                    }
                    else {
                        phoneNumber = nil
                    }
                    if comparedContact.phoneNumber  != phoneNumber {
                        comparedContact.phoneNumber = phoneNumber
                    }
                }
                else {
                    contactManipulator.insertNewContactsToCoreData(contact)
                }
                contactManipulator.coreDataStack.saveContext()
            }
        }
        defaults.setInteger(1, forKey: "receiveContactChangeTimes")
        
    }
    
    func reachabilityChanged(note: NSNotification)
    {
        if ((self.reach?.isReachable()) == true) {
            if ((reach?.isReachableViaWiFi()) == true) {
                let alert = UIAlertController(title: "网络连接", message: "目前wifi连接畅通", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "好球", style: .Cancel, handler: nil))
                currentVC?.presentViewController(alert, animated: true, completion: nil)
            }else {
                print("via 3G/4G")
            }
        }
        else {
            let alert = UIAlertController(title: "网络！", message: "没网咋办啊", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "算了", style: .Cancel, handler: nil))
            
            currentVC?.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        reach?.stopNotifier()
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kReachabilityChangedNotification, object: nil)
        coreDataStack.saveContext()
    }
    

}

