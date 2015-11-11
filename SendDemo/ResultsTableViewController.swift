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

    var allContacts = [Contacts]()
    var filteredContacts = [Contacts]()
    
    var coreDataStack:CoreDataStack = {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).coreDataStack
    }()
    
    var ptbView: PullToBounceWrapper!
    
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
            allContacts = fetchRequestController.fetchedObjects as! [Contacts]
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
        let searchItems = searchText.componentsSeparatedByString(" ") as [String]
        let andMatchPredicates: [NSPredicate] = searchItems.map { searchString in
            
            
            var searchItemsPredicate = [NSPredicate]()
            
            let nameExpression = NSExpression(forKeyPath: "name")
            let searchStringExpression = NSExpression(forConstantValue: searchString)
            
            let nameSearchComparisonPredicate = NSComparisonPredicate(leftExpression: nameExpression, rightExpression: searchStringExpression, modifier: .DirectPredicateModifier, type: .ContainsPredicateOperatorType, options: .CaseInsensitivePredicateOption)
            
            searchItemsPredicate.append(nameSearchComparisonPredicate)
            
            // this below code is for compare Int value not String
//            let numberFormatter = NSNumberFormatter()
//            numberFormatter.numberStyle = .NoStyle
//            numberFormatter.formatterBehavior = .BehaviorDefault
//            
//            let targetNumber = numberFormatter.numberFromString(searchString)
            
            // `searchString` may fail to convert to a number.
            // Use `targetNumberExpression` in both the following predicates.
            let phoneNumberExpression = NSExpression(forKeyPath: "phoneNumber")
            let phoneNumberPredicate = NSComparisonPredicate(leftExpression: phoneNumberExpression, rightExpression: searchStringExpression, modifier: .DirectPredicateModifier, type: .ContainsPredicateOperatorType, options: .CaseInsensitivePredicateOption)
            
            searchItemsPredicate.append(phoneNumberPredicate)
                
                // TODO: renaming
                // `price` field matching.
//                let lhs = NSExpression(forKeyPath: "introPrice")
//                
//                let finalPredicate = NSComparisonPredicate(leftExpression: lhs, rightExpression: targetNumberExpression, modifier: .DirectPredicateModifier, type: .EqualToPredicateOperatorType, options: .CaseInsensitivePredicateOption)
//                
//                searchItemsPredicate.append(finalPredicate)
            
            let orMatchPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: searchItemsPredicate)
            
            return orMatchPredicate
        }
        
        let finalCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: andMatchPredicates)
        
        filteredContacts = allContacts.filter(){finalCompoundPredicate.evaluateWithObject($0)}
        
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
//        mainView?.hidden = false
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let whitespaceCharacterSet = NSCharacterSet.whitespaceCharacterSet()
        let searchText = searchController.searchBar.text?.stringByTrimmingCharactersInSet(whitespaceCharacterSet)
        filterContentForSearchText(searchText!)
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
//        ptbView = searchBar.superview?.superview as! PullToBounceWrapper
//        for v in ptbView.subviews{
//            if v.isKindOfClass(ContactsTableView) {
//                let ctv = v as! ContactsTableView
//                ctv.scrollToRowAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), atScrollPosition: .Top, animated: false)
//            }
//        }
        return true
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
