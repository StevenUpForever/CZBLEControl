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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourceArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let stringArray = dataSourceArray[(indexPath as NSIndexPath).row]
        if let firstStr = stringArray.first {
            cell.textLabel?.text = firstStr as String
        }
        if stringArray.count > 1 {
            cell.detailTextLabel?.text = stringArray[1] as String
        }

        return cell
    }

}
