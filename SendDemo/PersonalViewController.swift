//
//  PersonalViewController.swift
//  SendDemo
//
//  Created by ProfessorTrevor on 15/7/1.
//  Copyright (c) 2015年 ProfessorTrevor. All rights reserved.
//

import UIKit

class PersonalViewController: UIViewController {
    static let storyboardName = "Main"
    static let viewControllerIdentifier = "PersonalViewController"
    
    @IBOutlet weak var personPortraitImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var temporaryImage: UIImageView!
    
    var personalInfo: Contacts!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = personalInfo.name
        companyLabel.text = personalInfo.phoneNumber
        personPortraitImage.image = UIImage(named: "obama")
    }
    
    class func detailViewControllerForProduct(info: Contacts) -> PersonalViewController {
        let storyboard = UIStoryboard(name: PersonalViewController.storyboardName, bundle: nil)
        
        let viewController = storyboard.instantiateViewControllerWithIdentifier(PersonalViewController.viewControllerIdentifier) as! PersonalViewController
        
        viewController.personalInfo = info
        
        return viewController
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
