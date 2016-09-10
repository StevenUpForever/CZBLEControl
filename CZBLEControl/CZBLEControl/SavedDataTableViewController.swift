//
//  SavedDataTableViewController.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 9/4/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
//

import UIKit
import GoogleAPIClient
import MBProgressHUD

enum savedDataSource {
    case iCloudDrive
    case GoogleDrive
    case Dropbox
    case localDrive
}

class SavedDataTableViewController: UITableViewController {
    
    var dataSourceArray = [AnyObject]()
    var indicator: MBProgressHUD!
    
    var dataSource: savedDataSource!

    //MARK: viewController lifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator = MBProgressHUD(view: view)
        indicator.label.text = "Loading files..."
        view.addSubview(indicator)
        
        loadProperDataSource(dataSource)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourceArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! SavedDataTableViewCell
        
        cell.loadData(dataSourceArray[indexPath.row])

        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationVC = segue.destinationViewController as? SavedDataDetailTableViewController, senderCell = sender as? SavedDataTableViewCell {
            destinationVC.sourceObj = senderCell.dataSourceObj
        }
    }

}
