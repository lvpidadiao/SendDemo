//
//  ContactTableViewController.swift
//  SendDemo
//
//  Created by ProfessorTrevor on 15/6/19.
//  Copyright (c) 2015年 ProfessorTrevor. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON

class ContactsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    
    var contacts:[Contacts] {
        get {
            let fetchedContact = fetchRequestController.fetchedObjects as! [Contacts]
            return fetchedContact
        }
        
        set {
            self.contacts = newValue
        }
    }
    // fetch contacts data from native CoreData store
    var fetchRequestController : NSFetchedResultsController!
    // get userInfo
    var userLoginInfo:loginInfo = loginInfo()
    // search controller
    var searchController:UISearchController!
    
    var searchResults:[Contacts] = []
    
    var resultsTableController: ResultsTableViewController!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 80.0
        
        let fetchRequest = NSFetchRequest(entityName: "Contacts")
        let sortDescriptor = NSSortDescriptor(key: "personNameFirstLetter", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        fetchRequestController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: "personNameFirstLetter", cacheName: nil)
        fetchRequestController.delegate = self
        
        do {
            try fetchRequestController.performFetch()
        }
        catch {
            print(error)
        }
        
        // MARK: - Search controller implementation
        resultsTableController = ResultsTableViewController()
        //resultsTableController.tableView.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsTableController)
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.delegate = self
       
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        
        definesPresentationContext = true
        
        print("in Contacts View Controller password: \(userLoginInfo.passWord)")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        getMyFriendsFromServer()
        print("we have post data to server")
    }
    
    // MARK: - 所有关于search的代码
    
    
    func filterContentForSearchText(searchText: String) {
        searchResults = contacts.filter({ (person: Contacts) -> Bool in
            let nameMatch = person.name.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            let phoneNumberMatch = person.phoneNumber.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return nameMatch != nil || phoneNumberMatch != nil
        })
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        filterContentForSearchText(searchText!)
        
        let resultsController = searchController.searchResultsController as! ResultsTableViewController
        resultsController.filteredContacts = searchResults
        resultsController.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func getMyFriendsFromServer() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let gettime = defaults.integerForKey("ServerGetTime")
        
        let data:NSMutableDictionary = ["userName": "\(userLoginInfo.userName)", "reqInfo":["reqType":"getAllChanged", "getTime": gettime]]
        
        let dataToTransfer = data as NSDictionary

        Alamofire.request(.POST, "http://192.168.0.109/login", parameters: dataToTransfer as? [String : AnyObject] , encoding: .JSON).responseJSON(){
            (_, _, result) in
            print("response String: \(result)")
            if let json = result.value {
                var jsonData = JSON(json)
                
                if let retVal = jsonData["retValue"].bool {
                    print("retValue \(retVal)")
                    if retVal == true {
                        self.saveFriends(jsonData["friendInfo"])
                        print("yes it is true")
                    }
                }
                
                if let returnedGetTime:Int = json["gettime"] as? Int{
                    defaults.setInteger(returnedGetTime, forKey: "ServerGetTime")
                }
                
            }
        }
    }
    
    func saveFriends(friendArray: JSON){
        
    }
    
    // when CoreData changed, update tableView
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        default:
            tableView.reloadData()
        }
        contacts = controller.fetchedObjects as! [Contacts]
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchRequestController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.name
    }
    

    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return fetchRequestController.sectionIndexTitles
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return fetchRequestController.sections!.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        let sectionInfo = fetchRequestController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ContactCell", forIndexPath: indexPath) as! ContactsTableViewCell
        
        
        configureCell(cell, indexPath: indexPath)
        // Configure the cell...
        return cell
    }
    
    func configureCell(cell: ContactsTableViewCell, indexPath: NSIndexPath) {
        let contact = fetchRequestController.objectAtIndexPath(indexPath) as! Contacts
        
        cell.portraitImage.image = UIImage(named: "obama")
        cell.nameLabel.text = contact.name
        cell.sexImage.image = UIImage(named: "male")
        cell.isBusyImage.image = UIImage(named: "moon")
        cell.phoneNumberLabel.text = contact.phoneNumber
        
    }

    
    // MARK: hide Status Bar
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    
     //MARK: - Navigation

     //In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showPersonalInformation" {
            if let indexPath = self.tableView?.indexPathForSelectedRow {
                let destinationController = segue.destinationViewController as! PersonalViewController
                destinationController.personalInfo = fetchRequestController.objectAtIndexPath(indexPath) as! Contacts
                destinationController.hidesBottomBarWhenPushed = true
            }
        }
    }
}
