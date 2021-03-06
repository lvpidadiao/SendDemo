//
//  ContactsManipulater.swift
//  SendDemo
//
//  Created by ProfessorTrevor on 15/10/30.
//  Copyright © 2015年 ProfessorTrevor. All rights reserved.
//

import Foundation
import UIKit
import Contacts
import CoreData


extension UIColor {
    
    class var blue:UIColor {
        get {
            return UIColor(red:0.421593, green: 0.657718, blue: 0.972549, alpha: 1)
        }
    }
    
    class var lightBlue:UIColor {
        get {
            return UIColor(red:0.700062, green: 0.817345, blue: 0.972549, alpha: 1)
        }
    }
    
}

extension String {
    func makeChinesePhonetic() -> String {
        let mutableString = NSMutableString(string: self)
        CFStringTransform(mutableString, nil, kCFStringTransformMandarinLatin, false)
        CFStringTransform(mutableString, nil, kCFStringTransformStripDiacritics, false)
        let pinyin = mutableString as String
        return pinyin
    }
    
    func escapeWhiteSpace() -> String {
        return self.stringByReplacingOccurrencesOfString(" ", withString: "")
    }
    
}


class ContactsManipulater {
    // MARK: - For user CoreData Contacts
    var coreDataStack:CoreDataStack = {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).coreDataStack
    }()

    let fetchRequest = NSFetchRequest(entityName: "Contacts")
    
    
    // MARK: - for local Contacts framework Contacts
    let store = (UIApplication.sharedApplication().delegate as! AppDelegate).contactStore
    let allKeysToFetch = [CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName), CNContactImageDataKey, CNContactPhoneNumbersKey]
    
    func fetchAllContactsFromContactsStore() -> [CNContact] {
        let fetchRequest = CNContactFetchRequest(keysToFetch: allKeysToFetch)
        
        var allContacts = [CNContact]()
        
        do {
            try store.enumerateContactsWithFetchRequest(fetchRequest, usingBlock: { (contact, stop) -> Void in
                allContacts.append(contact)
            })
        }
        catch let error as NSError {
            print("\(error.localizedDescription)")
        }
        return allContacts
    }
    
    func fetchOneContactForIdentifierForCoreData(matchedString: String) -> Contacts? {
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", matchedString)
        var result = [Contacts]()
        let moc = coreDataStack.context
        do{
            result = try moc.executeFetchRequest(fetchRequest) as! [Contacts]
        }
        catch let error as NSError{
            print("\(error.localizedDescription)")
        }
        return result.first
    }
    
    func fetchAllPropertyFromCoreData(property: [String]) -> [String] {
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchRequest.resultType = .DictionaryResultType
        fetchRequest.includesPropertyValues = true
        fetchRequest.propertiesToFetch = property
        
        var properties = [String]()
        let moc = coreDataStack.context
        do {
            let result = try moc.executeFetchRequest(fetchRequest) as! [NSDictionary]
            result.forEach({ (dict) -> () in
                properties.append(dict["identifier"] as! String)
            })
        }
        catch let error as NSError{
            print("\(error.localizedDescription)")
        }
        return properties
    }
    
    func insertNewContactsToCoreData(contact: CNContact) {
        let person = NSEntityDescription.insertNewObjectForEntityForName("Contacts", inManagedObjectContext: coreDataStack.context) as! Contacts
        let name = CNContactFormatter.stringFromContact(contact, style: .FullName)
        person.name = name
        let phonetic = name?.makeChinesePhonetic()
        person.phoneticName = phonetic
        person.personNameFirstLetter = phonetic!.substringWithRange(phonetic!.startIndex...phonetic!.startIndex).uppercaseString
        person.isUpdate = false
        person.isBusy = false
        person.identifier = contact.identifier
        
        coreDataStack.saveContext()
    }
    
}