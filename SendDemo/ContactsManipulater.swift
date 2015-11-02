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

class ContactsManipulater {
    // MARK: - For user CoreData Contacts
    let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
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
    
    func getStringFirstLetter(s: String) -> String {
        let mutableString = NSMutableString(string: s)
        CFStringTransform(mutableString, nil, kCFStringTransformMandarinLatin, false)
        CFStringTransform(mutableString, nil, kCFStringTransformStripDiacritics, false)
        let pinyin = mutableString as String
        
        return pinyin.substringWithRange(pinyin.startIndex...pinyin.startIndex).uppercaseString
    }
    
    func convertChineseToPheoticLetter(s: String) -> String {
        let mutableString = NSMutableString(string: s)
        CFStringTransform(mutableString, nil, kCFStringTransformMandarinLatin, false)
        CFStringTransform(mutableString, nil, kCFStringTransformStripDiacritics, false)
        let pinyin = mutableString as String
        return pinyin
    }
    
    func insertNewContactsToCoreData(contact: CNContact) {
        let person = NSEntityDescription.insertNewObjectForEntityForName("Contacts", inManagedObjectContext: moc) as! Contacts
        person.name = CNContactFormatter.stringFromContact(contact, style: .FullName)
        person.isUpdate = false
        person.isBusy = false
        person.personNameFirstLetter = getStringFirstLetter(person.name)
        person.identifier = contact.identifier
        
        saveChanges()
    }
    
    
    func saveChanges() {
        if moc.hasChanges {
            do {
                try moc.save()
            }
            catch let error as NSError{
                NSLog("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
        }
    }
    
}