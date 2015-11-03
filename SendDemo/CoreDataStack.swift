//
//  CoreDataStack.swift
//  SendDemo
//
//  Created by ProfessorTrevor on 15/11/3.
//  Copyright © 2015年 ProfessorTrevor. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    var context:NSManagedObjectContext
    var psc:NSPersistentStoreCoordinator
    var model:NSManagedObjectModel
    var store:NSPersistentStore?
    
    init() {
        
        let bundle = NSBundle.mainBundle()
        let modelURL =
        bundle.URLForResource("SendDemo", withExtension:"momd")
        model = NSManagedObjectModel(contentsOfURL: modelURL!)!
        
        psc = NSPersistentStoreCoordinator(managedObjectModel:model)
        
        context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = psc
        
        let documentsURL = self.applicationDocumentsDirectory()
        let storeURL =
        documentsURL.URLByAppendingPathComponent("SendDemo")
        
        let options =
        [NSMigratePersistentStoresAutomaticallyOption: true]
        
        
        do {
            store = try psc.addPersistentStoreWithType(NSSQLiteStoreType,
                configuration: nil,
                URL: storeURL,
                options: options)
        }
        catch {
            print("Error adding persistent store: \(error)")
            abort()
        }
        
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            }
            catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    func applicationDocumentsDirectory() -> NSURL {
        
        let fileManager = NSFileManager.defaultManager()
        
        let urls = fileManager.URLsForDirectory(.DocumentDirectory,
            inDomains: .UserDomainMask) as Array<NSURL>
        
        return urls[0]
    }
    
}