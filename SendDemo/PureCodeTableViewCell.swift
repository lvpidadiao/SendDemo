//
//  PureCodeTableViewCell.swift
//  SendDemo
//
//  Created by ProfessorTrevor on 15/11/11.
//  Copyright © 2015年 ProfessorTrevor. All rights reserved.
//

import UIKit

class PureCodeTableViewCell: UITableViewCell {

    let color = UIColor.lightBlue
    
    var portraitImage: UIImageView!{
        didSet{
            // make the portrait circular corner
            portraitImage.layer.cornerRadius = portraitImage.frame.width / 2
            portraitImage.clipsToBounds = true
        }
    }
    var nameLabel: UILabel!
    var sexImage: UIImageView!
    var isUpdateImage: UIImageView!{
        didSet{

        }
    }
    var isBusyImage: UIImageView!
    var phoneNumberLabel: UILabel!
    var inputTextField: UITextField!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .None
        
        portraitImage = UIImageView()
        portraitImage.frame = CGRect(x: 8, y: 8, width: 64, height: 64)
        self.addSubview(portraitImage)
        
        nameLabel = UILabel(frame: CGRect(x: 80, y: 8, width: 97, height: 32))
        self.addSubview(nameLabel)
        
        phoneNumberLabel = UILabel(frame: CGRect(x: 185, y: 8, width: 81, height: 32))
        phoneNumberLabel.font = phoneNumberLabel.font.fontWithSize(13)
        self.addSubview(phoneNumberLabel)
        
        sexImage = UIImageView(frame: CGRect(x: 80, y: 48, width: 23, height: 23))
        self.addSubview(sexImage)
        
        isUpdateImage = UIImageView(frame: CGRect(x: 287, y: 8, width: 23, height: 23))
        self.addSubview(isUpdateImage)
        
        isBusyImage = UIImageView(frame: CGRect(x: 287, y: 48, width: 23, height: 23))
        self.addSubview(isBusyImage)

        let sepalator = UIView()
        sepalator.frame = CGRect(x: 0, y: 80 - 1, width: 320, height: 1)
        sepalator.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
        self.addSubview(sepalator)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
