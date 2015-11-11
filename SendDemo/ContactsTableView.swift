//
//  ContactsTableView.swift
//  SendDemo
//
//  Created by ProfessorTrevor on 15/11/11.
//  Copyright © 2015年 ProfessorTrevor. All rights reserved.
//

import UIKit

class ContactsTableView: UITableView {

    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
//        self.registerClass(PureCodeTableViewCell.self, forCellReuseIdentifier: "PureContactCell")
        self.separatorStyle = UITableViewCellSeparatorStyle.None
        
    }
    
    required init?(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
}
