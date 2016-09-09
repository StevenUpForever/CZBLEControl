//
//  SavedDataDetailTableViewController.swift
//  CZBLEControl
//
//  Created by Steven Jia on 9/8/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
//

import UIKit
import MBProgressHUD

class SavedDataDetailTableViewController: UITableViewController {
    
    var sourceObj: AnyObject!
    
    var dataSourceArray = [[NSString]]()
    
    var indicator: MBProgressHUD!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator = MBProgressHUD(view: view)
        indicator.label.text = "Loading file content..."
        view.addSubview(indicator)
        
        loadProperFileContent()
        
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
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)

        let stringArray = dataSourceArray[indexPath.row]
        if let firstStr = stringArray.first {
            cell.textLabel?.text = firstStr as String
        }
        if stringArray.count > 1 {
            cell.detailTextLabel?.text = stringArray[1] as String
        }

        return cell
    }

}
