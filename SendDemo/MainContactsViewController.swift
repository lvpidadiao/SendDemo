//
//  MainContactsViewController.swift
//  SendDemo
//
//  Created by ProfessorTrevor on 15/11/10.
//  Copyright © 2015年 ProfessorTrevor. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON

class MainContactsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate
{

    @IBOutlet weak var tableView: UITableView!
    // fetch contacts data from native CoreData store
    var coreDataStack:CoreDataStack = {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).coreDataStack
    }()
    var fetchRequestController : NSFetchedResultsController!
    // get userInfo
    var userLoginInfo:loginInfo = loginInfo()
    // search controller
    var searchController:UISearchController!
    
    //    var searchResults:[Contacts] = []
    
    var resultsTableController: ResultsTableViewController!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 80.0
        
        let fetchRequest = NSFetchRequest(entityName: "Contacts")
        let sortDescriptor = NSSortDescriptor(key: "personNameFirstLetter", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let managedObjectContext = coreDataStack.context
        fetchRequestController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: "personNameFirstLetter", cacheName: nil)
        fetchRequestController.delegate = self
        
        do {
            try fetchRequestController.performFetch()
        }
        catch {
            print(error)
        }
        
        let customHeaderView = UIView(frame: CGRectMake(0, 0, 320, 44))
        // MARK: - Search controller implementation
        resultsTableController = ResultsTableViewController()
        
        // We want to be the delegate for our filtered table so didSelectRowAtIndexPath(_:) is called for both tables.
        resultsTableController.tableView.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsTableController)
        searchController.searchBar.sizeToFit()
        
        customHeaderView.addSubview(searchController.searchBar)
        tableView.tableHeaderView = customHeaderView
        tableView.bringSubviewToFront(customHeaderView)
        // make the searchupdating and searchbar delegate to resultsTableController
        searchController.searchBar.delegate = resultsTableController
        searchController.searchResultsUpdater = resultsTableController
        searchController.searchBar.placeholder = "Hello Loser"
        
        searchController.dimsBackgroundDuringPresentation = false
        
        definesPresentationContext = true
        
        print("in Contacts View Controller password: \(userLoginInfo.passWord)")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        tableView.sectionIndexBackgroundColor = UIColor.clearColor()
        
        //      通过tag寻找view
        //        tableView.viewWithTag(10)
        
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        getMyFriendsFromServer()
        print("we have post data to server")
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
    
    // MARK: - when CoreData changed, update tableView
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            break
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        //        tableView.reloadData()
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            let cell = tableView.cellForRowAtIndexPath(indexPath!) as! ContactsTableViewCell
            configureCell(cell, indexPath: indexPath!)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchRequestController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.name
    }
    
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return fetchRequestController.sectionIndexTitles
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return fetchRequestController.sections!.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        let sectionInfo = fetchRequestController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
        cell.isBusyImage.image = contact.isBusy == true ? UIImage(named: "busy") : UIImage(named: "coffee")
        cell.isUpdateImage.image = contact.isUpdate == true ? UIImage(named: "updateAlert") : UIImage(named: "notUpdateAlert")
        cell.phoneNumberLabel.text = contact.phoneNumber
        
    }
    
    
    // MARK: hide Status Bar
    //    override func prefersStatusBarHidden() -> Bool {
    //        return true
    //    }
    
    //MARK: - ContactsTableView and ResultsTableView tableview delegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedPerson: Contacts
        if tableView == self.tableView {
            selectedPerson = fetchRequestController.objectAtIndexPath(indexPath) as! Contacts
        }
        else {
            selectedPerson = resultsTableController.filteredContacts[indexPath.row]
        }
        
        let pvc = PersonalViewController.detailViewControllerForProduct(selectedPerson)
        pvc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(pvc, animated: true)
    }
    
    
    //MARK: - Navigation
    
    //In a storyboard-based application, you will often want to do a little preparation before navigation
    //    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    //        if segue.identifier == "showPersonalInformation" {
    //            if let indexPath = self.tableView?.indexPathForSelectedRow {
    //                let destinationController = segue.destinationViewController as! PersonalViewController
    //                destinationController.personalInfo = fetchRequestController.objectAtIndexPath(indexPath) as! Contacts
    //                destinationController.hidesBottomBarWhenPushed = true
    //            }
    //        }
    //    }
}
