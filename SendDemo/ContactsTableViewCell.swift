//
//  ContactsTableViewCell.swift
//  SendDemo
//
//  Created by ProfessorTrevor on 15/6/19.
//  Copyright (c) 2015年 ProfessorTrevor. All rights reserved.
//

import UIKit

class ContactsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var portraitImage: UIImageView!{
        didSet{
            // make the portrait circular corner
            portraitImage.layer.cornerRadius = portraitImage.frame.width / 2
            portraitImage.clipsToBounds = true
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sexImage: UIImageView!
    @IBOutlet weak var isUpdateImage: UIImageView!
    @IBOutlet weak var isBusyImage: UIImageView!
    @IBOutlet weak var phoneNumberLabel: UILabel!


}
