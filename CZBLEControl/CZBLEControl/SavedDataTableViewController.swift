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
    
    var googleDriveArray = [GTLDriveFile]()
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
        return googleDriveArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! SavedDataTableViewCell
        
        cell.textLabel?.text = googleDriveArray[indexPath.row].name
        cell.dataSourceObj = googleDriveArray[indexPath.row]

        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationVC = segue.destinationViewController as? SavedDataDetailTableViewController, senderCell = sender as? SavedDataTableViewCell {
            destinationVC.sourceObj = senderCell.dataSourceObj
        }
    }

}
