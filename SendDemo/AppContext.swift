//
//  AppContext.swift
//  SendDemo
//
//  Created by ProfessorTrevor on 15/12/1.
//  Copyright © 2015年 ProfessorTrevor. All rights reserved.
//

import Foundation


func setCurrentViewController(vc: UIViewController)
{
    let appDelegate = (UIApplication.sharedApplication().delegate) as! AppDelegate
    appDelegate.currentVC = vc
}

func getCurrentViewController() -> UIViewController? {
    let appDelegate = (UIApplication.sharedApplication().delegate) as! AppDelegate
    return appDelegate.currentVC
}