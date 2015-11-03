//
//  ResultsTableViewController.swift
//  SendDemo
//
//  Created by ProfessorTrevor on 15/10/26.
//  Copyright © 2015年 ProfessorTrevor. All rights reserved.
//

import UIKit

class ResultsTableViewController: UITableViewController {

    var filteredContacts = [Contacts]()
    
    static let tableViewCellIdentifier = "searchedResultsCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "SearchedTableCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: ResultsTableViewController.tableViewCellIdentifier)
        
        self.tableView.rowHeight = 80.0
        
        tableView.dataSource = self
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredContacts.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ResultsTableViewController.tableViewCellIdentifier, forIndexPath: indexPath) as! SearchResultsTableViewCell
        
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: SearchResultsTableViewCell, indexPath: NSIndexPath) {
        let contact = filteredContacts[indexPath.row]
        
        cell.searchResultsImageView.image = UIImage(named: "obama")
        cell.searchedResultsNameLabel.text = contact.name
        cell.searchedResultsPhoneLabel.text = contact.phoneNumber
    }
}
