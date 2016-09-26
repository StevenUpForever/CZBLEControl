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
    case googleDrive
    case dropbox
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourceArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SavedDataTableViewCell
        
        cell.loadData(dataSourceArray[(indexPath as NSIndexPath).row])

        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteData(indexPath)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? SavedDataDetailTableViewController, let senderCell = sender as? SavedDataTableViewCell {
            destinationVC.sourceObj = senderCell.dataSourceObj
        }
    }

}
