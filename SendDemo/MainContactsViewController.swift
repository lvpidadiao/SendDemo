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


class MainContactsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, MJNIndexViewDataSource
{

    // fetch contacts data from native CoreData store
    var coreDataStack:CoreDataStack = {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).coreDataStack
    }()
    var fetchRequestController : NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Contacts")
        let sortDescriptor = NSSortDescriptor(key: "personNameFirstLetter", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).coreDataStack.context
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: "personNameFirstLetter", cacheName: nil)
        
        do {
            try frc.performFetch()
        }
        catch {
            print(error)
        }
        return frc
    }()
    
    var backfrc: NSFetchedResultsController?
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    // get userInfo
    var userLoginInfo:loginInfo = loginInfo()
    // search controller
    var searchController:UISearchController!
    
    var indexTitle = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    
    var resultsTableController: ResultsTableViewController!
    
    var tableView: ContactsTableView!
    
    var indexView: MJNIndexView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchRequestController.delegate = self
        
//        navigationController?.navigationBar.hidden = true
        
        // configure tableView and PullToBounce TableView

        tableView = ContactsTableView(frame: self.view.bounds, style: .Plain)
        tableView.estimatedRowHeight = 80.0

        let nib = UINib(nibName: "MainContactsTableCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "mainCell")

        configurePullToBounceView(tableView)
        
        // configure MJNIndexView
        indexView = MJNIndexView(frame: view.bounds)
        configureMJNIndexView(indexView)

        // MARK: - Search controller implementation
        resultsTableController = ResultsTableViewController()
        
        // We want to be the delegate for our filtered table so didSelectRowAtIndexPath(_:) is called for both tables.
        resultsTableController.tableView.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsTableController)
        searchController.searchBar.sizeToFit()
        // make the searchupdating and searchbar delegate to resultsTableController
        searchController.searchBar.delegate = resultsTableController
        searchController.searchResultsUpdater = resultsTableController
        searchController.searchBar.placeholder = "Hello Loser"
        searchController.delegate = resultsTableController
        
        self.tableView.tableHeaderView = searchController.searchBar
        
        searchController.dimsBackgroundDuringPresentation = true
        
        definesPresentationContext = true
        
        print("in Contacts View Controller password: \(userLoginInfo.passWord)")
        
        tabBarController!.tabBar.translucent = false
    }
    
    
    func configurePullToBounceView(tableView: ContactsTableView){
        let bodyView = UIView()
        bodyView.frame = self.view.frame
        bodyView.frame.y += 20 + 44
        bodyView.backgroundColor = UIColor.blue

        tableView.frame.height -= (20 + 44 + tabBarController!.tabBar.frame.height)
        tableView.separatorStyle = .None
        tableView.dataSource = self
        tableView.delegate  = self

        let tableViewWrapper = PullToBounceWrapper(scrollView: tableView)

        bodyView.addSubview(tableViewWrapper)
        tableViewWrapper.didPullToRefresh = {
            self.indexView.hidden = true
            NSTimer.schedule(delay: 2) { timer in
                tableViewWrapper.stopLoadingAnimation()
                self.indexView.hidden = false
            }
        }

        bodyView.addSubview(tableViewWrapper)
        self.view.addSubview(bodyView)
    }
    
    func configureMJNIndexView(indexView: MJNIndexView) -> Void
    {
        indexView.dataSource = self
        indexView.fontColor = UIColor.redColor()
        indexView.selectedItemFontColor = UIColor.purpleColor()
        indexView.font = indexView.font.fontWithSize(13)
        
        view.addSubview(indexView)
        view.bringSubviewToFront(indexView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setCurrentViewController(self)
        
        let reach = (UIApplication.sharedApplication().delegate as! AppDelegate).reach
        // if reachable not check the validation ,just wait to complete server code
        if !reach!.isReachable() {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) { () -> Void in
                LoginManager.loginForSessionToken(self)
            }
        }
        else {
            print("reachable, but we wait.")
        }
//        getMyFriendsFromServer()

    }
    

    
//    func getMyFriendsFromServer() {
//        let defaults = NSUserDefaults.standardUserDefaults()
//        let gettime = defaults.integerForKey("ServerGetTime")
//        
//        let data:NSMutableDictionary = ["userName": "\(userLoginInfo.userName)", "reqInfo":["reqType":"getAllChanged", "getTime": gettime]]
    
//        let dataToTransfer = data as NSDictionary
        
//        Alamofire.request(.POST, "http://192.168.0.109/login", parameters: dataToTransfer as? [String : AnyObject] , encoding: .JSON).responseJSON(){
//            (_, _, result) in
//            print("response String: \(result)")
//            if let json = result.value {
//                var jsonData = JSON(json)
//                
//                if let retVal = jsonData["retValue"].bool {
//                    print("retValue \(retVal)")
//                    if retVal == true {
//                        self.saveFriends(jsonData["friendInfo"])
//                        print("yes it is true")
//                    }
//                }
//                
//                if let returnedGetTime:Int = json["gettime"] as? Int{
//                    defaults.setInteger(returnedGetTime, forKey: "ServerGetTime")
//                }
//                
//            }
//        }
//    }
    
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
        fetchRequestController = controller
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchRequestController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.name
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
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
        let cell = tableView.dequeueReusableCellWithIdentifier("mainCell", forIndexPath: indexPath) as! ContactsTableViewCell
        
        
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
    
    
    // MARK: - MJNIndexTableIndexBar datasource
    
    func sectionIndexTitlesForMJNIndexView(indexView: MJNIndexView!) -> [AnyObject]! {

        return fetchRequestController.sectionIndexTitles
    }
    
    func sectionForSectionMJNIndexTitle(title: String!, atIndex index: Int) {
        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forItem: 0, inSection: index), atScrollPosition: .Top, animated: true)
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
    
    // MARK: - Segmented Control
    
    @IBAction func localServerSwitch(sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        switch (index) {
        case 0:
            fetchRequestController = backfrc!
        case 1:
            updateFetchRequestController()
        default:
            break
        }
        indexView.refreshIndexItems()
        tableView.reloadData()
    }
    

    func updateFetchRequestController() {
        let fetchRequest = NSFetchRequest(entityName: "Contacts")
        let sd = NSSortDescriptor(key: "personNameFirstLetter", ascending: true)
        fetchRequest.sortDescriptors = [sd]
        
        let predicate = NSPredicate(format: "isUpdate == %@", true)
        fetchRequest.predicate = predicate
        
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).coreDataStack.context
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: "personNameFirstLetter", cacheName: nil)
        backfrc = fetchRequestController
        fetchRequestController = frc
        fetchRequestController.delegate = self
        
        do {
            try fetchRequestController.performFetch()
        }
        catch {
            print(error)
        }
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
