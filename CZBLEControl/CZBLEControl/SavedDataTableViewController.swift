//
//  SavedDataTableViewController.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 9/4/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
//

import UIKit
import GoogleAPIClient

class SavedDataTableViewController: UITableViewController {
    
    var googleDriveArray = [GTLDriveFile]()

    //MARK: viewController lifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let g = GoogleDriveManager.sharedManager
        g.loadFiles { (success, files) in
            if success {
                self.googleDriveArray = files!
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    CustomAlertController.showCancelAlertController("Fetch Google Drive file failed", message: nil, target: self)
                })
            }
        }
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
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        cell.textLabel?.text = googleDriveArray[indexPath.row].name

        return cell
    }

}
