//
//  Constants.swift
//  SendDemo
//
//  Created by ProfessorTrevor on 15/11/25.
//  Copyright © 2015年 ProfessorTrevor. All rights reserved.
//

import Foundation

struct UserDefaultsKeys {
    static let AddressBookHasSotredKey:String = "isAddressBookStored"
    static let SessionTokenKey: String = "sessionToken"
}

struct URLForServer {
    static let LoginURL: String = "http://192.168.0.109/login"
    static let SeLoginURL: String = "https://192.168.0.109/login"
    static let LogoutURL: String = "http://192.168.0.109/logout"
    static let SignupURL: String = "http://192.168.0.109/signup"
    static let PasswordResetURL: String = "http://192.168.0.109/passwordReset"
    static let PostRequestURL: String = "http://192.168.0.109/requestToNeo"
}