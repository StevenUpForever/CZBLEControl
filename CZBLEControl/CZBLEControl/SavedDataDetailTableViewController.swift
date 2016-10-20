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
    
    var coreDataWriteValues = [BLEData]()
    var coreDataReadvalues = [BLEData]()
    
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        if sourceObj is DataList {
            return 2
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sourceObj is DataList {
            return section == 0 ? coreDataWriteValues.count : coreDataReadvalues.count
        } else {
            return dataSourceArray.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        if sourceObj is DataList {
            if indexPath.section == 0 {
                cell.textLabel?.text = coreDataWriteValues[indexPath.row].dataString
                cell.detailTextLabel?.text = coreDataWriteValues[indexPath.row].date
            } else {
                cell.textLabel?.text = coreDataReadvalues[indexPath.row].dataString
                cell.detailTextLabel?.text = coreDataReadvalues[indexPath.row].date
            }
        } else {
            let stringArray = dataSourceArray[(indexPath as NSIndexPath).row]
            if let firstStr = stringArray.first {
                cell.textLabel?.text = firstStr as String
            }
            if stringArray.count > 1 {
                cell.detailTextLabel?.text = stringArray[1] as String
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if sourceObj is DataList {
            if section == 0 {
                return "Write value"
            } else {
                return "Read value"
            }
        } else {
            return nil
        }
    }

}
