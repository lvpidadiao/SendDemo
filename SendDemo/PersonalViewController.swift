//
//  PersonalViewController.swift
//  SendDemo
//
//  Created by ProfessorTrevor on 15/7/1.
//  Copyright (c) 2015年 ProfessorTrevor. All rights reserved.
//

import UIKit

class PersonalViewController: UIViewController {
    
    
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
