//
//  File.swift
//  SendDemo
//
//  Created by ProfessorTrevor on 15/8/15.
//  Copyright (c) 2015年 ProfessorTrevor. All rights reserved.
//

import Foundation
import CoreData


class Contacts: NSManagedObject {
    @NSManaged var name:String!
    @NSManaged var location:String!
    @NSManaged var isBusy:NSNumber!
    @NSManaged var isUpdate:NSNumber!
    @NSManaged var phoneNumber:String!
    @NSManaged var sex:NSNumber!
    @NSManaged var portrait:NSData!
    @NSManaged var personNameFirstLetter: String!
    @NSManaged var identifier: String!
    @NSManaged var phoneticName: String!
}

