//
//  ResultsTableViewController.swift
//  SendDemo
//
//  Created by ProfessorTrevor on 15/10/26.
//  Copyright © 2015年 ProfessorTrevor. All rights reserved.
//

import UIKit
import CoreData

extension String {
    func makeChinesePheotic() -> String {
        let mutableString = NSMutableString(string: self)
        CFStringTransform(mutableString, nil, kCFStringTransformMandarinLatin, false)
        CFStringTransform(mutableString, nil, kCFStringTransformStripDiacritics, false)
        let pinyin = mutableString as String
        return pinyin
    }
    
    func escapeWhiteSpace() -> String {
        return self.stringByReplacingOccurrencesOfString(" ", withString: "")
    }
}

class ResultsTableViewController: UITableViewController,NSFetchedResultsControllerDelegate, UISearchBarDelegate,UISearchResultsUpdating {

    var filteredContacts = [Contacts]()
    
    var coreDataStack:CoreDataStack = {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).coreDataStack
    }()
    
    static let tableViewCellIdentifier = "searchedResultsCell"
    
    var fetchRequestController: NSFetchedResultsController!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let fetchRequest = NSFetchRequest(entityName: "Contacts")
        let sortDescriptor = NSSortDescriptor(key: "personNameFirstLetter", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).coreDataStack.context
        fetchRequestController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: "personNameFirstLetter", cacheName: nil)
        fetchRequestController.delegate = self
        
        do {
            try fetchRequestController.performFetch()
        }
        catch {
            print(error)
        }
        
        
        
        let nib = UINib(nibName: "SearchedTableCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: ResultsTableViewController.tableViewCellIdentifier)
        
        self.tableView.rowHeight = 80.0
        
        tableView.dataSource = self
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
    }
    
    func filterContentForSearchText(searchText: String) {
            let fetchRequest = NSFetchRequest(entityName: "Contacts")
            fetchRequest.propertiesToFetch = ["name","phoneNumber"]
            fetchRequest.predicate = NSPredicate(format: "name CONTAINS[CD] %@ OR phoneNumber CONTAINS[cd] %@", searchText, searchText)
            do {
                filteredContacts =  try coreDataStack.context.executeFetchRequest(fetchRequest) as! [Contacts]
            }
            catch {
                print(error)
            }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchText = searchController.searchBar.text?.makeChinesePheotic()
        filterContentForSearchText(searchText!)
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
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
